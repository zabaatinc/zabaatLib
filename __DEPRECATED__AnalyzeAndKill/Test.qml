import QtQuick 2.5
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0
import Zabaat.MVVM 1.0

import Zabaat.Material 1.0
import Zabaat.Controller 1.0


Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'


    property var arr
    function sampleArray(n){
        n = n || 1;
        return Chance.n(person,n);
    }
    property var uid : 10
    function person(){
        var assign = uid++;
        return {
            id        : assign.toString(),
            firstname : Chance.first(),
            lastname  : Chance.last(),
            children  : Chance.n(Chance.first, 3),
            stats     : { hp : Chance.integer({min:50,max:100}), mp : Chance.integer({min:0,max:100}) }
        }
    }


    Component.onCompleted: {
        var sample = sampleArray(1);
        arr = RestArrayCreator.create(sample);
//        mainWindow.width =  345
//        mainWindow.height = 647
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
    LoginFlow {
        id : loginFlow
        anchors.fill: parent
        sizeDesigner  : Qt.point(750,1254)
        sizeMainWindow: Qt.point(375, 647)
        scaleMultiplier: Qt.point(2,2)
        onDone : loginFlow.visible = false;

        Component.onCompleted: {
            UserSystem.componentsConfig.userList                   = ['Shahan','Fahad',"Anam","Brett"]
            UserSystem.componentsConfig.title_text.component       = titleText;
            UserSystem.componentsConfig.textbox.component          = textbox
            UserSystem.componentsConfig.textbox_password.component = textbox_password
            UserSystem.componentsConfig.button.component           = button
            UserSystem.componentsConfig.button_alt.component       = button_alt
            UserSystem.componentsConfig.background.component       = background
        }
    }

    Item {
        id : cmps
        Component {
            id: titleText
            Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 18
                text : "Login Flow!"
            }
        }
        Component { id : textbox; ZTextBox { state : 'cliplabel-b1-f12pt-nobar' }}
        Component { id : textbox_password;  ZTextBoxPassword { state : 'cliplabel-b1-f12pt-nobar' }}
        Component { id : button;  ZButton { state : 'accent-f10pt' } }
        Component { id : button_alt;  ZButton { state : 'transparent-t2-f10pt' } }
        Component { id : background; Rectangle {
                        id : rect;
                        color : 'gray'
                        Component.onCompleted: {
                            if(!ZAnimator.animationExists('blinky'))
                                ZAnimator.createColorAnimation("blinky",["gray", 'lightgray'])

                            var ani = ZAnimator.getAnimationRunner(rect)
                            ani.add('blinky','color',60000,Animation.Infinite).start();
            //                console.log("STARTED")
                        }
                    } }
    }





//    Column {
//        id : btns
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin : 15
//        Button {
//            text : "Add"
//            onClicked :  {
//                var p = person();
//                p.id = "10";

//                console.time('RA push')
//                arr.push(p);
//                console.timeEnd('RA push')

////                console.time('Controller')
////                console.log(JSON.stringify(p,null,2))
//                controller.addModel('herp', p);
////                console.timeEnd('Controller')
//                console.log(arr.length, controller.getModel('herp').count)
//            }
//        }
//        Button {
//            text : "Remove"
//            onClicked: {
//                console.log("REM DIS IDX", 0)
//                arr.remove(0);
//            }
//        }
//        Button {
//            text : "Change"
//            onClicked: arr[Math.floor(Math.random() * arr.length)].firstname = Chance.first();
//        }
//        Button {
//            text : "ChangeHP"
//            onClicked: arr[Math.floor(Math.random() * arr.length)].stats.hp++;
//        }
//        Button {
//            text : "ChangeKid"
//            onClicked: {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                var randIdxKidLen = arr[randIdx].children.length;
//                var kidRandIdx = Math.floor(Math.random() * randIdxKidLen)
//                arr[randIdx].children[kidRandIdx] = Chance.first();
////                console.log(JSON.stringify(arr[randIdx].children))
//            }
//        }
//        Button {
//            text : "addKid"
//            onClicked : {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                arr[randIdx].children.push(Chance.first())
//            }
//        }
//        Button {
//            text : "removeKid"
//            onClicked : {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                var randIdxKidLen = arr[randIdx].children.length;
//                var kidRandIdx = Math.floor(Math.random() * randIdxKidLen)
//                arr[randIdx].children.remove(kidRandIdx);
//            }
//        }
//        Button {
//            text : "remove firstname"
//            onClicked : {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                var id = arr[randIdx].id
//                arr.del(id + '/firstname');
//            }
//        }
//        Button {
//            text : "remove stats"
//            onClicked : {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                var id = arr[randIdx].id
//                arr.del(id + '/stats');
//            }
//        }
//        Button {
//            text : "add stats"
//            onClicked : {
//                var randIdx = Math.floor(Math.random() * arr.length)
//                var id = arr[randIdx].id
//                arr.set(id + '/stats', {hp:999,mp:999});
//            }
//        }



//    }
//    ListView {
//        id : lv
//        anchors.centerIn: parent
//        width : parent.width/2
//        height : parent.height
//        model : vm
//        delegate : Item {
//            property var m : model;
//            property var kids : m ? vm.getEmbedded(m.path + "/children") : null;
//            width  : ListView.view.width;
//            height : ListView.view.height * 0.1;

//            ZText {
//                width : parent.width
//                height : parent.height * 0.5
//                state : 'f1-success-b1'
//                property var hp : Lodash.has(parent,"m.value.stats.hp") ? Lodash.get(parent,"m.value.stats.hp") : "??"
//                property var mp : Lodash.has(parent,"m.value.stats.mp") ? Lodash.get(parent,"m.value.stats.mp") : "??"
//                text : {
//                    if(!parent || !parent.m)
//                        return "";
//                    return parent.m.value.id + "\t" + parent.m.value.firstname + "\t"+ hp + "\t" + mp;
//                }
//            }

//            ListView {
//                id : delLV
//                orientation: ListView.Horizontal
//                model : parent.kids
//                anchors.bottom: parent.bottom
//                width : parent.width
//                height : parent.height * 0.5
//                delegate: ZText {
//                    property var m : model
//                    text   : m ? m.value : ""
//                    width  : delLV.width/3
//                    height : delLV.height
//                    state  : "danger-f2"
//                }
//                ZText {
//                    anchors.right : parent.left
//                    text : delLV.count
//                    height : delLV.height
//                    width : height
//                }
//            }

//        }
//    }
//    ViewModel {
//        id : vm
//        sourceModel: arr;
//        properties: ['firstname','stats','children']
//    }
//    ZController {
//        id : controller
//    }









}
