import QtQuick 2.5
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0

Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'

    Component.onCompleted: {
        mainWindow.width =  345
        mainWindow.height = 647
//        375, 647)
        var userData = UserSystem.settings.userLoginData;
        console.log("LAST LOGGED IN WITH", JSON.stringify(userData));


        var f1= function(cb){
            Functions.time.setTimeOut(100,cb);
        }
        var f2= function(cb){
            Functions.time.setTimeOut(1000,cb);
        }
        var f3= function(cb){
            Functions.time.setTimeOut(10,cb);
        }

        UserSystem.functions.skippedLoginFuncs = [f1,f2,f3];

        UserSystem.functions.loginFunc = function(userdata, cb) {
            return cb({ data : {
                              id : '123',
                              identifier  : userdata.identifier,
                              firstname : "Shahan",
                              lastname : 'kazi',
                              sex : "M",
                              dob : "02/25/1988",
                              role : "Admin",
                              email : "shahan@zabaat.com"
                          }
                       })
        }

    }

    Row {
        width : childrenRect.width
        spacing : 10
        height : childrenRect.height
        Button {
            text : "Login!"
            onClicked : UserSystem.login({identifier:"wolf",password:"maliken" })
        }
        Button {
            text : "Skip login!"
            onClicked : UserSystem.skipLogin()
        }
        Button {
            text : "Logout"
            onClicked : UserSystem.logout();
        }
    }


    Column {
        anchors.centerIn: parent
        width : childrenRect.width
        height : childrenRect.height
        Text { text :"Id:"          + " " + UserSystem.userInfo.id }
        Text { text :"UserName:"    + " " + UserSystem.userInfo.username }
        Text { text :"FirstName:"   + " " + UserSystem.userInfo.firstname }
        Text { text :"LastName:"    + " " + UserSystem.userInfo.lastname }
        Text { text :"Gender:"      + " " + UserSystem.userInfo.gender }
        Text { text :"Role:"        + " " + UserSystem.userInfo.role }
        Text { text :"DateOfBirth:" + " " + UserSystem.userInfo.dateOfBirth }
        Text { text :"Email:"       + " " + UserSystem.userInfo.email }
    }

    LoginFlow {
        id : loginFlow
        anchors.fill: parent
        sizeDesigner  : Qt.point(750,1254)
        sizeMainWindow: Qt.point(375, 647)
        scaleMultiplier: Qt.point(2,2)
        config.background.component : Component {
            Rectangle {
                color : 'gray'
            }
        }
        config.title_text.component: Component {
            Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 18
                text : "Login Flow!"
            }
        }
        config.title_img.source: "https://upload.wikimedia.org/wikipedia/en/9/99/MarioSMBW.png"
    }





}
