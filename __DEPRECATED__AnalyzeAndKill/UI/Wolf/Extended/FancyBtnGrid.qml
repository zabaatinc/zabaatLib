import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import "../"
import QtQuick.Layouts 1.1

GridLayout {
    id : grid
    signal selected(string section)
    onSelected: mySelection = section

    property var btns :   [ /*{ icon : '\uf0ad' , label : 'parts'},
                            { icon : '\uf0c0' , label : 'labor'},
                            { icon : '\uf272' , label : 'extras'},
                            { icon : '\uf239' , label : 'sublets'}*/ ]

    property string mySelection       : ""
    property int btnSize              : width !== 0 || height !== 0 ? Math.min(xSize,ySize) : 0
    property int xSize                : Math.abs((grid.width ) / (columns ))
    property int ySize                : Math.abs((grid.height) / (rows ))
    property bool showHighlight       : true
    property string clickArgsProperty : "label"
    property var fontFamily           : null

//    onBtnsChanged          : if(logic.hasInit) logic.init()
//    onShowHighlightChanged : if(logic.hasInit) logic.init()

    columns                : 4
    Component.onCompleted  : logic.init()

    property QtObject logic : QtObject {
        id : logic
        property bool hasInit : false
        property int initCounter : 0

        function clear(){
            for(var i = grid.children.length - 1; i >= 0; i--){
                var child = grid.children[i]
                if(child){
                    child.parent = null
                    child.destroy()
                }
            }
            grid.children = []
        }
        function init(){
            clear()
            initCounter++
            console.log(rootObject, "initCalled for the", initCounter, "time")
            for(var b = 0; b < btns.length; b++){
                var btnInfo = btns[b]
                var btn     = fancyBtnFactory.createObject(grid)

                if(fontFamily)
                    btn.fontFamily = fontFamily

                btn.btnSize   = Qt.binding(function(){return grid.btnSize})
                btn.icon      = btnInfo.icon
                btn.label     = btnInfo.label
                btn.clickFunc = grid.selected
                btn.clickArgs = btn[clickArgsProperty]

                if(showHighlight) {
                    var anim = highlighterFactory.createObject(btn)
                    anim.myName = btn.clickArgs
                }
            }
            hasInit = true
        }
    }
    property Component fancyBtnFactory : Component {
        id : fancyBtnCmp
        FancyBtn{
            btnSize               : 40
            activeFocusOnTab      : true
            clickArgs             : label
            defaultColor          : focus ? ZGlobal.style.info : ZGlobal.style.accent
            Layout.alignment      : Qt.AlignHCenter
            Layout.preferredWidth : btnSize
            Layout.preferredHeight: btnSize
        }
    }
    property Component highlighterFactory : Component {
        id : highlighterFactory
        ZTracer{
            borderWidth: 10
            property string myName : ""
            property bool selected: myName === grid.mySelection
            onSelectedChanged: if(selected) clrAnim.start()
                               else  {
                                   clrAnim.stop()
                                   color = 'transparent'
                               }

            color : 'transparent'
            ColorAnimation on color {
                id : clrAnim
                from    : "transparent"
                to      : ZGlobal.style.accent
                duration: 1000
                loops   : Animation.Infinite
                running : false
            }
        }
    }



}
