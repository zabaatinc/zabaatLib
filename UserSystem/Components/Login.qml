import QtQuick 2.5
import Zabaat.UserSystem 1.0
import "Facebook"
import Zabaat.Base 1.0
ZPage {
    id : rootObject
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
        src    : UserSystem.componentsConfig ? UserSystem.componentsConfig.title : null;
    }


    Column {
        id : loginItems_inputBoxes
        width : rootObject.wx(290)
        height : childrenRect.height
        spacing : rootObject.hx(30)
        anchors.top: parent.top
        anchors.topMargin: rootObject.hx(200)
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            width  : parent.width
            height : rootObject.hx(40);

            FlexibleComponent {
                id : textbox_user
                src : UserSystem.componentsConfig ? UserSystem.componentsConfig.textbox : null;
                width : parent.width - userListExpanderButton.width
                height : parent.height
                label  : "Username"
                value  : {
                    if(UserSystem.settings.userLoginData && UserSystem.settings.userLoginData[UserSystem.config.keyName_username])
                        return UserSystem.settings.userLoginData[UserSystem.config.keyName_username]
                    return "";
                }

            }
            FlexibleComponent {
                id : userListExpanderButton
                src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button: null;
                value : "▼"
                onEvent : if(name === 'clicked'){
                            userListExpander.visible = true;
                          }
                height: parent.height
                width : visible ? height : 0
                visible : UserSystem.componentsConfig && Lodash.isArray(UserSystem.componentsConfig.userList) && UserSystem.componentsConfig.userList.length > 0
            }
        }





        FlexibleComponent {
            id : textbox_pw
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.textbox_password : null;
            label : "Password"
            value : {
                if(UserSystem.settings.userLoginData && UserSystem.settings.userLoginData[UserSystem.config.keyName_password])
                    return UserSystem.settings.userLoginData[UserSystem.config.keyName_password];
                return "";
            }
            visible : UserSystem.passwordRequired
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
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null
        visible : Lodash.isFunction(UserSystem.functions.resetPassFunc) && Lodash.isFunction(UserSystem.functions.requestResetCodeFunc)
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
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button : null
            width : parent.width
            height: rootObject.hx(40)
            value : "Log in"
            enabled : {
                if(UserSystem.noNetwork ||
                   textbox_user.value.length == 0 ||
                   (textbox_pw.value.length == 0 && UserSystem.passwordRequired) ||
                   ((textbox_user.error || textbox_pw.error))
                ) {
                    return false;
                }
                return true;
            }
            onEvent : if(name === 'clicked') {
                action({name:"login", username : textbox_user.value, password:textbox_pw.value})
            }
        }
        FlexibleComponent {
            width : rootObject.wx(60)
            height : rootObject.hx(19)
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.text : null;
            value : "OR"
            anchors.horizontalCenter: parent.horizontalCenter
            visible : !!UserSystem.facebookAppId
        }
        FlexibleComponent {
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button : null
            width : parent.width
            height: rootObject.hx(40)
            value : /*Constants.fa(FA.facebook_f) + Constants.spaces(4) +*/ "Log in with Facebook"
            enabled : !UserSystem.noNetwork
            onEvent: if(name === 'clicked' ) fbLogin.visible = true;
            visible : !!UserSystem.facebookAppId
        }
    }

    FlexibleComponent {
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null
        width : rootObject.wx(300)
        height : rootObject.hx(40)
        value : "Continue Without Logging In"
        onEvent : if(name === 'clicked') action({name:"skip"})
        anchors.top: loginItem_buttons.bottom
        anchors.topMargin: rootObject.hx(45)
        anchors.horizontalCenter: parent.horizontalCenter
        visible : UserSystem.skipLoginAllowed
    }


    FlexibleComponent {
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null
        width : rootObject.wx(248)
        height : rootObject.hx(24)

        value  : "Sign Up"
        onEvent: if(name === 'clicked') action({name:"tosignup"})
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: rootObject.hx(17)
        visible : !fbLogin.visible && Lodash.isFunction(UserSystem.functions.createUserFunc)  //dont show this at the bottom when fb area is up!
        enabled : !UserSystem.noNetwork
    }

    UIBlocker {
        id : userListExpander
        anchors.fill: parent
        text : ""
        visible : false

        FlexibleComponent {
            id : userListExpanderBackButton
            anchors.margins: 5
            anchors.top: parent.top
            anchors.left: parent.left
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button : null;
            onEvent: if(name === 'clicked')
                         userListExpander.visible= false;
            value : "◄"
            height : userLv.cellHeight * 1.1
            width  : height
        }
        FlexibleComponent {

            height : userListExpanderBackButton.height
//            property var animals : ["🐀","🐁","🐂","🐃","🐄","🐅","🐆","🐇","🐈","🐉","🐊","🐋","🐌",
//                                    "🐍","🐎","🐏","🐐","🐑","🐒","🐓","🐔","🐕","🐖","🐗","🐘","🐙",
//                                    "🐚","🐛","🐜","🐝","🐞","🐟","🦂","🦃","🐠","🦀","🐡","🐢","🐣",
//                                    "🐤","🐥","🐦","🐧","🐨","🐩","🐪","🐫","🐬","🕷","🕸","🐭","🐮",
//                                    "🦁","🐯","🐰","🐱","🐲","🐳","🐴","🐵","🐶","🐷","🐸","🦄","🐹",
//                                    "🐺","🐻","🐼","🐽"]

//            property string randAnimalIcon : ""
            value : "Choose User";
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null;
            anchors.left: userListExpanderBackButton.right
            anchors.right: parent.right
            anchors.margins: 5
            anchors.top: parent.top
//            onVisibleChanged: if(visible) {
//                                  var idx = Math.floor(Math.random() * animals.length);
//                                  randAnimalIcon = animals[idx];
//                              }

        }
        Item {
            anchors.top:userListExpanderBackButton.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip : true

            ListView {
                id : userLv
                width : parent.width * 0.9
                height : Math.min(cellHeight * count + (spacing * (count-1)) , parent.height -cellHeight);
                anchors.centerIn: parent
                model : userListExpanderButton.visible ? UserSystem.componentsConfig.userList : null;
                spacing : hx(15);

                property real cellHeight: userListExpander.height * 0.07
                delegate: UserButton {
                    m : userLv.model[index]
                    width  : ListView.view.width
                    height : userLv.cellHeight
                    onClicked: {
                        textbox_user.value = username;
                        userListExpander.visible = false;
                    }
                }



            }
        }
    }

    UIBlocker {
        id : fbLogin
        anchors.fill: parent
        visible : false
        text : ""

        Rectangle {
            id : fbBar
            width : parent.width
            height : parent.height * 0.08

            FlexibleComponent {
                anchors.fill : parent
                value: 'Authenticate'
                src : UserSystem.componentsConfig ? UserSystem.componentsConfig.text : null;
            }

            FlexibleComponent {
                width    : height
                height   : parent.height
                value    : "<"
                src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null;
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
