import QtQuick 2.5
import Zabaat.UserSystem 1.0
ZPage {
    id : pg
    property var config
    signal action(var param);
    property alias username : textbox_user.value
    property int currentStep : 1
    property int totalSteps  : 2

    QtObject {
        id : logic

        function requestCode(username) {
            var fn = UserSystem.functions.requestResetCodeFunc
            fn = typeof fn === 'function' ? fn : function(usr, cb) { cb() }

            fn(username, function() {
                step1_requestCode.busy = false;
                currentStep++;
            })
        }

        function resetPass(username,pass,code) {
//            console.log("CALLING RESETPASS", username, pass, code)
            var fn = UserSystem.functions.resetPassFunc
            fn = typeof fn === 'function' ? fn : function(usrname,pass,code, cb) { cb() }
            fn(username, pass, code, function(msg) {
                step2_reset.busy = false;
                if(!msg.err) {
                    action({name:'login', username : username, password : pass } );
                }
            })
        }
    }

    Item {
        id : steps
        width : parent.width
        anchors.bottom: area_progressAndCancel.top
        anchors.top: parent.top
        anchors.topMargin: hx(200);
//        color : 'green'

        Column {
            id : step1_requestCode
            anchors.fill: parent
            visible : currentStep === 1
            spacing : hx(30)
            property bool busy : false
            FlexibleComponent {
                id : textbox_user
                label  : "Username"
                src : config ? config.textbox : null;
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
            }
            FlexibleComponent {
                value : "Request Reset Code";
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
                src : config ? config.button : null
                onEvent : if(name === 'clicked') {
                    parent.busy = true;
                    logic.requestCode(textbox_user.value)
                }
                enabled : !parent.busy
            }

            FlexibleComponent {
                width  : wx(300);
                height : hx(80);
                src : config ? config.text : null;
                anchors.horizontalCenter: parent.horizontalCenter
                value : "An e-mail will be sent to you with a reset code. This may take a few minutes."
            }
        }

        Column {
            id : step2_reset
            anchors.fill: parent
            spacing : hx(30)
            visible : currentStep === 2
            property bool busy : false;

            FlexibleComponent {
                id : textbox_code
                label  : "Code"
                src : config ? config.textbox : null;
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FlexibleComponent {
                id : textbox_pw1
                label  : "New Password"
                src : config ? config.textbox_password : null;
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FlexibleComponent {
                id : textbox_pw2
                label  : "Re-enter Password"
                src : config ? config.textbox_password : null;
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FlexibleComponent {
                value : "Reset and Login";
                width  : wx(300);
                height : hx(40);
                anchors.horizontalCenter: parent.horizontalCenter
                src : config ? config.button : null
                onEvent: if(name === 'clicked') {
                    if(textbox_pw1.value !== textbox_pw2.value)
                        return console.error("Passwords do not match!")

                    parent.busy = true;
                    logic.resetPass(textbox_user.value, textbox_pw2.value, textbox_code.value);
                }
                enabled : !parent.busy
            }

            FlexibleComponent {
                width  : wx(300);
                height : hx(80)
                src : config ? config.text : null;
                anchors.horizontalCenter: parent.horizontalCenter
                value : "Please input the reset code you received at " + textbox_user.value + ".";
            }


        }




    }



    Item {
            id : area_progressAndCancel
            width : wx(300)
            height : hx(85)

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            FlexibleComponent {
                width  : parent.width
                height : hx(40)
                src : config ?config.text : null;
                value : currentStep + "/" + totalSteps
                anchors.bottom: bar.top
            }
            Rectangle {
                id : bar
                width : parent.width
                height : hx(5)
                border.width: 1
                border.color: "white"
                color : 'transparent'
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cancelBtn.top

                Rectangle {
                    id : barFill
                    height : parent.height
                    width  : Math.min((currentStep / totalSteps),1) * parent.width
                }
            }
            FlexibleComponent {
                id : cancelBtn
                value : "Cancel"
                src : config ? config.button_alt : null;
                width : parent.width
                height : hx(40)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                onEvent : if(name === 'clicked')
                              action({name:"tologin",username:textbox_user.value})
            }
        }




//    button
//    button_alt
//    background
//    background_login
//    background_resetpass
//    background_signup
//    background_loggedin
//    title
//    title_img
//    title_text
//    text
//    textbox
//    textbox_password
    FlexibleComponent {
        id : title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: hx(67)
        width  : wx(219)
        height : hx(50)
        src    : config ? config.title : null;
    }







}
