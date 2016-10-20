import QtQuick 2.5
import Zabaat.Utility.FileIO 1.0
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
Item {
    id : rootObject
    property string saveLocation : paths.data
    Component.onCompleted : logic.init();


    Item {
        id : logic
        ZPaths { id : paths }
        ZFileOperations { id : fileIO }
        property var map : ({})
        property int mapCount : 0

        function init(){
            var file = fileIO.readFile(saveLocation + "/emailCollection.csv");
            load(file);
        }

        function load(file) {
            map = {}
            mapCount = 0;
            if(file) {
                var lines = Lodash.compact(file.split("\n"));
                Lodash.each(lines, function(line) {
                    var data = Lodash.compact(line.split(','));
                    if(data.length > 0) {
                        var email = data[0]
                        var first = data[1] ? data[1] : "N/A"
                        var last  = data[2] ? data[2] : "N/A"
                        map[email] = { first : first, last : last }
                        mapCount++
                    }
                })
            }
        }

        function add(email, first, last){
            email = email.toLowerCase();
            if(map[email]) {
                Toasts.snackbar("Updated " + email , { stateText : 'f12pt-tleft-t2' })
            }
            else {
                mapCount++
            }
            map[email] = { first : first, last : last }
            save();
        }

        function save(){
            var str = ""
            Lodash.each(map, function(obj,email) {
                str += email + ',' + obj.first + ',' + obj.last + '\n'
            })
            fileIO.writeFile(saveLocation, 'emailCollection.csv',  str);
        }

        function send(){
            Toasts.dialogWithInput("Send CSV", "Please Enter the e-mail you want the csv sent to", function(email) {
                if(validateEmail(email) !== null) {
                    Toasts.snackbar("Email " + email + " is not valid!", { stateText : 'f12pt-tleft-t2', color : Colors.danger })
                    return send();
                }

                console.log("ACTUAL SNED")
            }, null, { state : 'f14pt-t1-accent' })


        }

        function contains(str, find, instances) {
            var exact = true;
            if(!instances || typeof instances !== 'number') {
                instances = 1;
                exact = false;
            }

            instances = Math.max(instances,1);

            var s = 0, count = 0, lastIdx = 0;
            while(exact || count < instances) {
                lastIdx = str.indexOf(find,lastIdx);
                if(lastIdx !== -1) {
                    lastIdx += find.length;
                    count++;
                }
                else {
                    break;
                }
            }

            return exact ? count === instances :
                           count >=  instances;
        }
        function validateEmail(a) {
            if(!a)
                return "";

            var badVal = "Invalid E-mail"

            if(!logic.contains(a,"@",1))
                return badVal;

            var idx = a.indexOf("@");
            a = a.slice(idx);

            var slices = a.split('.');
            if(slices.length !== 2 || slices[0].length < 1 || slices[1].length < 1)
                return badVal;

            return null;
        }
    }


    Item {
        id : gui
        anchors.fill: parent

        ZText {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: gui.width * 0.025
            state : 'f14pt'
            text : logic.mapCount
        }
        Column {
            anchors.centerIn: parent
            width : gui.width * 0.8
            height : childrenRect.height
            spacing : gui.height * 0.025

            ZTextBox {
                id : txEmail
                width :gui.width * 0.8
                height : gui.height * 0.1
                label : "E-mail"
                anchors.horizontalCenter: parent.horizontalCenter
                state : 'cliplabel'
                validationFunc: logic.validateEmail
            }
            ZTextBox {
                id : txFirst
                width :gui.width * 0.8
                height : gui.height * 0.1
                label : "First"
                anchors.horizontalCenter: parent.horizontalCenter
                state : 'cliplabel'
            }
            ZTextBox {
                id : txLast
                width :gui.width * 0.8
                height : gui.height * 0.1
                label : "Last"
                anchors.horizontalCenter: parent.horizontalCenter
                state : 'cliplabel'
            }
            ZButton {
                width : height * 2.5
                height : gui.height * 0.1
                text : "ok"
                enabled : !txEmail.error && txEmail.text.length > 0 && txFirst.text.length > 0 && txLast.text.length > 0
                anchors.right : parent.right
                onClicked: {
                    logic.add(txEmail.text, txFirst.text, txLast.text);
                    txEmail.text = txFirst.text = txLast.text = "";
                }
            }
        }
        ZButton {
            id : sendBtn
            width :height * 2.5
            height : gui.height * 0.1
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5
            text : FAR.send + " Send"
            visible : {
                return txEmail.text.toLowerCase() ===  'iii'  &&
                txFirst.text.toLowerCase() === 'iii' &&
                txLast.text.toLowerCase() === 'iii'
            }
            onClicked: logic.send();
        }
    }



}
