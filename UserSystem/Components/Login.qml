import QtQuick 2.5
import Zabaat.UserSystem 1.0
import "Facebook"
ZPage {
    id : rootObject
    property var config
    signal action(var param);
    property alias username : textbox_user.value

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


    Column {
        id : loginItems_inputBoxes
        width : rootObject.wx(290)
        height : childrenRect.height
        spacing : rootObject.hx(30)
        anchors.top: parent.top
        anchors.topMargin: rootObject.hx(200)
        anchors.horizontalCenter: parent.horizontalCenter

        FlexibleComponent {
            id : textbox_user
            src : config ? config.textbox : null;

            label  : "Username"
            value  : {
                if(UserSystem.settings.userLoginData && UserSystem.settings.userLoginData[UserSystem.config.keyName_username])
                    return UserSystem.settings.userLoginData[UserSystem.config.keyName_username]
                return "";
            }
            width  : parent.width
            height : rootObject.hx(40);
        }
        FlexibleComponent {
            id : textbox_pw
            src : config ? config.textbox_password : null;
            label : "Password"
            value : {
                if(UserSystem.settings.userLoginData && UserSystem.settings.userLoginData[UserSystem.config.keyName_password])
                    return UserSystem.settings.userLoginData[UserSystem.config.keyName_password];
                return "";
            }
            clip : true
            width : parent.width
            height : rootObject.hx(40);
        }
    }

    FlexibleComponent {
        id : button_resetPass
        width : wx(290)
        height : hx(30);
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginItems_inputBoxes.bottom
        anchors.topMargin: hx(5);
        value : "Forgot password?";
        onEvent: if(name === 'clicked')
                    action({name:'reset',username:textbox_user.value})
        src : config ? config.button : null
    }

    Column {
        id : loginItem_buttons
        width : rootObject.wx(300)
        height : childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: button_resetPass.bottom
        anchors.topMargin: rootObject.hx(50);
        spacing : rootObject.hx(5);
        FlexibleComponent {
            src : config ? config.button : null
            width : parent.width
            height: rootObject.hx(40)
            value : "Log in"
            enabled : !UserSystem.noNetwork
            onEvent : if(name === 'clicked') {
                if(textbox_user.error || textbox_pw.error)
                    return;

                if(textbox_user.value.length == 0){
//                    Constants.errDisplay("Username is empty");
                }
                else if(textbox_pw.value.length == 0){
//                    Constants.errDisplay("Password is empty");
                }
                else {
                    action({name:"login", username : textbox_user.value, password:textbox_pw.value})
                }
            }
        }
        FlexibleComponent {
            width : rootObject.wx(60)
            height : rootObject.hx(19)
            src : config ? config.text : null;
            value : "OR"
            anchors.horizontalCenter: parent.horizontalCenter
            visible : !!UserSystem.facebookAppId
        }
        FlexibleComponent {
            src : config ? config.button : null
            width : parent.width
            height: rootObject.hx(40)
            value : /*Constants.fa(FA.facebook_f) + Constants.spaces(4) +*/ "Log in with Facebook"
            enabled : !UserSystem.noNetwork
            onEvent: if(name === 'clicked' ) fbLogin.visible = true;
            visible : !!UserSystem.facebookAppId
        }
    }

    FlexibleComponent {
        src : config ? config.button_alt : null
        width : rootObject.wx(300)
        height : rootObject.hx(40)
        value : "Continue Without Logging In"
        onEvent : if(name === 'clicked') action({name:"skip"})
        anchors.top: loginItem_buttons.bottom
        anchors.topMargin: rootObject.hx(45)
        anchors.horizontalCenter: parent.horizontalCenter
    }



    //IS IN ROOTOBJECT! NOT PART OF THIS!
    FlexibleComponent {
        src : config ? config.button_alt : null
        width : rootObject.wx(248)
        height : rootObject.hx(24)

        value  : "Sign Up"
        onEvent: if(name === 'clicked') action({name:"tosignup"})
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: rootObject.hx(17)
        visible : !fbLogin.visible  //dont show this at the bottom when fb area is up!
        enabled : !UserSystem.noNetwork
    }


    UIBlocker {
        id : fbLogin
        anchors.fill: parent
        parent : rootObject
        visible : false
        text : ""

        Rectangle {
            id : fbBar
            width : parent.width
            height : parent.height * 0.08

            FlexibleComponent {
                anchors.fill : parent
                value: 'Authenticate'
                src : config ? config.text : null;
            }

            FlexibleComponent {
                width    : height
                height   : parent.height
                value    : "<"
                src : config ? config.button_alt : null;
                onEvent : if(name === 'clicked') fbLogin.visible = false;
                visible : fb.opacity !== 0
            }

        }

        Facebook {
            id : fb
            width             : parent.width
            height            : parent.height - fbBar.height
            anchors.bottom    : parent.bottom
            input.readyFlag    : fbLogin.visible
            input.appId        : UserSystem.facebookAppId
            onAppCodeReceived: {
                var success = function() {
                    fbLogin.visible = false;
                    action({name:'loggedin'})
                }

                var fail = function(){
                    fbLogin.text = "";
                    fb.visible = false;
                }

                fbLogin.text = ['.','..','...']
                UserSystem.loginThruFb("auth/facebook/callback?" + fb.input.appAuthenticatedKey + "=" + code, success, fail)
            }
        }



    }



}
