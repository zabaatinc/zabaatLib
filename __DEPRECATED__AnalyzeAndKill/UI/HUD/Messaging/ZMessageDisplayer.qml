import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import Zabaat.Misc.Global 1.0
import Zabaat.UI.HUD.Chat 1.0

Item
{
    id     : rootObject
    width  : headerWidth
    height : 500

    property int   normalMsgHeight : 32
    property int   headerWidth     : 200
    property int   headerHeight    : 32
    property alias spacing         : lv.spacing
    property alias model           : lv.model
    property bool minimized : true
    property var uniqueProperties : ["normalMsgHeight","headerWidth","headerHeight","spacing","model"]

    property var clientPtr  : ZGlobal.client
    property var chatWindow : null



    ListView
    {
        id : lv
        width  : headerWidth
        height : privates.calcHeight()

        y : !minimized ? -privates.calcHeight() : 0
        spacing : 5
        model : clientPtr ? clientPtr.controller.getModelWhenItArrives("messages",this,"model",true) : null

        Behavior on y   {   NumberAnimation { duration : 250 } }

        onCountChanged: if(count != 0) minimized = false

        header : ZDefaultMessage
        {
            id : headerCmp
            text : "Messages"
            bgkColor : "green"
            textColor : "white"
            height : headerHeight
            width : headerWidth

            MouseArea
            {
                anchors.fill: headerCmp
                onClicked: minimized = !minimized
                drag.target: rootObject
                drag.axis: Drag.XAxis
            }
        }

        delegate: Loader
        {
            objectName : "listDelegate"
            z : 2
            source : "Z" + lv.capitalizeFirstLetter(type) + "Message.qml"
            onLoaded:
            {
                console.log("making new thing")
                console.log("Z" + lv.capitalizeFirstLetter(type) + "Message.qml")
                console.log(type)
                item.height = Qt.binding(function() { if(msgStatus == "acknowledged") return 0; return rootObject.normalMsgHeight } )

                if(item.hasOwnProperty('text'))         item.text         =  Qt.binding(function() { return text } )
                if(item.hasOwnProperty('msgData'))      item.msgData      =  Qt.binding(function() { return msgData } )

                if(item.hasOwnProperty('chatMsgClicked'))
                {
                    item.chatMsgClicked.connect(makeChatWindow)
                }
            }
        }

        add : Transition
        {
            NumberAnimation { properties : "y"            ; from : lv.height; duration : 250;  }
            NumberAnimation { properties : "scale,opacity"; from : 0; to: 1; duration : 250 ; }
        }

        function capitalizeFirstLetter(string) {  return string.charAt(0).toUpperCase() + string.slice(1);  }
    }


    Item
    {
        id : privates

        function calcHeight()
        {
            var childrenHeight = 0
            for(var i = 0; i < lv.contentItem.children.length; i++)
            {
                if(lv.contentItem.children[i].objectName == "listDelegate" &&  lv.contentItem.children[i].height > 0)
                {
                    childrenHeight += lv.contentItem.children[i].height
                    if(i != lv.count - 1)
                        childrenHeight += lv.spacing

                }
            }
            return childrenHeight
        }

    }


    function makeChatWindow(msgData)
    {
       if(!chatWindow)
           chatWindow = ZGlobal.functions.getQmlObject(["QtQuick 2.4","QtQuick.Window 2.2","Zabaat.UI.HUD.Chat 1.0","QtQuick.Controls 1.2"],
                                                       "Window
                                                        {
                                                            visible : true;
                                                            property alias chatView : cv

//                                                            Action
//                                                            {
//                                                                shortcut : 'Shift+Z'
//                                                                onTriggered : cv.sendFunc()
//                                                            }

//                                                            Action
//                                                            {
//                                                                shortcut : 'Shift+Return'
//                                                                onTriggered : cv.nl()
//                                                            }

                                                            ZChatView{ id : cv;  anchors.fill : parent }
                                                        }",
                                                       rootObject)




           chatWindow.title  = "Chat"
           chatWindow.width  = 1000
           chatWindow.height = 900
           chatWindow.chatView.clientPtr = clientPtr
           chatWindow.closing.connect(nullifyWindow)

           if(msgData && msgData.userId && msgData.username)
                chatWindow.chatView.openChatWith(msgData.userId, msgData.username)
    }

    function nullifyWindow() { chatWindow = null }


    function addMsg(msg)
    {
        if(msg != null)
        {
            if(!isNaN(msg))
            {
                msg = { text : msg.toString(),
                        msgData : ({}),
                        type : "default",
                        msgStatus : "true"
                      }
            }
            else if(typeof(msg) === 'string')
            {
                msg = { text : msg,
                        msgData : ({}),
                        type : "default",
                        msgStatus : "true"
                      }
            }


            if(!lv.model)
                lv.model = ZGlobal.functions.getQmlObject(["QtQuick 2.0"], "ListModel{}", privates)


            lv.model.append(msg)
        }
    }

    function ackAll()
    {
        if(lv.model)
        {
            for(var i = 0; i < lv.model.count; i++)
                lv.model.setProperty(i,"msgStatus","acknowledged")
        }
    }

    function unackAll()
    {
        if(lv.model)
        {
            for(var i = 0; i < lv.model.count; i++)
                lv.model.setProperty(i,"msgStatus","unacknowledged")
        }
    }

}

