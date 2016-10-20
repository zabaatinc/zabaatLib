import QtQuick 2.5
import Zabaat.UserSystem 1.0
import "Facebook"
import "../Lodash"
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

        Row {
            width  : parent.width
            height : rootObject.hx(40);

            FlexibleComponent {
                id : textbox_user
                src : config ? config.textbox : null;
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
                src : config ? config.button: null;
                value : "▼"
                onEvent : if(name === 'clicked'){
                            userListExpander.visible = true;
                          }
                height: parent.height
                width : visible ? height : 0
                visible : config && Lodash.isArray(config.userList) && config.userList.length > 0
            }
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
        src : config ? config.button_alt : null
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
        id : userListExpander
        anchors.fill: parent
        text : ""

        FlexibleComponent {
            id : userListExpanderBackButton
            anchors.margins: 5
            anchors.top: parent.top
            anchors.left: parent.left
            src : config ? config.button : null;
            onEvent: if(name === 'clicked')
                         userListExpander.visible= false;
            value : "◄"
            height : userLv.cellHeight * 1.1
            width  : height
        }

        FlexibleComponent {
            width : parent.width - userListExpanderBackButton.width
            height : userListExpanderBackButton.height
            value : "Choose User";
            src : config ? config.button : null;
            anchors.right: parent.right
            anchors.margins: 5
            anchors.top: parent.top
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
                model : userListExpanderButton.visible ? config.userList : null;
                spacing : hx(15);

                property real cellHeight: userListExpander.height * 0.07
                delegate: Row {
                    id : userDel
                    width  : ListView.view.width
                    height : userLv.cellHeight
                    property var m  : userLv.model[index]
                    property string textDisp
                    property string avatar
                    property string username
                    onMChanged: {
                        if(!m)
                            return;

                        if(Lodash.isObject(m)){
                            avatar = m[UserSystem.config.keyName_avatar];
                            avatar = avatar || Qt.resolvedUrl("blank.png");

                            var first    = m[UserSystem.config.keyName_firstName] || "";
                            var last     = m[UserSystem.config.keyName_lastName]  || "";
                            var username = m[UserSystem.config.keyName_username]  || "";

                            userDel.username = username || (first + " " + last);

                            if(first || last)
                                return textDisp = first + " " + last;
                            else
                                return textDisp = username;
                        }
                        else {
                            avatar = Qt.resolvedUrl('blank.png');
                            userDel.username = textDisp = m;
                        }


                    }

                    RoundedImage {
                        width  : height
                        height : parent.height
                        source : parent.avatar
                    }

                    FlexibleComponent {
                        width : parent.width - parent.height
                        height : parent.height
                        value : parent.textDisp
                        src : config ? config.button_alt : null;
                        onEvent: if(name === 'clicked') {
                                     textbox_user.value = parent.username;
                                     userListExpander.visible = false;
                                 }
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
