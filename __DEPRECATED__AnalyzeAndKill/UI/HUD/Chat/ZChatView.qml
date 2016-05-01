import QtQuick 2.4
import Zabaat.UI.Wolf 1.0
import Zabaat.Controller 1.0
import QtQuick.Controls 1.2

Rectangle
{
    id : rootObject
    color : Qt.rgba(1,1,1,0.5)
    property var clientPtr : null
    onClientPtrChanged:
    {
        if(clientPtr)
        {
            console.log('doing a postReq for /Global/getUsers')
            clientPtr.controller.postReq("/Globals/getUsers",{},function (response) {}, "user")
        }
    }

    function openChatWith(userid, username)
    {
        console.log("doing a requestChat with",userid, username, typeof clientPtr)
        clientPtr.controller.postReq("/ChatRooms/requestChat",{ userId : userid, username : username},
                                     function (response)
                                     {
                                         console.log('server replied to requestChat')
                                         chatWindow.chatId = response[0].id
                                         userList.currentIndex = userList.getIndexByName(username)  //highlight the right dude
                                     } , "chatrooms")
    }


    function sendChatMsg()
    {
        if(chatWindow.chatId != "-1" && clientPtr)
        {
            clientPtr.controller.postReq("/chatrooms/addMessage",{id : chatWindow.chatId, msgText: inputBox.text } , function (response) { console.log('clearing'); inputBox.text = "" })
        }
    }



    Column
    {
        Row
        {

          Rectangle
          {
                id:userBoundingRect
                width : rootObject.width * 0.7/5
                height : rootObject.height * 5/6
                border.color: Qt.darker(color, 1.5)
                border.width:2
                radius: 4
                color:"#D1D0C9"
                property alias selectedItemId : userList.currentUserId
                property alias selectedItemName : userList.currentUserName

                ListView
                {
                    id: userList
                    property string currentUserId: "derp"
                    property string currentUserName: "derp"

                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4
                    clip: true
                    highlightFollowsCurrentItem: false

                    model: clientPtr ? clientPtr.controller.getModelWhenItArrives("user",this,"model",true) : null
                    highlight: Component
                    {
                        id: highlightBar
                        Rectangle
                        {
                            y: userList.currentItem.y+3;
                            width: parent.width; height: 23
                            color: "lightblue"
                            Behavior on y { SpringAnimation { spring: 2; damping: 0.4 } }
                        }
                    }

                    delegate: Rectangle
                    {
                        width: userList.width
                        height:20
                        color : "transparent"

                        Text
                        {
                            id: txt
                            text: username
                            font.pointSize: 18
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                userList.currentIndex = index;
                                userList.currentUserId = id;
                                userList.currentUserName = username
                                rootObject.openChatWith(id, username)
                            }
                        }
                    }

                      function getIndexByName(name)
                      {
                          if(model)
                          {
                              for(var i = 0; i < model.count; i++)
                              {
                                  if(model.get(i).username == name)
                                      return i
                              }
                          }
                          return -1
                      }


                }


            }

            ZChat
            {
                id : chatWindow
                width : rootObject.width * 4.3/5
                height : rootObject.height * 5/6
                msgData: clientPtr ? clientPtr.controller.getModelWhenItArrives("chatrooms" , this, "msgData",true) : null
            }
        }

        Rectangle
        {
            width : rootObject.width
            height : rootObject.height * 1/6
            color : Qt.rgba(0.8,0.8,0.8,0.5)
            border.width: 1
            border.color : Qt.darker(color)
            radius : height / 16
            clip : true

            TextEdit
            {
                id : inputBox
                width : parent.width   -5
                height : parent.height
                x : 5
                wrapMode : Text.WrapAnywhere

                font.pointSize: 16
//                onAccepted: sendChatMsg()


//                Keys.onPressed:
//                {
//                    if(event.modifiers & Qt.ShiftModifier)
//                    {
//                        console.log('key pressed SHIFT ')
//                        inputBox.text += "\n"
//                    }
//                }

                ZButton
                {
					id:sendButton
                    anchors.right: parent.right
                    anchors.bottom : parent.bottom
                    text : "send"
                    onBtnClicked: sendChatMsg()
                }
            }

            ZScrollBar
            {
                x : parent.width
                height : 16
                cmpSize : 16
                width : parent.height
                rot : 90
                totalDegrees : inputBox.height < inputBox.contentHeight ? Math.ceil((inputBox.contentHeight - inputBox.height) / inputBox.font.pixelSize) : 0
                onTotalDegreesChanged: if(totalDegrees == 0) inputBox.y = 0

                onBtnDec_Clicked: if(inputBox.y < 0) inputBox.y += inputBox.font.pixelSize
                onBtnInc_Clicked: if(inputBox.y > inputBox.height -  inputBox.contentHeight)    inputBox.y -= inputBox.font.pixelSize
            }




        }


//        ZTextBox
//        {
//            id : inputBox
//            width : rootObject.width
//            height : rootObject.height * 1/6
//            textInputStyle:  Qt.ImhMultiLine
//        }
    }

}
