import QtQuick 2.5
import Zabaat.UserSystem 1.0
ZPage {
    id : pg
    signal action(var param);

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

    FlexibleComponent {
        id : welcomeText
        width  : pg.wx(244)
        height : pg.hx(48)
        anchors.top: parent.top
        anchors.topMargin: pg.hx(159)
        anchors.horizontalCenter: parent.horizontalCenter
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.title_text : null;
    }
    FlexibleComponent {
        id : titleImg
        anchors.top : welcomeText.bottom
        anchors.topMargin: pg.hx(42);
        anchors.horizontalCenter: parent.horizontalCenter
        width  : pg.wx(148)
        height : pg.hx(28)
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.title_img : null;
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
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button : null
            value  : "Log in"
            onEvent : if(name === 'clicked') {
                        action({name:"tologin"});
                      }
            enabled : !UserSystem.noNetwork
        }
        FlexibleComponent {
            width : parent.width
            height : parent.h
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button : null
            value : "Sign Up"
            onEvent : if(name === 'clicked') {
                         action({name:"tosignup"});
                      }

            enabled : !UserSystem.noNetwork
            visible : typeof UserSystem.functions.createUserFunc === 'function'
        }
        FlexibleComponent {
            width : parent.width
            height : parent.h
            src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null;
            visible : UserSystem.skipLoginAllowed
            value : "Continue Without Logging In"
            onEvent : if(name === 'clicked')
                        action({name:"skip"})// logic.skipLogin()//logic.toLoginProc("","")
        }
    }

    FlexibleComponent {
        width : parent.width
        height: hx(40)
        src : UserSystem.componentsConfig ? UserSystem.componentsConfig.button_alt : null;
        value : "Leave Feedback"
        onEvent : if(name === 'clicked'){
            UserSystem.functions.leaveFeedbackFunc();
        }
        visible : typeof UserSystem.functions.leaveFeedbackFunc === 'function'
        anchors.bottom: parent.bottom
    }


}
