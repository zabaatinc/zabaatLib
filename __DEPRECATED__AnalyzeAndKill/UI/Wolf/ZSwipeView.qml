import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

/*  USAGE

readyToRender: to true when you are ready for the loaders to load their content in case you need them to init after other things are done
headerObj: either pass in your own, or leave alone to get the normal fancy header object

    ZSwipeView{
        id:swipe
        anchors.top:parent.top
        width:parent.width
        height:parent.height*.8
        readyToRender: false
        model:ListModel{
            ListElement{
                title:'Current Game'
                source: "../gameoverMoney.qml"
            }
            ListElement{
                title:'Your High Scores'
                source: "../gameoverLocals.qml"
                alwaysActive: true
            }
            ListElement{
                title:'Global High Scores'
                source: "../gameoverGlobal.qml"
                alwaysActive: true
            }
        }
    }

    ZSwipeView{

        width : 100
        height : 210

        Item1{

        }

        WRect{

        }

        delegate : Item{
            width : 100
            height : 210
        }



    }

*/





Item {
  id: rootObj
  property var model
  property bool isDesktopPlatform: Qt.platform.os === "windows" ||
                                   Qt.platform.os === "linux" ||
                                   Qt.platform.os === "osx"
  property string currentPageTitle: ''
  property bool showHeaders: true
  property var headerObj : defaultHeader
  property bool readyToRender : false // hold your horses you stupid thing
  property var rootObjectPtr : null

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Loader{
        id:headerLoad
        sourceComponent:headerObj
        height: item.height
        Layout.fillWidth: true
        Layout.preferredHeight: 18 * Screen.logicalPixelDensity
    }

    ListView {
      id: screensListView
      y:headerLoad.height
      Layout.fillWidth: true
      Layout.fillHeight: true
      orientation:              ListView.Horizontal
      snapMode:                 ListView.SnapOneItem
      highlightRangeMode:       ListView.StrictlyEnforceRange
      highlightMoveVelocity:    2000
      clip:                     true
      model:                    rootObj.model
      onCurrentItemChanged: {
        if (isDesktopPlatform && currentItem.item != null)
          currentItem.item.selected()
      }
      delegate: Loader {
        width: screensListView.width
        height: screensListView.height
        source: model.source ? model.source : ""
        active: alwaysActive === true || rootObj.readyToRender ? true : false
        sourceComponent: model.sourceComponent ? model.sourceComponent : null
        Component.onCompleted: {
          Object.defineProperty(item, 'rootObjectPtr', rootObj.rootObjectPtr)    //make this point to the rootObject
          item.isFirstScreen = (index === 0)
          item.isLastScreen = (index === screensListView.count - 1)
        }
      }
    }
  }



  Component{
      id:defaultHeader
      ListView {
        id: tabView
        Layout.fillWidth: true
        Layout.preferredHeight: 16 * Screen.logicalPixelDensity
        anchors.horizontalCenter: parent.horizontalCenter
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: rootObj.model
        currentIndex: screensListView.currentIndex
        visible: showHeaders
        delegate: Item {
          width: headerLabel.width + tabView.height * 0.4
          anchors.top: parent.top
          anchors.bottom: parent.bottom

          Text {
            id: headerLabel
            anchors.centerIn: parent
            text: model.title
            font.pixelSize: tabView.height * 0.3
            font.capitalization: Font.AllUppercase
          }

          Rectangle {
            visible: index !== 0
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.4
            color: "lightgray"
          }

          Rectangle {
            visible: index !== tabView.count - 1
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.4
            color: "lightgray"
          }

          Rectangle {
            anchors.fill: parent
            opacity: (headerMouseArea.pressed) ? 0.5 : 0
            color: "#2440F2"

            Behavior on opacity {
              NumberAnimation {
                duration: 333
              }
            }
          }

          MouseArea {
            id: headerMouseArea
            anchors.fill: parent
            onClicked: {
                screensListView.currentIndex = index
            }
          }
        }
        highlightFollowsCurrentItem: false
        highlight: Item {
          x: tabView.currentItem.x
          width: tabView.currentItem.width
          height: stripRectangle.height * 3
          anchors.bottom: parent.bottom

          Behavior on x {
            NumberAnimation {
              duration: 300
            }
          }

          Behavior on width {
            NumberAnimation {
              duration: 300
            }
          }

          Rectangle {
            id:highlightBarTop
            anchors.left: parent.left
            anchors.right: parent.right
            height: stripRectangle.height * 2
            color: "#4880F2"//"#80c342"
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: stripRectangle.height
            color: Qt.darker(highlightBarTop.color,2)
          }
        }

        Rectangle {
          id: stripRectangle
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: parent.height * 0.05
          z: -1
          color: "lightgray"
        }
      }
  }

}
