import Zabaat.Material 1.0
import QtQuick 2.4
import QtGraphicalEffects 1.0
//Default button, flat style
ZSkin {
    id : rootObject

    //aliases so stateHandler can see it
    property alias graphical     : graphical
    property alias textContainer : textContainer
    property alias font          : text.font

    color           : Colors.standard
    focus           : true
    border.color    : graphical.borderColor
    anchors.centerIn: parent
    onLogicChanged  : if(logic)  logic.containsMouse = Qt.binding(function() { return inkArea.containsMouse })
    onStateChanged  : {
        graphical.state = "reload"
        graphical.state = ""
    }
    onActiveFocusChanged: {
//        console.log(activeFocus)
        if(activeFocus && graphical.state !== "press")  graphical.state = "focus"
        else if(graphical.state === "focus")            graphical.state = ""
    }


    ZInkArea {
        id : inkArea
        anchors.fill: parent
        color   : graphical.inkColor
        enabled : logic ? true : false;
        allowDoubleClicks: logic ? logic.allowDoubleClicks : false
        acceptedButtons: Qt.AllButtons
        onPressed:  if(logic)       logic.pressed(logic, x,y,buttons)
        onClicked:  if(logic)       logic.clicked(logic, x,y,buttons)
        onDoubleClicked : if(logic) logic.doubleClicked(logic, x,y,buttons)
        opacity : graphical.inkOpacity
        onContainsMouseChanged : {
//            if(graphical.state !== 'press')
//                graphical.state = containsMouse ? "focus" : ""
        }
    }
    Item {
        id :  textContainer
        anchors.fill: parent
        clip : true
        Text {
            id : text
            anchors.fill       : parent
            anchors.margins    : parent.height * 1/10
            horizontalAlignment: graphical.text_hAlignment
            verticalAlignment  : graphical.text_vAlignment
            font.family        : logic.font1
            font.pixelSize     : parent.height * 1/4
            text               : logic.text
            color              : Colors.text1
            textFormat         : Text.RichText
        }
    }
    Item {
        id : graphical
        property color fill_Default: Colors.standard
        property color fill_Press  : Colors.accent
        property color fill_Focus  : Colors.info
        property color text_Default: Colors.text1
        property color text_Press  : Colors.text2
        property color text_Focus  : Colors.text2
        property int   text_hAlignment  : Text.AlignHCenter
        property int   text_vAlignment  : Text.AlignVCenter
        property color inkColor    : Colors.getContrastingColor(rootObject.color)
        property color borderColor : Colors.text1
        property real inkOpacity   : 1


        states :[
            State {
                name : ""
                PropertyChanges { target: rootObject; color: graphical.fill_Default }
                PropertyChanges { target: text      ; color: graphical.text_Default }
            },
            State {
                name : "focus"
                PropertyChanges { target: rootObject; color: graphical.fill_Focus   }
                PropertyChanges { target: text      ; color: graphical.text_Focus   }
            },
            State {
                name : "press"
                PropertyChanges { target: rootObject; color: graphical.fill_Press  }
                PropertyChanges { target: text      ; color: graphical.text_Press  }
            } ,
            State { name : "reload" }
        ]
    }


    states : ({
        "default" : { "rootObject": { "border.width" : 0,
                                    "radius"       : 0,
                                    "@width"       : [parent,"width"],
                                    "@height"      : [parent,"height"],
                                    rotation       : 0
                                   } ,
                      "graphical" : {
                           "@fill_Default": [Colors,"standard"],
                           "@text_Default": [Colors,"text1"],
                           "@fill_Press"  : [Colors,"standard"],
                           "@text_Press"  : [Colors,"info"],
                           "@fill_Focus"  : [Colors,"info"],
                           "@text_Focus"  : [Colors,"text2"],
                           "@inkColor"    : [Colors,"accent"],
                           "@borderColor" : [Colors,"text1"],
                           inkOpacity : 1,
                           text_hAlignment : Text.AlignHCenter,
                           text_vAlignment : Text.AlignVCenter
                    },
                    textContainer : { rotation : 0 },
        },
       "diamond" : { rootObject: { "border.width": 1,
                                   "radius": 5,
                                    rotation : 45
                                 },
                     textContainer : { rotation : -45 }
       },
       "circle" : { rootObject: { "border.width": 1,
                                   "@radius": [rootObject,"height", 0.5],
                                   "@width" : [rootObject,"height"],
                                   clip: true
                  }
        },
        "raised" : { rootObject: {  "border.width": 1,
                                    radius: 5,
                   }
        },
        "disabled" : { graphical : {
                           fill_Default: "gray",
                           text_Default: "darkGray",
                           fill_Press  : "gray",
                           text_Press  : "darkGray",
                           fill_Focus  : "gray",
                           text_Focus  : "darkGray",
                           inkColor    : "gray",
                           borderColor : "darkGray"
                      }
       },
        "accent"  : { graphical : {
                            "@fill_Default": [Colors,"accent"],
                            "@text_Default": [Colors,"text2"],
                            "@fill_Press"  : [Colors.darker,"accent"],
                            "@text_Press"  : [Colors,"text2"],
                            "@fill_Focus"  : [Colors,"accent"],
                            "@text_Focus"  : [Colors,"text1"],
                            "@inkColor"    : [Colors,"info"],
                            "@borderColor" : [Colors,"text1"]
                       }
        },
        "info"  : { graphical : {
                            "@fill_Default": [Colors,"info"],
                            "@text_Default": [Colors,"text2"],
                            "@fill_Press"  : [Colors.darker,"info"],
                            "@text_Press"  : [Colors,"text2"],
                            "@fill_Focus"  : [Colors,"info"],
                            "@text_Focus"  : [Colors,"text1"],
                            "@inkColor"    : [Colors,"info"],
                            "@borderColor" : [Colors,"text1"]
                       }
        },
       "danger"  : { graphical : {
                           "@fill_Default": [Colors,"danger"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"danger"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"danger"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"danger"],
                           "@borderColor" : [Colors,"text1"]
                      }
       },
       "success"  : { graphical : {
                           "@fill_Default": [Colors,"success"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"success"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"success"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"success"],
                           "@borderColor" : [Colors,"text1"]
                     },
        },
        "warning"  : { graphical : {
                            "@fill_Default": [Colors,"warning"],
                            "@text_Default": [Colors,"text2"],
                            "@fill_Press"  : [Colors.darker,"warning"],
                            "@text_Press"  : [Colors,"text2"],
                            "@fill_Focus"  : [Colors,"warning"],
                            "@text_Focus"  : [Colors,"text1"],
                            "@inkColor"    : [Colors.contrasting,"warning"],
                            "@borderColor" : [Colors,"text1"]
                      },
         },
        "ghost"  : {  rootObject : {"border.width" : 2 },
                      graphical : {
                            "fill_Default" : "transparent",
                            "@text_Default": [Colors,"text1"],
                            "@fill_Press"  : [Colors.darker,"success"],
                            "@text_Press"  : [Colors,"text1"],
                            "@fill_Focus"  : [Colors,"success"],
                            "@text_Focus"  : [Colors,"text2"],
                            "@inkColor"    : [Colors,"text1"],
                            "@borderColor" : [Colors,"text1"],
                            inkOpacity : 0.5
                      }
        },
        "transparent"  : {  rootObject : {"border.width" : 0} ,
                            graphical : {
                                "fill_Default": "transparent",
                                "@fill_Press"  : [Colors.darker,"success"],
                                "@fill_Focus"  : [Colors,"success"],
                                "@inkColor"    : [Colors,"text2"],
                                "@borderColor" : [Colors,"text2"],
                                inkOpacity : 0.5
                         }
        },
        "noink"       :  { graphical : { inkOpacity : 0 } },
        "t1"         : { graphical : { "@text_Default": [Colors,"text1"],
                                        "@text_Press"  : [Colors,"text1"],
                                        "@text_Focus"  : [Colors,"text2"],
                                        "@inkColor"    : [Colors,"accent"],
                                        "@borderColor" :[Colors,"text1"] }
        },
        "t1"         : { graphical : { "@text_Default": [Colors,"text1"],
                                       "@text_Press"  : [Colors,"text1"],
                                       "@text_Focus"  : [Colors,"text2"],
                                       "@inkColor"    : [Colors,"accent"],
                                       "@borderColor" : [Colors,"text1"] }
        },

                  //property int   text_hAlignment  : Text.AlignHCenter
                  //property int   text_vAlignment  : Text.AlignVCenter
//        "tcenterh"    : { graphical : { text_hAlignment : Text.AlignHCenter }},
//        "tright"      : { graphical : { text_hAlignment : Text.AlignRight   }},
//        "tleft"       : { graphical : { text_hAlignment : Text.AlignLeft    }},
//        "tcenterv"    : { graphical : { text_vAlignment : Text.AlignVCenter }},
//        "tbottom"     : { graphical : { text_vAlignment : Text.AlignBottom  }},
//        "ttop"        : { graphical : { text_vAlignment : Text.AlignTop     }},
        "tcenter"      : { graphical : { text_hAlignment : Text.AlignHCenter, text_vAlignment : Text.AlignVCenter }},
        "tcenterright" : { graphical : { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignVCenter }},
        "tcenterleft"  : { graphical : { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignVCenter }},
        "ttopright"    : { graphical : { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignTop     }},
        "ttopleft"     : { graphical : { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignTop     }},
        "tbottomright" : { graphical : { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignBottom  }},
        "tbottomleft"  : { graphical : { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignBottom  }},
    })


}
