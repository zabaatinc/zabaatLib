import QtQuick 2.5
import Zabaat.UserSystem 1.0
ZPage {
    id : rootObject
    property var config
    signal action(var param);

    //config contains:
    //button
    //button_alt
    //background
    //background_login
    //background_resetpass
    //background_signup
    //background_loggedin
    //textbox
    //textbox_password
    //title_text
    //title_imgSrc
    property real nextBtnHeight  : rootObject.height * 0.06
    property real cancelBtnHeight: rootObject.height * 0.094
    property real uxWidth        : rootObject.width * 0.86
    property real barHeight      : rootObject.height * 0.01
    property real tosHeight      : rootObject.height * 0.1





    QtObject {
        id : logic
        function createAndLogin(info, cb){
            menu.enabled = false;
            UserSystem.functions.createUserFunc(info, function(msg){
                                   if(!msg || msg.err || !msg.data)
                                        return menu.enabled = false;

                                    UserSystem.login(info,function(){
                                        if(typeof cb === 'function')
                                            cb()
                                        action({name:'loggedin'})
                                    })
                                 })
        }
        function genUserInfoObj(){
            var r = {}
            r[UserSystem.config.keyName_username] = boxUsername.value;
            r[UserSystem.config.keyName_email] = boxEmail.value;
            r[UserSystem.config.keyName_password] = boxPassword.value;

            return r
        }
    }

    Item {
        id : gui
        anchors.fill: parent

        Item {
            id : menu
            width : parent.width
            height : parent.height * 0.53

            Column {
                width : uxWidth
                height : childrenRect.height
                anchors.centerIn: parent
                spacing : nextBtnHeight / 2

                FlexibleComponent {
                    id : boxEmail
                    width  : uxWidth
                    height : nextBtnHeight
                    label  : "E-mail"
                    src : config ? config.textbox : null;
                }
                FlexibleComponent {
                    id : boxUsername
                    width  : parent.width
                    height : nextBtnHeight
                    label  : "Username"
                    src : config ? config.textbox : null;
                }
                FlexibleComponent {
                    id : boxPassword
                    width  : parent.width
                    height : nextBtnHeight
                    label  : "Password"
                    src : config ? config.textbox_password : null;
                }
            }
        }
        Item {
            width : parent.width
            height : parent.height - menu.height
            anchors.bottom: parent.bottom

            FlexibleComponent {
                id : nextBtn
                width : uxWidth
                height : nextBtnHeight
                value : "Next"
                src : config ? config.button : null;
                anchors.horizontalCenter: parent.horizontalCenter
                onEvent: if(name === 'clicked') logic.createAndLogin(logic.genUserInfoObj())
            }
            FlexibleComponent {
                id: tosBtn
                width : parent.width
                src : config ? config.button_alt : null;
                height : tosHeight
                value : "By signing up, you agree to our<br><b>Terms & Service</b> agreement"
                anchors.top : nextBtn.bottom
                visible : typeof UserSystem.functions.showTos === 'function' ?  true : false
                onEvent : if(name === 'clicked') UserSystem.functions.showTos();
            }



            FlexibleComponent {
                width  : parent.width
                height : nextBtnHeight
                src : config ? config.text : null;
                value   : "1 / 2"
                anchors.bottom: bar.top
            }
            Rectangle {
                id : bar
                width : uxWidth
                height : barHeight
                border.width: 1
                border.color: barFill.color
                color : 'transparent'
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cancelBtn.top

                Rectangle {
                    id : barFill
                    height : parent.height
                    width  : parent.width /2
                }
            }
            FlexibleComponent {
                id : cancelBtn
                value : "Cancel"
                width : parent.width
                height : cancelBtnHeight
                src : config ? config.button_alt : null;
                anchors.bottom: parent.bottom
                onEvent: if(name === 'clicked') action({name : "tologin" })
            }
        }
    }




}
