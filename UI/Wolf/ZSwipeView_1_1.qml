import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Zabaat.Misc.Global 1.0

/*  USAGE

headerObj: either pass in your own, or leave alone to get the normal fancy header object

    ZSwipeView{

        width : 100
        height : 210

        Item1{

        }

        WRect{

        }
    }

    IF YOU PASS A CUSTOM HEADER COMPONENT, MAKE SURE IT HAS TEH FOLLOWING PROPERTIES
        property bool imADelegate : true
        property int  _index      : index
        property var _ptr : ptr
*/



//TODO, INVESTIGATE destroy() of objects! Otherwise this is pretty solid.
Item {
  id: rootObj
  property bool   isDesktopPlatform : Qt.platform.os === "windows" ||  Qt.platform.os === "linux" || Qt.platform.os === "osx"
  property string currentPageTitle  : ''
  property bool   showHeaders       : true
  property var    headerObj         : defaultHeader
  property var  headerPtr         : headerLoad && headerLoad.item ? headerLoad.item : null
  property bool   resizeToFit       : true  //global property across delegates. Can be overrided by same property name inside an item
  property bool   center            : true  //global property across delegates. Can be overrided by same property name inside an item
  property alias  headerProperties  : hp
  property alias  interactive       : screensListView.interactive
  property var    visibilityFunctions : ({})
  property alias  currentIndex        : screensListView.currentIndex
  property alias  moveSpeed           : screensListView.highlightMoveVelocity
  property alias  numTabs             : screensListView.count
  property bool haveAddBtn            : false
  property alias  screens             : screensListView

  property int   newTabAddedBehavior  : 0   //0 = don't move currentIndex
                                            //1 = move to lastest
                                            //2 = move to first entry


  signal addBtnClicked()

  clip : true
  onChildrenChanged: privates.kidnap()      //the bread and butter of the ease of this swiper. Puts children into screensListView

  function moveToTab(indexOrTitle){
      var elem = privates.getElemAt(indexOrTitle)
      if(elem && elem.visible)
          screensListView.currentIndex = elem._index
  }
  function changeVisibility(indexOrTitle, visibility){
      var elem = privates.getElemAt(indexOrTitle)
      if(elem){
          elem.visible = visibility
          if(!visibility && elem._index === screensListView.currentIndex)
              privates.moveToFirstUnhiddenTab()
      }
  }
  function nextTab(){
    if(currentIndex >= screensListView.count - 1)
        return

    for(var i = currentIndex + 1; i < screensListView.count; i++){
        var elem = privates.getElemAt(i)
        if(elem.visible){
            currentIndex = i
            return
        }
    }

  }
  function prevTab(){
    if(currentIndex <= 0)
        return

    for(var i = currentIndex - 1; i >= 0; i--){
        var elem = privates.getElemAt(i)
        if(elem.visible){
            currentIndex = i
            return
        }
    }

  }
  function getTabItem(indexOrTitle){
      var del = privates.getElemAt(indexOrTitle)
      if(del && del._ptr)
          return del._ptr
  }
  function getAllTabItems(){
      var arr = []
      for(var i = 0; i < screensListView.count; i++){
          var del = privates.getElemAt(i)
          if(del && del._ptr)
              arr.push(del._ptr)
      }
      return arr
  }
  function removeTab(indexOrTitle){
      var elem = privates.getElemAt(indexOrTitle)
      if(elem){
          var ind = elem._index
          if(elem._ptr){
//            console.log('KILLING PTR, whose die signal will kill its parent tab!')
            elem._ptr.destroy()
            elem._ptr = null
          }
      }
  }
  function renameTab(indexOrTitle, newName){
      var elem   = privates.getElemAt(indexOrTitle)


      if(elem && elem._ptr){
          elem._ptr.title = newName

      }
  }

  Column{
      anchors.fill: parent
      property bool dontkillme : true

      Item{
          width                 : rootObj.width
          height                : headerProperties.height
          Loader{
              id                    : headerLoad
              sourceComponent       : headerObj
              anchors.fill: parent
          }
          ZButton{
              id : addBtn
              width  : height
              height : parent.height * 2/3
              x : headerLoad.item ? headerLoad.item.contentWidth : 0
              text : ""
              icon: "\uf067"
              y : parent.height/2 - height/2
              visible : haveAddBtn
              onBtnClicked : addBtnClicked()
          }
      }
      ListView {
        id: screensListView
        width  : rootObj.width
        height : rootObj.height - headerLoad.height
        orientation:              ListView.Horizontal
        snapMode:                 ListView.SnapOneItem
        highlightRangeMode:       ListView.StrictlyEnforceRange
//        currentIndex         : 0
        interactive          : true
        highlightMoveVelocity: count * width/2
        clip                 : rootObj.clip
        model                : ListModel{ id : lm }
        cacheBuffer          : width * 255 > 0 ? width * 255 : 999999999
        onCurrentItemChanged : {
          if (isDesktopPlatform && currentItem !== null && typeof currentItem.selected !== 'undefined')
            currentItem.selected()
        }
        delegate: Item{
            id : kidnappingDelegate
            property bool imADelegate : true
            property int  _index      : index
            property var  _ptr        : ptr
            property string _title    : title

            width  : screensListView.width
            height : screensListView.height
            visible: visibilityFunctions && visibilityFunctions[_title] ? visibilityFunctions[_title]() && rootObj.visible : rootObj.visible
//            onVisibleChanged: if(!visible && screensListView.currentIndex === _index)
//                                 privates.moveToFirstUnhiddenTab()

            Component.onCompleted: {
                if(_ptr){
                    _ptr.parent = kidnappingDelegate

                    var doResize = _ptr.hasOwnProperty('resizeToFit') ? _ptr.resizeToFit : resizeToFit
                    if(doResize)
                    {
                        _ptr.width  = Qt.binding(function() { return kidnappingDelegate.width}  )
                        _ptr.height = Qt.binding(function() { return kidnappingDelegate.height} )
                    }

                    var doCenter = _ptr.hasOwnProperty('center') ? _ptr.center : center
                    if(doCenter) {
//                        console.log("CENTERING", _ptr)
                        _ptr.anchors.centerIn  = kidnappingDelegate
                    }

                    //our ZTypes use this
                    if(typeof _ptr.isDying !== 'undefined')                _ptr.isDying.connect(function()               { lm.remove(_index) })
                    else                                                   _ptr.Component.destruction.connect(function() { lm.remove(_index) })

                    //remove from queue
                    delete privates.kQueue[_ptr.toString()]


                    if(!visible && privates.kQueue == {} )
                        privates.moveToFirstUnhiddenTab()
                }
            }
        }

        function getDelegateInstanceAt(index){
            for(var i = 0; i < screensListView.contentItem.children.length; i++){
                var child = screensListView.contentItem.children[i]
                if(child.imADelegate && child._index === index)
                    return child
            }
            return null
        }



      }
  }
  Component{
      id:defaultHeader
      ListView {
        id: tabView
        property bool dontkillme

        width           : rootObj.width
        height          : hp.height

        anchors.horizontalCenter: parent.horizontalCenter
        orientation             : ListView.Horizontal
        boundsBehavior          : Flickable.StopAtBounds
        model                   : screensListView.model
        currentIndex            : screensListView.currentIndex
        onCurrentItemChanged: currentPageTitle = currentItem._ptr ? currentItem._ptr.title : ""


        clip : true
        visible: rootObj && showHeaders ? true : false
        delegate: Item {

          property bool imADelegate : true
          property int  _index      : index
          property var _ptr : ptr

          width  : visible ? headerLabel.width + tabView.height : 0
          height : headerProperties.height
          visible : privates && privates.getElemAt && privates.getElemAt(_index) ? privates.getElemAt(_index).visible : true


          Rectangle{
              anchors.fill: parent
              radius      : headerProperties.radius
              border.width: headerProperties.border.width
              border.color: headerProperties.border.color
              color       : headerProperties.color
          }
          Text {
            id: headerLabel
            anchors.centerIn: parent
            text: _ptr && _ptr.title ? _ptr.title : title != null && typeof title !== 'undefined' ? title : "Dying"
            font.pixelSize      :  tabView.height * 0.3
            font.capitalization : headerProperties.font.capitalization
            color               : headerProperties.font.color
            font.family         : headerProperties.font.family
          }
          Rectangle {//divider
            visible: index !== 0 && headerProperties.divider.visible
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.4
            color: headerProperties.divider.color
          }
          Rectangle {//divider
            visible: index !== tabView.count - 1 && headerProperties.divider.visible
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.4
            color:  headerProperties.divider.color
          }
          Rectangle {//highlightcolor
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
            onClicked: screensListView.currentIndex = index
          }
        }
        highlightFollowsCurrentItem: false
        highlight: Item {
          x: tabView.currentItem.x
          z : tabView.count + 1
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
            color: headerProperties.bar.color
            visible : headerProperties.bar.visible
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: stripRectangle.height
            color: Qt.darker(highlightBarTop.color,2)
            visible : headerProperties.bar.visible
          }
        }

        Rectangle {
          id: stripRectangle
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: parent.height * 0.05
          z: -1
          color   : headerProperties.stripRectangle.color
          visible : headerProperties.stripRectangle.visible
        }
      }
  }
  QtObject{
      id : privates
      property bool dontkillme : true
      property var  kQueue     : ({})   //the kidnap Queue. This is used to ensure that we don't try to create new instances of child in the listmodel
      function kidnap(){    //creates a new delegate in the list and then shoves the new child into it
          var childrenToReparent = []
          for(var i = 0; i < rootObj.children.length; i++){
              var child = rootObj.children[i]
              if(!child.dontkillme)
                  childrenToReparent.push(child)
          }

          for(i = 0; i < childrenToReparent.length; i++){
              child = childrenToReparent[i]
              var title  = child.hasOwnProperty('title')  ? child.title  : lm.count.toString()

              if(typeof kQueue[child.toString()] === 'undefined'){
                  lm.append({ptr : child, title : title })
                  kQueue[child.toString()] = true
              }
          }

//          screensListView.currentIndex = 0
      }

      //USED IN hp for styling the header if we use the default one
      //      headerProperties.font.family      = ZGlobal.style.text.heading1
      //      headerProperties.border.width     = 1
      //      headerProperties.font.color       = 'white'
      //      headerProperties.bar.color        = 'white'
      //      headerProperties.divider.visible  = false
      //      headerProperties.height           = 30

      function getElemAt(indexOrTitle){
          if(isNaN(indexOrTitle)){
              for(var i = 0; i < screensListView.count; i++){
                  var elem = screensListView.getDelegateInstanceAt(i)
                  if(elem && elem._title === indexOrTitle)
                      return elem
              }
          }
          else{
              elem = screensListView.getDelegateInstanceAt(indexOrTitle)
              if(elem)
                  return elem
          }
          return null
      }
      function getHeaderAt(indexOrTitle){
          if(headerLoad && headerLoad.item && headerLoad.item.contentItem)
          {
              if(isNaN(indexOrTitle)){
                  for(var i = 0; i < headerLoad.item.contentItem.children.length; i++){
                      var child = headerLoad.item.contentItem.children[i]
                      if(child.imADelegate && child._ptr && child._ptr.title === indexOrTitle)
                          return child
                  }
              }
              else{
                  for(i = 0; i < headerLoad.item.contentItem.children.length; i++){
                      child = headerLoad.item.contentItem.children[i]
                      if(child.imADelegate && child._index === indexOrTitle)
                          return child
                  }
              }
          }
          return null
      }
      function moveToFirstUnhiddenTab(){
          for(var i = 0; i < screensListView.count; i++){
              var elem = screensListView.getDelegateInstanceAt(i)
              if(elem && elem.visible){
//                  console.log(elem._title, 'is visible')
                  screensListView.currentIndex = i
                  return
              }
          }
      }

      property QtObject _bar: QtObject{
          id : ba
          property color color  : ZGlobal.style.accent
          property bool  visible : true
      }
      property QtObject _font:QtObject{
          id : fo
          property string  family          : ZGlobal.style.text.heading1
          property color   color           : ZGlobal.style.text.color1
          property int     capitalization  : Font.AllUppercase
      }
      property QtObject _sr:QtObject{
          id : sr
          property color color   : 'lightgray'
          property bool  visible : true
      }
      property QtObject _bor:QtObject{
          id : bor
          property color color       : 'black'
          property int   width       : 1
      }
      property QtObject _hp:QtObject{
          id : div
          property color color : 'lightGray'
          property bool visible : false
      }

  }
  QtObject {
      id : hp
      property int  height             : 30
      property bool dontkillme         : true
      property int radius              : 0
      property color color             : 'transparent'
      property alias bar               : ba
      property alias font              : fo
      property alias border            : bor
      property alias stripRectangle    : sr
      property alias divider           : div
  }
  Item{
      id : killingGrounds
      property bool dontkillme : true
      visible : false
  }



}
