import QtQuick 2.0
import QtQuick.Layouts 1.1
import Zabaat.UI.Wolf 1.0
import Zabaat.Misc.Global 1.0


GridView
{
    id : gv
    signal reopen  (string name, var obj)
    signal close   (string name, var obj)

    objectName : "RecentsView Delegate"

    cellWidth  : 250
    cellHeight : 500

    property var   iconMap            : null
    property color primaryTextColor   : ZGlobal.style.text.color1
    property color secondaryTextColor : ZGlobal.style.text.color2

    property color primaryBgColor     : ZGlobal.style.warning
    property color secondaryBgcolor   : ZGlobal.style.success


    delegate : Column {
        width  : gv.cellWidth - 50
        height : gv.cellHeight
        spacing : 10

        ZButton{
            id     : mainItemBtn
            width  : parent.width
            height : parent.height * 0.4/5
            text   : name
            icon   : iconMap && iconMap[name] ? iconMap[name] : ""

            onBtnClicked: gv.reopen(name,main)
        }
        ListView{
            id : lv
            objectName : "RecentsViewList"

            width  : parent.width
            height : parent.height * 4.6/5

            model : open ? open : null

            delegate : Row  {
                width  : parent.width
                height : mainItemBtn.height * 0.8
                property int _index : index

                Item{
                    id : opener
                    width : parent.width
                    height : parent.height

                    ZText{
                        id : icon
//                        border.width: 1
                        text : main.item.icon ? main.item.icon : ""
                        color    : gv.primaryBgColor
                        fontColor: gv.primaryTextColor
                        dText{
                            font.family : 'FontAwesome'
                        }
                        width : parent.width * 0.1
                        height : parent.height
                    }
                    ZText{
                        id : _name
                        anchors.right: opener.right
                        width        : icon.text.length === 0? parent.width : parent.width - icon.width
                        height       : parent.height
                        border.width : 1
                        color : gv.primaryBgColor
                        fontColor: gv.primaryTextColor
                        text : name
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked   : gv.reopen(name,main)
                        onEntered : {
                            _name.color     = gv.secondaryBgcolor
                            _name.fontColor = gv.secondaryTextColor
                        }
                        onExited : {
                            _name.color     = gv.primaryBgColor
                            _name.fontColor = gv.primaryTextColor
                        }
                    }
                }
                ZButton {
                    id : closer
                    showIcon: true
                    fontAwesomeIcon: '\uf00d'
                    text : ""
                    width : parent.width * 0.1
                    height: parent.height
                    defaultColor: ZGlobal.style.danger
//                    radius: height/2
                    onBtnClicked:
                    {
                        gv.close(name,main)
                        lv.model.closeFunc(main)
                    }

//                    glowEffectPtr.visible: false
                }
            }
        }
    }

}
