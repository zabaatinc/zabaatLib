import QtQuick 2.5
import Zabaat.Utility 1.0
Rectangle {
    id : rootObject
    signal itemSelected(string id, var model, rect r);
    signal flickUp()
    signal flickDown()
    signal pageReceived(int page, var data, bool isBeginning)

    readonly property bool ready : logic.ready && gui.ready
    onReadyChanged: if(ready && requestOnStart) {
                               delayTimer.start()
                               getPageFunc(pageOffset, gv.numElemsPerPage, function (msg){
                                   if(msg.data)
                                       pageReceived(pageOffset, msg.data, false)
                               })
                           }


    //vars
    property int pageOffset    : 0      //the current page we are on!
    property int rows          : 4
    property int columns       : 1
    property int requestDelay  : 100
    property bool requestOnStart: true
    property var model

    //aliases
    property alias logic     : logic
    property alias gui       : gui
    property alias gv        : gv
    property var delegate    : delegate

    //funcs, one of them to be overridden!!
    property var getPageFunc : function(page, n, cb){
//        console.log("UNIMPLEMENTED")

        function randPerson(){
            return {
                first : Chance.first(),
                last  : Chance.last(),
                clr   : Qt.rgba(Math.random(), Math.random(), Math.random()),
                age   : Chance.age()
            }
        }

        var arr =  Chance.n(randPerson,n)
        if(typeof cb === 'function')
            cb({ data : arr});
    }

    function emitSelection(index){
        var item = model.get(index);
        if(item){
            itemSelected(item.uid, item, logic.getRect(index));
        }
    }


    QtObject {
        id : logic
        function getRect(index) {
            var c = gv.getDelegateInstance(index);
            if(c) {
                //get C in terms of this!
                var pts = c.mapToItem(rootObject);
                return Qt.rect(pts.x,pts.y,c.width,c.height)
            }
        }

        property Timer delayTimer : Timer {
            id : delayTimer
            interval : rootObject.requestDelay
        }


        property bool ready: false
        Component.onCompleted: ready = true;
    }



    Item {
        id : gui
        anchors.fill: parent

        GridView {
            id : gv
            anchors.fill: parent
            clip        : true
            cellHeight  : height / rows
            cellWidth   : width  / columns
            model       : rootObject.model

            onWidthChanged   : if(rootObject.ready) getMoreIfNeeded()
            onHeightChanged  : if(rootObject.ready) getMoreIfNeeded()
            onContentYChanged: if(rootObject.ready) getMoreIfNeeded()
            onModelChanged   : if(rootObject.ready) getMoreIfNeeded()

            property int numElemsPerPage      : rows * columns
            property int requestWhenRemaining : numElemsPerPage * 1.5

            property int t : indexAt(0, contentY)

            Connections {
                target : rootObject
                onReadyChanged : if(rootObject.ready)
                                     gv.getMoreIfNeeded(true)
            }

            property int topIdx               : t !== -1 ? t : 0
            property int totalPages           : count / numElemsPerPage
            property int currentPage          : (topIdx/numElemsPerPage) + pageOffset

            onVerticalVelocityChanged : if(flicking){
                if(verticalVelocity < 0) {  //view is moving up as a result of flicking down
                    rootObject.flickDown()
//                    console.log('down')
                }
                else if(verticalVelocity >0 && contentY > 0) {
                    rootObject.flickUp()
//                    console.log('up')
                }

            }

            function getDelegateInstance(idx){
                var contentChildren = gv.contentItem.children
                for(var i = 0; i < contentChildren.length; ++i) {
                    var c = contentChildren[i]
                    if(c && c.imADelegate && c.idx === idx)
                        return c;
                }
                return null;
            }
            function getMoreIfNeeded(override){
                if((!delayTimer.running || override) && gv.model) {

                    //scrolled down vs scrolled up (& and not at page 0)
                    var p = -1
                    var isBeginning

                    //determine whether to request next page or previous page
                    if(pageOffset > 0 && topIdx - requestWhenRemaining <= 0 ) { //requirement for previous
                        p = currentPage - 1
                        pageOffset--
                        isBeginning = true;
                    }
                    else if(topIdx !== -1 && gv.model.count - topIdx <= requestWhenRemaining) { //requirement for next
                        p = currentPage + 1
                        isBeginning = false;
                    }

                    if(p !== -1) {
                        delayTimer.start()
                        rootObject.getPageFunc(p, gv.numElemsPerPage, function(msg){
                            if(msg && msg.data && rootObject) {
                                rootObject.pageReceived(p, msg.data, isBeginning)
                                if(isBeginning){
                                    var c = (msg.data.length / columns) * gv.cellHeight     //data.length / columns gives us the extra rows!
                                    console.log("adjust contentY by" , c)
                                    contentY += c
                                }
                            }
                        })
                    }
                }
            }


            delegate : Loader {
                id : gvDelLoader
                width : gv.cellWidth
                height : gv.cellHeight
                sourceComponent: rootObject.delegate

                property var  m          : rootObject.model  && rootObject.model.count > index ? rootObject.model.get(index) : null
                property int  idx        : index
                property bool imADelegate: true

                onLoaded : if(item) {
                               item.anchors.fill = gvDelLoader
                               if(item.hasOwnProperty('index'))
                                   item.index = Qt.binding(function() { return gvDelLoader ? gvDelLoader.idx : -1 })
                               if(item.hasOwnProperty('model'))
                                   item.model = Qt.binding(function() { return gvDelLoader ? gvDelLoader.m : null })
                               if(typeof item.clicked === 'function') {
                                   gvDelMa.enabled = false;
                                   item.clicked.connect(function() { rootObject.emitSelection(idx) } )
                               }
                               else
                                   gvDelMa.enabled = true;
                           }
                MouseArea {
                    id : gvDelMa
                    anchors.fill: parent
                    onClicked   : rootObject.emitSelection(idx)
                    z : Number.MAX_VALUE
                }

            }
        }



        property bool ready: false
        Component.onCompleted: ready = true;
    }


    Component {
        id : delegate
        Rectangle {
            property var model
            property int index
            property string first : model ? model.first : ""
            property string last  : model ? model.last  : ""


            color : Qt.rgba(Math.random(), Math.random(), Math.random())
            border.width: 1
            clip : true
            Text {
                id : subComponent_Text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color : 'white'
                anchors.fill: parent
                text : parent.index + "\n" + parent.first + "\n" + parent.last
                font.pixelSize: height * 1/5
            }
        }
    }




}
