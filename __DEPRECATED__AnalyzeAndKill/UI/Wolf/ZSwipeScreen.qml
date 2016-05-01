import QtQuick 2.4

/* USAGE

Make this a base element of a page or component, add components as necessary - the parent takes care of it


import QtQuick 2.4

ZSwipeScreen{

    anchors.centerIn: parent

        Text {
            id:text1
            anchors.bottom: scoreDisplay.bottom
            font.pixelSize          : 24
            font.family             : Style.defaultFont
            anchors.horizontalCenter: parent.horizontalCenter
            text                    : collectiblesThisRun ? Globals.settings.username+ " avoided " + collectiblesThisRun.score + " bolts! I deem thee : " + getScoreTitle(collectiblesThisRun.score) : ""
            visible                 : collectiblesThisRun != "N/A"
            Component.onCompleted:  if (collectiblesThisRun !="N/A") coinSoundTimer.start()
        }

        ScoreDisplay{
            scale:.9
            id: scoreDisplay
//            anchors.top:text1.bottom
//            height:parent.height*
            anchors.centerIn: parent
            //newScoreObj not needed if you use the helper function on gameOverScreen
    //        newScoreObj: __newMoneyObj  //leave null until you've calculated any changes to the things that you need to do
            model: moneyThisRun
        }

        Timer{
            id:coinSoundTimer
            running:false
            interval:2000
            onTriggered: Globals.soundManagerObj.playSound("coins",1.0)
        }
}


*/


Item {
  property bool isFirstScreen: false
  property bool isLastScreen: false
  signal selected()
}
