import Zabaat.Material 1.0
import QtQuick 2.4
Item {
    id : rootObject
    property var    logic        : null         //the pointer to the parent logic itme
    property string colorTheme   : logic ? logic.colors : "default"
    readonly property point  pos : logic ? Qt.point(logic.x,logic.y) : Qt.point(0,0)
    property bool debug          : false
//    focus                        : false
    property alias color          : rect.color
    property alias border         : rect.border
    property alias radius         : rect.radius

    Rectangle { id: rect ; anchors.fill : parent; color: logic ? Colors.get(logic.colors , "standard") : "white" }

    property string state  : "default"
    property var    states : []

    function log(){
        if(debug)
            console.log.apply(this,arguments)
    }
    function clr(name){
        return Colors.get(colorTheme , name)
    }

    Connections {
        target          : logic ? logic : null
        onStateChanged  : stateChangeOp(logic.state, logic.enabled)
        onEnabledChanged: stateChangeOp(logic.state, logic.enabled)
    }
    onStatesChanged: {
        if(logic && logic.hasOwnProperty('font')) {
            addFontStates()
            stateChangeOp(logic.state, logic.enabled)
        }
    }
    onLogicChanged: {
        if(logic) {
            addBorderStates()
            if(rootObject.hasOwnProperty("font"))
                addFontStates()
            stateChangeOp(logic.state, logic.enabled)
        }
    }

    QtObject {
        id : cache
        property string state  : ""
        property bool   enable : false

        property bool fontsAdded : false
        property bool bordersAdded : false
        property bool ready : rootObject.hasOwnProperty("font") ? fontsAdded && bordersAdded : bordersAdded
        onReadyChanged : if(ready){
                             stateChangeOp(state,enable,true)
                         }

    }

    //Automatically adds borderStates and fontStates if there is a font in the rootLevel Object!!
    //these states are - b1-b10 , f1-f10, fw1-fw10      //fw means font size is dependent on the Width instead of height of the component
    function addBorderStates(){
        states["b1" ] =  { rootObject : { "border.width" : 1  }};
        states["b2" ] =  { rootObject : { "border.width" : 2  }};
        states["b3" ] =  { rootObject : { "border.width" : 3  }};
        states["b4" ] =  { rootObject : { "border.width" : 4  }};
        states["b5" ] =  { rootObject : { "border.width" : 5  }};
        states["b6" ] =  { rootObject : { "border.width" : 6  }};
        states["b7" ] =  { rootObject : { "border.width" : 7  }};
        states["b8" ] =  { rootObject : { "border.width" : 8  }};
        states["b9" ] =  { rootObject : { "border.width" : 9  }};
        states["b10"] =  { rootObject : { "border.width" : 10 }};

        cache.bordersAdded = true;
    }
    function addFontStates(){
        if(states["default"]){
            states["default"].font = { bold : false, italic : false, "@pixelSize":[parent,"height",1/4],
                                       weight:Font.Normal, strikeout : false, underline : false }
        }
        else {
            states["default"] =  { font:  { bold : false, italic : false, "@pixelSize":[parent,"height",1/4],
                                            weight:Font.Normal, strikeout : false, underline : false } }
        }

        states["w1"       ]  = { font : { weight : Font.Thin                    }}
        states["w2"       ]  = { font : { weight : Font.Light                   }}
        states["w3"       ]  = { font : { weight : Font.ExtraLight              }}
        states["w4"       ]  = { font : { weight : Font.Normal                  }}
        states["w5"       ]  = { font : { weight : Font.Medium                  }}
        states["w6"       ]  = { font : { weight : Font.DemiBold                }}
        states["w7"       ]  = { font : { weight : Font.Bold                    }}
        states["w8"       ]  = { font : { weight : Font.ExtraBold               }}
        states["w9"       ]  = { font : { weight : Font.Black                   }}
        states["f1"       ]  = { font : { "@pixelSize" : [parent,"height",1]    }}
        states["f2"       ]  = { font : { "@pixelSize" : [parent,"height",1/2]  }}
        states["f3"       ]  = { font : { "@pixelSize" : [parent,"height",1/3]  }}
        states["f4"       ]  = { font : { "@pixelSize" : [parent,"height",1/4]  }}
        states["f5"       ]  = { font : { "@pixelSize" : [parent,"height",1/5]  }}
        states["f6"       ]  = { font : { "@pixelSize" : [parent,"height",1/6]  }}
        states["f7"       ]  = { font : { "@pixelSize" : [parent,"height",1/7]  }}
        states["f8"       ]  = { font : { "@pixelSize" : [parent,"height",1/8]  }}
        states["f9"       ]  = { font : { "@pixelSize" : [parent,"height",1/9]  }}
        states["f10"      ]  = { font : { "@pixelSize" : [parent,"height",1/10] }}
        states["fw1"      ]  = { font : { "@pixelSize" : [parent,"width",1]     }}
        states["fw2"      ]  = { font : { "@pixelSize" : [parent,"width",1/2]   }}
        states["fw3"      ]  = { font : { "@pixelSize" : [parent,"width",1/3]   }}
        states["fw4"      ]  = { font : { "@pixelSize" : [parent,"width",1/4]   }}
        states["fw5"      ]  = { font : { "@pixelSize" : [parent,"width",1/5]   }}
        states["fw6"      ]  = { font : { "@pixelSize" : [parent,"width",1/6]   }}
        states["fw7"      ]  = { font : { "@pixelSize" : [parent,"width",1/7]   }}
        states["fw8"      ]  = { font : { "@pixelSize" : [parent,"width",1/8]   }}
        states["fw9"      ]  = { font : { "@pixelSize" : [parent,"width",1/9]   }}
        states["fw10"     ]  = { font : { "@pixelSize" : [parent,"width",1/10]  }}
        states["bold"     ]  = { font : { bold      : true                      }}
        states["italic"   ]  = { font : { italic    : true                      }}
        states["underline"]  = { font : { underline : true                      }}
        states["strikeout"]  = { font : { strikeout : true                      }}
        states["caps"]       = { font : { capitalization : Font.AllUppercase  }}
        states["lowercase"]  = { font : { capitalization : Font.AllLowercase  }}
        states["smallcaps"]  = { font : { capitalization : Font.SmallCaps  }}
        states["capitalize"] = { font : { capitalization : Font.Capitalize  }}

        cache.fontsAdded = true;
    }
    function stateChangeOp(state, enabled, force){
        if(!force && state === cache.state && enabled === cache.enable)
            return;


        if(cache.ready) {
            rootObject.enabled = enabled;
            if(!enabled && logic.disableShowsGraphically) {
                ZStateHandler.setState(rootObject, state + "-disabled")
            }
            ZStateHandler.setState(rootObject, state)
        }

        cache.state  = state
        cache.enable = enabled
    }

}
