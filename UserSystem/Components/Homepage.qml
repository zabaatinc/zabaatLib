import QtQuick 2.5
import Zabaat.UserSystem 1.0
ZPage {
    id : pg
    property var config
    signal action(var param);
    Component.onCompleted: {
        console.log('HOMEPAGE LOADED')
    }

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
    //title_img
    FlexibleComponent {
        id : welcomeText
        width  : pg.wx(244)
        height : pg.wx(48)
        anchors.top: parent.top
        anchors.topMargin: pg.hx(159)
        anchors.horizontalCenter: parent.horizontalCenter
        src : config ? config.title_text : null;
    }
    FlexibleComponent {
        id : titleImg
        anchors.top : welcomeText.bottom
        anchors.topMargin: pg.hx(42);
        anchors.horizontalCenter: parent.horizontalCenter
        width  : pg.wx(148)
        height : pg.hx(28)
        src : config ? config.title_img : null;
    }

    Column {
        width  : pg.wx(300)
        height : childrenRect.height
        anchors.top: titleImg.bottom
        anchors.topMargin: pg.hx(83);
        anchors.horizontalCenter: parent.horizontalCenter

        property int h: pg.hx(40);
        spacing : pg.hx(30)

        FlexibleComponent {
            width : parent.width
            height: parent.h
            src : config ? config.button : null
            value  : "Log in"
            onEvent : if(name === 'clicked') {
                        action({name:"tologin"});
                      }
            enabled : !UserSystem.noNetwork
        }
        FlexibleComponent {
            width : parent.width
            height : parent.h
            src : config ? config.button : null
            value : "Sign Up"
            onEvent : if(name === 'clicked') {
                         action({name:"tosignup"});
                      }

            enabled : !UserSystem.noNetwork
        }
        FlexibleComponent {
            width : parent.width
            height : parent.h
            src : config ? config.button_alt : null;
            value : "Continue Without Logging In"
            onEvent : if(name === 'clicked')
                        action({name:"skip"})// logic.skipLogin()//logic.toLoginProc("","")
        }
    }

    FlexibleComponent {
        width : parent.width
        height: hx(40)
        src : config ? config.button_alt : null;
        value : "Leave Feedback"
        onEvent : if(name === 'clicked'){
            UserSystem.functions.leaveFeedbackFunc();
        }
        visible : typeof UserSystem.functions.leaveFeedbackFunc === 'function'
        anchors.bottom: parent.bottom
    }


}
