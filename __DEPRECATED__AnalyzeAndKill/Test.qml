import QtQuick 2.5
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0
import Zabaat.MVVM 1.0
import Zabaat.Material 1.0

Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'

    property var arr
    Component.onCompleted:  {
        arr = RestArrayCreator.create(sampleArray());
    }

    function sampleArray(){
        return Chance.n(person,1);
    }
    property var uid : 10
    function person(){
        return {
            id        : ++uid,
            firstname : Chance.first(),
            lastname  : Chance.last(),
            children  : Chance.n(Chance.first, 3),
            stats     : { hp : Chance.integer({min:50,max:100}), mp : Chance.integer({min:0,max:100}) }
        }
    }

    Column {
        id : btns
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Button {
            text : "Add"
            onClicked :  {
                arr.push(person());
                var last = arr[arr.length-1];
                console.log(last._path, last.children._path, last.children[0]._path , last.children[1]._path, last.children[2]._path);
            }
        }
        Button {
            text : "Remove"
            onClicked: {
                console.log("REM DIS IDX", 0)
                arr.remove(0);
            }
        }
        Button {
            text : "Change"
            onClicked: arr[Math.floor(Math.random() * arr.length)].firstname = Chance.first();
        }
        Button {
            text : "ChangeHP"
            onClicked: arr[Math.floor(Math.random() * arr.length)].stats.hp++;
        }


    }

    ListView {
        anchors.centerIn: parent
        width : parent.width/2
        height : parent.height
        model : ViewModel {
            id : vm
            sourceModel: arr
            properties: ['firstname','children','stats']
//            filterFunc: function(a,path,i) {
//                var code = a.firstname.charCodeAt(0);
//                return code >= 65 && code < 75;
//            }
        }
        delegate : Item {
            property var m : model;
            property var kids : m ? vm.logic.embeddedModelsMap[m.path + "/children"] : null;
            width : ListView.view.width;
            height : ListView.view.height * 0.1;

            ZText {
                width : parent.width
                height : parent.height * 0.5
                state : 'f1-success-b1'
                property var hp : parent.m ? parent.m.value.stats.hp : 0
                text : {
                    if(!parent || !parent.m)
                        return "";
                    return parent.m.value.id + "\t" + parent.m.value.firstname + "\t"+ hp + "\t" + parent.m.value.stats.mp;
                }
            }

            ListView {
                id : delLV
                orientation: ListView.Horizontal
                model : parent.kids
                anchors.bottom: parent.bottom
                width : parent.width
                height : parent.height * 0.5
                delegate: ZText {
                    property var m : model
                    text   : m ? m.value : ""
                    width  : delLV.width/3
                    height : delLV.height
                    state  : "danger-f2"
                }
            }

        }
    }

//    Component.onCompleted: {
//        mainWindow.width =  345
//        mainWindow.height = 647
////        375, 647)
//        var userData = UserSystem.settings.userLoginData;
//        console.log("LAST LOGGED IN WITH", JSON.stringify(userData));


//        var f1= function(cb){
//            Functions.time.setTimeOut(100,cb);
//        }
//        var f2= function(cb){
//            Functions.time.setTimeOut(1000,cb);
//        }
//        var f3= function(cb){
//            Functions.time.setTimeOut(10,cb);
//        }

//        UserSystem.functions.skippedLoginFuncs = [f1,f2,f3];

//        UserSystem.functions.loginFunc = function(userdata, cb) {
//            return cb({ data : {
//                              id : '123',
//                              identifier  : userdata.identifier,
//                              firstname : "Shahan",
//                              lastname : 'kazi',
//                              sex : "M",
//                              dob : "02/25/1988",
//                              role : "Admin",
//                              email : "shahan@zabaat.com"
//                          }
//                       })
//        }

//    }

//    Row {
//        width : childrenRect.width
//        spacing : 10
//        height : childrenRect.height
//        Button {
//            text : "Login!"
//            onClicked : UserSystem.login({identifier:"wolf",password:"maliken" })
//        }
//        Button {
//            text : "Skip login!"
//            onClicked : UserSystem.skipLogin()
//        }
//        Button {
//            text : "Logout"
//            onClicked : UserSystem.logout();
//        }
//    }
//    Column {
//        anchors.centerIn: parent
//        width : childrenRect.width
//        height : childrenRect.height
//        Text { text :"Id:"          + " " + UserSystem.userInfo.id }
//        Text { text :"UserName:"    + " " + UserSystem.userInfo.username }
//        Text { text :"FirstName:"   + " " + UserSystem.userInfo.firstname }
//        Text { text :"LastName:"    + " " + UserSystem.userInfo.lastname }
//        Text { text :"Gender:"      + " " + UserSystem.userInfo.gender }
//        Text { text :"Role:"        + " " + UserSystem.userInfo.role }
//        Text { text :"DateOfBirth:" + " " + UserSystem.userInfo.dateOfBirth }
//        Text { text :"Email:"       + " " + UserSystem.userInfo.email }
//    }
//    LoginFlow {
//        id : loginFlow
//        anchors.fill: parent
//        sizeDesigner  : Qt.point(750,1254)
//        sizeMainWindow: Qt.point(375, 647)
//        scaleMultiplier: Qt.point(2,2)
//        config.background.component : Component {
//            Rectangle {
//                color : 'gray'
//            }
//        }
//        config.title_text.component: Component {
//            Text {
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                font.pointSize: 18
//                text : "Login Flow!"
//            }
//        }
//        config.title_img.source: "https://upload.wikimedia.org/wikipedia/en/9/99/MarioSMBW.png"
//    }





}
