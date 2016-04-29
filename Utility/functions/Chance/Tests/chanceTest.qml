import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Item {
    id : rootObject
    Text {
        text : "seed " + Chance.seed
        anchors.right: parent.right
    }
    property var cNum : null

    Grid {
        Button {
            text : cNum === null ? "Store" : "Unstore"
            onClicked: {
                if(cNum === null)
                    cNum = Chance.storeChance(12345)
                else {
                    Chance.unstoreChance(cNum)
                    cNum = null;
                }
            }
        }


        Button { text : "bool"     ;  onClicked: console.log(Chance[text](null, { id: cNum })               )}
        Button { text : "character";  onClicked: console.log(Chance[text](null, { id: cNum })               )}
        Button { text : "floating" ;  onClicked: console.log(Chance[text](null, { id: cNum })               )}
        Button { text : "integer"  ;  onClicked: console.log(Chance[text](null, { id: cNum })               )}
        Button { text : "natural"  ;  onClicked: console.log(Chance[text](null, { id: cNum })               )}
        Button { text : "string"   ;  onClicked: console.log(Chance[text]({pool:'red'} , { id: cNum })      )}


        Button { text : "paragraph" ;  onClicked: console.log(Chance[text](null, { id: cNum })      )}
        Button { text : "sentence"  ;  onClicked: console.log(Chance[text](null, { id: cNum })      )}
        Button { text : "syllable"  ;  onClicked: console.log(Chance[text](null, { id: cNum })      )}
        Button { text : "word"      ;  onClicked: console.log(Chance[text]({syllables: 3}, { id: cNum })      )}

        Button { text : "state"          ;  onClicked: console.log(Chance[text](null, { id: cNum })      )}
        Button { text : "5 states"       ;  onClicked: console.log(Chance.n("state",5))    }
        Button { text : "5 Unique states";  onClicked: console.log(Chance.unique("state",5))    }

    }



}
