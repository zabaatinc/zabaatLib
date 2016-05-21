import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Rectangle {
    id : rootObject
    color : 'yellow'
    function prnt(){
        console.log(JSON.stringify.apply(this,arguments));
    }
    function herp(a){ console.log("fn", a)}

    Grid {
        anchors.fill: parent

        Column {
            width : childrenRect.width
            height : childrenRect.height
            LButton {
                text : "ARRAY"
                enabled : false
                fontScl: 2
                colorBg : 'white'
            }
            Grid {
                id : array
                LButton {
                    text : "chunk([1,2,3,4],2)";
                    onClicked: prnt(_.chunk([1,2,3,4],2)   )
                }
                LButton {
                    text : "compact([0, 1, false, 2, '', 3])";
                    onClicked: prnt(_.compact([0, 1, false, 2, '', 3]))
                }
                LButton {
                    text : "concat([1], 2, [3], [[4]] )";
                    onClicked:prnt(_.concat([1], 2, [3], [[4]]     ) );
                }

            }

        }

        Column {
            width : childrenRect.width
            height : childrenRect.height
            LButton {
                text : "FUNCTION"
                enabled : false
                fontScl: 2
                colorBg : 'white'
            }
            Grid {
                id : functions

                LButton {
                    text : "delay(fn, 1000 ms)";
                    onClicked: _.delay(herp  , 1000 , "abc");
                }


            }

        }




    }






}
