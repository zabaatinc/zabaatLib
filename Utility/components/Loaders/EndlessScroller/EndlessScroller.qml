import QtQuick 2.5
import Zabaat.Utility 1.0
Rectangle {
    id : rootObject
    signal itemSelected(string id, var model, rect r);
    signal flickUp()
    signal flickDown()
    signal finishedCustomHandling()

    signal pageRequested(int page)
    signal pageReceived(int page, var data, bool isBeginning)

    //vars
    readonly property bool ready            : logic.ready && gui.ready
    property int  pageOffset                : 0      //use when we dont start on page 0!!
    property int  rows                      : 4
    property int  columns                   : 1
    property real requestWhenPagesRemaining : 1.5    //request when this much pages are left. YES, it is a REAL. It's smart.
    property real requestPageSize           : requestWhenPagesRemaining //request this amount of pages when a request is made!
    property int  requestDelay              : 100
    property bool requestOnStart            : true
    property bool rerequestPages            : false
    property var  model

    //aliases
    property alias logic     : logic
    property alias gui       : gui
    property alias gv        : gv
    property var delegate    : delegate

    //handlers
    onPageRequested: logic.addUniqueToArr(logic.pagesRequested, page)  //redundant but using for safety
    onPageReceived : logic.addUniqueToArr(logic.pagesReceived, page)   //redundant but using for safety
    onReadyChanged : if(ready){
        if(requestOnStart) {
            delayTimer.start()
            requestPage(pageOffset)
        }
    }



    //funcs, one of them to be overridden!!
    property var getPageFunc : function(page, n, cb){
        var arr = []
        for(var i = 0; i < n ; ++i){
            arr.push({ name : i , page : page })
        }
        if(typeof cb === 'function')
            cb({ data : arr});
    }
    function emitSelection(index){
        var item = model.get(index);
        if(item){
            itemSelected(item.uid, item, logic.getRect(index));
        }
    }

    function refresh(){
        logic.pagesReceived = []
        logic.pagesRequested = []
    }

    //returns true if a request was performed, false if not. Requests may not be perfomed if we already have
    //the said page! The prefunc runs before the call is made. This is to do any preparation. This is the function
    //to call if you manually want to request a page. Will also change logic.hasInit = true if results were received
    function requestPage(pg, cb, preFunc){
        if(rerequestPages || logic.pagesReceived.indexOf(pg) === -1) {
            logic.addUniqueToArr(logic.pagesRequested, pg)
            pageRequested(pageOffset)

            if(typeof preFunc === 'function')
                preFunc(pg)

            getPageFunc(pg, gv.numElemsPerPage * rootObject.requestPageSize, function (msg){
                if(msg.data) {
                    logic.addUniqueToArr(logic.pagesReceived, pg)
                    pageReceived(pg, msg.data, false)
                    if(typeof cb === 'function')
                        cb(msg)

                    if(msg && msg.data && !logic.hasInit) { //init it if we haven't already! This will trigger GetMoreIfNeeded
                        logic.hasInit = true ;
                    }
                }
            })
            return true;
        }
        return false;
    }

    QtObject {
        id : logic

        property bool hasInit       : false
        property var pagesRequested : []    //keeps track of the pages requested
        property var pagesReceived  : []    //keeps track of the pages received

        function addUniqueToArr(arr, item){
            if(arr.indexOf(item) === -1){
                arr.push(item)
            }
        }

        function getRect(index) {
            var c = gv.getDelegateInstance(index);
            if(c) {
                //get C in terms of this!
                var pts = c.mapToItem(rootObject,0,0);
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
        property bool ready: false
        Component.onCompleted: ready = true;

        GridView {
            id : gv
            anchors.fill: parent
            clip        : true
            cellHeight  : height / rows
            cellWidth   : width  / columns
            model       : rootObject.model
//            highlightRangeMode: GridView.ApplyRange
            boundsBehavior: Flickable.OvershootBounds
            flickableDirection: Flickable.VerticalFlick



            Connections {
                target : model ? model : null
                onRowsInserted : {
                    var addCount = last - first + 1
                    if(first < model.count - addCount - 1){ //0 < 10 - 10 - 1   //condition for if stuff was inserted before!
                        //force refresh bro!
//                        console.log("BEFORE FORCE" , gv.count, model.count)
//                        gv.forceLayout()
//                        console.log("AFTER FORCE" ,gv.count,model.count)
                        var a = addCount * Math.floor(gv.cellHeight/columns)

                        if(!gv.flicking){
                            if(gv.count === model.count){
                                gv.disableRequests = true;
                                gv.contentY += a
                                if(pageOffset > 0)
                                    pageOffset--
                                gv.disableRequests = false;
                                finishedCustomHandling()
                            }
                            else
                                contentYAdjustmentTimer.begin(a)
                        }
                        else {
                            if(pageOffset > 0)
                                pageOffset--
                        }


//                        gv.contentY += gv.cellHeight * (addCount/columns)
//                        if(pageOffset > 0) {
//                            pageOffset--
//                        }
                    }
//                    else if(gv.preserveVelocity !== 0){
//                        //remember flick.y speed!
//                        gv.flick(0, -gv.preserveVelocity)
//                        gv.preserveVelocity = 0;
//                    }


                }
            }

            Timer  {
                id : contentYAdjustmentTimer
                interval : 1
                property real adjustment : 0
                onTriggered: {
//                    gv.returnToBounds()
//                    console.log('ADJUST')
                    gv.disableRequests = true;

                    gv.contentY += adjustment
                    if(pageOffset > 0)
                        pageOffset--

                    gv.disableRequests = false;
                    finishedCustomHandling()
                }
                function begin(adj){

                    adjustment = adj
                    start()
                }

            }


            property alias hasInit            : logic.hasInit
            property real adjustY             : 0
            property bool disableRequests     : false
            property int numElemsPerPage      : rows * columns
            property int requestWhenRemaining : numElemsPerPage * rootObject.requestWhenPagesRemaining
            property real preserveVelocity    : 0
//            maximumFlickVelocity: 100000000000000000

            property int t                    : indexAt(0,contentY)
            property int topIdx               : t === -1 ? 0 : t
//            property int preserveIdx          : -1

//            onPreserveIdxChanged              : if(preserveIdx !== -1) console.log("PI", preserveIdx)
            property int totalPages           : count / numElemsPerPage
            property int currentPage          : (topIdx/numElemsPerPage) + pageOffset


            function getDelegateInstance(idx){
                var contentChildren = gv.contentItem.children
                for(var i = 0; i < contentChildren.length; ++i) {
                    var c = contentChildren[i]
                    if(c && c.imADelegate && c.idx === idx)
                        return c;
                }
                return null;
            }
            function getMoreIfNeeded(override, debug){

                function doReq(p, isBeginning, topIdx, debug){
                    return p === -1 ? false : requestPage(p, null, function(){ var b = isBeginning; if(!b) gv.preserveVelocity = gv.verticalVelocity  })
                }


                if(!disableRequests && (!delayTimer.running || override) && gv.model) {

                    //FREEZE RELEVANT INFO in these vars (cause async) ! this will make this atomic and give both up and down a chance
                    //to succeed
                    var topIdx      = gv.topIdx
                    var currentPage = Math.floor(topIdx / gv.numElemsPerPage) + pageOffset
                    var startDelayTimer = false
                    var count = gv.model.count


                    //scrolled down vs scrolled up (& and not at page 0)

                    //determine whether to request next page or previous page (only ask for stuff before when upward is true?)
//                    console.log(topIdx , "<",  requestWhenRemaining, topIdx < requestWhenRemaining, "\t\t", contentY)
                    if(pageOffset > 0 && topIdx  < requestWhenRemaining ) { //requirement for previous
//                        console.log("ASKING FOR PAGE", currentPage - 1, debug)
                        startDelayTimer = doReq(currentPage - 1, true, topIdx, debug)
                    }

//                    console.log(count , topIdx, requestWhenRemaining)
                    if(topIdx !== -1 && count - topIdx <= requestWhenRemaining) { //requirement for next
//                        console.log("ASKING FOR PAGE", currentPage + 1, debug)
                        startDelayTimer =  doReq(currentPage + 1, false, topIdx, debug) || startDelayTimer
                    }

                    if(startDelayTimer)
                        delayTimer.start()
                }

            }





            onHasInitChanged  : if(hasInit )   getMoreIfNeeded(true , 'INIT')
            onWidthChanged    : if(hasInit )   getMoreIfNeeded(false, "WIDTH")
            onHeightChanged   : if(hasInit )   getMoreIfNeeded(false, 'HEIGHT')
            onContentYChanged : if(hasInit )   getMoreIfNeeded(false, 'CONTENTY')
            onModelChanged    : if(hasInit )   getMoreIfNeeded(false, 'MODEL')
            onVerticalVelocityChanged : if(flicking){
                if(verticalVelocity < 0) {  //view is moving up as a result of flicking down
                    rootObject.flickDown()
//                    console.log('down')
                }
                else if(verticalVelocity > 0 && contentY > 0) {
                    rootObject.flickUp()
//                    console.log('up')
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




    }


    Component {
        id : delegate
        Rectangle {
            property var model
            property int index
            property string name : model ? model.name : ""
            property string page : model ? model.page : ""

            border.width: 1
            clip : true
            Text {
                id : subComponent_Text
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                anchors.margins: 10
                text : parent.page
                font.pixelSize: height * 1/2
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                anchors.margins: 10
                text : parent.index
                font.pixelSize: height * 1/2
            }

            Text {
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                anchors.margins: 10
                text : parent.name
                font.pixelSize: height * 1/2

            }
        }
    }




}
