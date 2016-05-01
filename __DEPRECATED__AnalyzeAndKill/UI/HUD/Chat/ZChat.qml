import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import Zabaat.UI.HUD.Messaging 1.0

Column
{
    id : rootObject
    property alias dList : lv
    property alias msgData : lv.msgData
    property alias chatId : lv.chatId
    property alias userNameColor : lv.userNameColor
    property alias chatColor     : lv.chatColor
    property alias bubbleColor   : lv.bubbleColor
    property alias fontSize     : lv.fontSize

    ListView
    {
        id : lv
        width  : rootObject.width
        height : rootObject.height - footerRect.height


        property string chatId       : "-1"
        property var   msgData       : null
        property color userNameColor : "green"
        property color chatColor     : "black"
        property color bubbleColor   : "white"
        property int   fontSize      : ZGlobal.style.text.normal.pointSize


        onMsgDataChanged: setModel()
        onChatIdChanged: if(chatId != "-1") setModel()



        function setModel()
        {
            if(msgData )
            {
                if(lv.model != null)
                    lv.model.clear()

                if(msgData.getById)
                {
                    console.log("finding chatId",chatId)
                    var m = msgData.getById(chatId)
                    if(m != null)
                    {
                        console.log("found",m)
                        lv.model = msgData.getById(chatId).chatMessages
                    }
                }
                else
                    console.log("getById is not defined")
            }
        }





        //interactive: false


        clip : true
        model : null

        spacing : 10

       delegate : Rectangle
        {
            objectName : "listDelegate"
            id : rect
            color : lv.bubbleColor
            width : lv.width
            height : usernameText.height + 2  + messageText.height
            radius : height / 4

            //Component.onCompleted : lv.height = privates.calcHeight()


            property alias dUserNameText : usernameText
            property alias dMessageText  : messageText

            Text
            {
                id : timeStampTxt
                color : lv.userNameColor
                text  : Qt.formatDateTime(timeStamp)
                scale : paintedWidth > width ? width / paintedWidth : 1
                font {
                    family : ZGlobal.style.text.normal.family
                    bold   : ZGlobal.style.text.normal.bold
                    italic : ZGlobal.style.text.normal.italic
                }

                anchors.right: rect.right
                anchors.rightMargin: 5
                visible : rect.height > 0
            }

            Column
            {
                spacing : 2
                visible : rect.height > 0

                Text
                {
                    id : usernameText
                    color : lv.userNameColor
                    text  : "<b>" + username + "</b>: "
                    scale : paintedWidth > width ? width / paintedWidth : 1
                    font.pointSize: fontSize
                    width : rect.width - timeStampTxt.contentWidth - 5
                    visible : rect.height > 0
                }

                Text
                {
                    id : messageText
                    color : lv.chatColor
                    text : msgText
                    scale : paintedWidth > width ? width / paintedWidth : 1
                    font.pointSize: fontSize
                    width : rect.width
                    visible : rect.height > 0
                }
            }
        }


        function sendMesage(user, msg)
        {
            var date = new Date()

            var data = { username : user,
                         msgText  : msg,
                         timeStamp : date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear()
                       }

            if(!lv.model)
                lv.model = ZGlobal.functions.getQmlObject(["QtQuick 2.0"], "ListModel{}", privates)

            lv.model.append(data)
        }

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



    Rectangle
    {
        id : footerRect
        width : lv.width
        height : 16
        color : "green"
        visible : ( lv.contentHeight > lv.height) && (-lv.contentY + lv.contentHeight) > footerRect.y ? true : false

//        Timer
//        {
//            interval : 250
//            running : true
//            repeat : true
//            onTriggered:
//            {
//                var visVal =
//                console.log(lv.contentHeight, -lv.contentY + lv.contentHeight,  footerRect.y)

//                footerRect.visible = visVal
//            }
//        }

    }


}

