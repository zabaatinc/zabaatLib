import QtQuick 2.5
import QtQuick.Controls 1.4

QtObject {
    id :config

    property alias button                : button
    property alias button_alt            : button_alt
    property alias background            : background
    property alias background_login      : background_login
    property alias background_resetpass  : background_resetpass
    property alias background_signup     : background_signup
    property alias background_loggedin   : background_loggedin
    property alias title                 : title
    property alias title_img             : title_img
    property alias title_text            : title_text
    property alias text                  : text
    property alias textbox               : textbox
    property alias textbox_password      : textbox_password
    property var userList   //should be an array of all users!

    property var onLoggedInQml : Component {
        Text {
            text : "Logged In"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Timer {
                running : true;
                interval: 250
                onTriggered: parent.done();
            }

            signal done();
        }
    }

    property QtObject ___priv : QtObject {
        id : priv
        property ComponentInfo button               : ComponentInfo{ id : button ;component: Component { Button {} } }
        property ComponentInfo button_alt           : ComponentInfo{ id : button_alt ;component: button.component }
        property ComponentInfo background           : ComponentInfo{ id : background; }
        property ComponentInfo background_login     : ComponentInfo{ id : background_login     ;component : background.component }
        property ComponentInfo background_resetpass : ComponentInfo{ id : background_resetpass ;component : background.component }
        property ComponentInfo background_signup    : ComponentInfo{ id : background_signup    ;component : background.component }
        property ComponentInfo background_loggedin  : ComponentInfo{ id : background_loggedin  ;component : background.component }
        property ComponentInfo title : ComponentInfo {
            id : title
            component: Component { Text {
                text : Qt.application.name
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20
                color : 'white'
            } }
        }
        property ComponentInfo title_img : ComponentInfo { id : title_img }
        property ComponentInfo title_text : ComponentInfo {
            id : title_text
            component : Component { Text {
                    font.pointSize: 14;
                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter
            } }
        }
        property ComponentInfo text : ComponentInfo {
            id : text
            component : Component { Text {
                    font.pointSize: 12;
                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter
            } }
        }
        property ComponentInfo textbox : ComponentInfo {
            id : textbox
            component : Component {
                Rectangle {
                    id : textboxinstance
                    objectName: "default_textbox"
                    border.width: 1
                    property alias text : ti.text
                    TextInput {
                        id : ti
                        anchors.fill: parent
                        anchors.margins: 5
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        property ComponentInfo textbox_password : ComponentInfo {
            id : textbox_password
            component : Component {
                Rectangle {
                    objectName: "default_textbox_password"
                    border.width: 1
                    property alias text : ti.text
                    TextInput {
                        id : ti
                        anchors.fill: parent
                        anchors.margins: 5
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        echoMode : TextInput.Password
                    }
                }
            }
        }

    }
}
