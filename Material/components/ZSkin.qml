import Zabaat.Material 1.0
import QtQuick 2.4

/*!
   \brief this is the way a ZObject looks. This is the face of the component and is decoupled from anything outside!
   Outside World talks to this by changing the state.

All ZSkins come with these states : \hr

default, disabled, accent, info , warning, danger, ghost, transparent, semitransparent
b1 to b10 , border width
tcenter, tcenterright, tcenterleft, ttopright, ttopleft, tbottomright, tbottomleft : Text alignment
t1 : Colors.text1
t2 : Colors.text2

\hr
If a ZSkin has a property called 'font' in its root, then the following states will be automatically available to it: \hr

default
w1 to w9 : Font.weight (light to black)
font1    : MaterialSettings.font.font1
font2    : MaterialSettings.font.font2
fontfa   : font awesome

f1 to f10 : Ratio to height. f1 being 1:1 and f10 being 1:10
fw1 to fw10 : Ratio to weight : fw1 being 1:1 and fw10 being 1:10

bold
italic
underline
strikeout
caps
lowercase
smallcaps
capitalize

\hr

If a ZSkin has a property called 'knob' in its root, then the following states will be automatically available to it: \hr

noknob : no knob
knob1 - knob10  : scale of the knob (low to high)
spill1 - spill9 : spill of the ink from the knob (low to high)

\hr

*/
Item {
    id : rootObject
    signal skinFuncAdded();
    signal initialized();

    /*! The ZObject that has loaded this ZSkin as its skin \hr */
    property var    logic        : null         //the pointer to the parent logic itme
    onLogicChanged: {
        if(logic) {
            cache.addBorderStates()
            cache.addGraphicalStates()
            if(rootObject.hasOwnProperty("font")) {
                cache.addFontStates()
            }
            if(rootObject.hasOwnProperty("knob"))
                cache.addKnobStates()

            rootObject.stateChangeOp(logic.state, logic.enabled)
        }
    }

    /*! The name of the color theme. \b default: "default" \hr */
    property string colorTheme   : logic ? logic.colors : "default"

    /*! The position of the ZObject parent \hr */
    readonly property point  pos : logic ? Qt.point(logic.x,logic.y) : Qt.point(0,0)

    /*! Determines whether the log function will print messages \hr */
    property bool debug          : false
//    focus                        : false

    /*! The background color. \b default : logic.colors.standard \hr */
    property alias color          : rect.color
    property alias transparency   : rect.opacity

    /*! Alias to border \hr */
    property alias border         : borderRect.border

    /*! The position of the ZObject parent \hr */
    property alias radius         : rect.radius

    /*! This allows the logic section (ZOBject) to call functions inside the skin! It's up to the skin to implement
        the function the logic calls! Will always take two params (name, params). So ZObject can always call
        something like : ZObject.skinFunc("fnName", {herp:derp} )

    */
    property var skinFunc : null
    onSkinFuncChanged: if(typeof skinFunc === 'function') {
//                           console.log("EMITTED SKIN FUNC CHANGE!", rootObject)
                           skinFuncAdded();
                       }



    /*! The container for colors that all ZObjects should use. The colors are the following:  \hr
        fill_Empty       : \b default : "transparent"
        fill_Default     : \b default : Colors.standard
        fill_Press       : \b default : Colors.accent
        fill_Focus       : \b default : Colors.info
        fill_Opacity     : \b default : 1
        text_Default     : \b default : Colors.text1
        text_Press       : \b default : Colors.text2
        text_Focus       : \b default : Colors.text2
        text_hAlignment  : \b default : Text.AlignHCenter
        text_vAlignment  : \b default : Text.AlignVCenter
        inkColor         : \b default : Colors.getContrastingColor(fill_Default
        borderColor      : \b default : Colors.text1
        inkOpacity       : \b default : 1
        disabled1        : \b default : "Gray"
        disabled2        : \b default : "DarkGray"
      \hr
    */
    property alias graphical      : graphical
    readonly property var injectState : cache.injectState
    property string state  : "default"
    property var    states : []
    function log(){
        if(debug)
            console.log.apply({},arguments)
    }
    function clr(name){
        return Colors.get(colorTheme , name)
    }
    /*! The money maker of ZSkin objects. Works sort of like css. Example: state : "warning-t2 \b default : "default" \hr */
    function stateChangeOp(state, enabled, force){
        ss.state = state;
        ss.enabled = enabled;
        ss.force = force? true : false;
        ss.start();
    }
    function stateChangeOpGuts(state,enabled,force){
        if(!force && state === cache.state && enabled === cache.enable)
            return;

        if(state === "" && cache.first)
            return cache.first = false;

        if(cache.ready) {
            rootObject.enabled = enabled;
            if(!enabled && logic.disableShowsGraphically) {
                var dis = state === "" ? "disabled" : "-disabled";
                ZStateHandler.setState(rootObject, state + dis)
            }
            else {
                ZStateHandler.setState(rootObject, state)
            }
        }

        cache.state  = state
        cache.enable = enabled
        if(cache.first){
            cache.first = false;        //tells us that we have init or loaded a different state other than default :D
        }

        if(!cache.initEmitted) {
            initialized();
            cache.initEmitted = true;
        }
    }


    Timer {
        id : ss
        interval : 0
        property string state
        property bool enabled
        property bool force
        onTriggered: stateChangeOpGuts(state,enabled,force);
    }



    Rectangle {
        id: rect ;
        anchors.fill : parent;
        color: Colors.standard
        opacity: graphical.fill_Opacity;
    }
    Rectangle {
        id: borderRect ;
        anchors.fill : parent;
        color: "transparent";
        border.color: graphical.borderColor
        radius : rect.radius
        z : Number.MAX_VALUE
    }
    Connections {
        id : conn
        property bool hasInit : false
        target          : logic ? logic : null
        onStateChanged  : rootObject.stateChangeOp(logic.state, logic.enabled)
        onEnabledChanged: if(rootObject) rootObject.stateChangeOp(logic.state, logic.enabled);

    }
    QtObject {
        id : cache
        property string state  : ""
        property bool   enable : false
        property bool   first  : true
        property bool   initEmitted : false

        property bool fontsAdded   : false
        property bool bordersAdded : false
        property bool graphicalAdded  : false
        property bool knobAdded : false

        property bool ready : {
            var fReady = rootObject.hasOwnProperty("font") ? fontsAdded : true
            var kReady = rootObject.hasOwnProperty("knob") ? knobAdded : true
            return fReady && kReady && graphicalAdded && bordersAdded
        }

        onReadyChanged : if(ready){
                             rootObject.stateChangeOp(state,enable,true)
                         }


        property QtObject graphical : QtObject{ //these things are available in every skin!! so why not merge em?
            id : graphical
            property color fill_Empty       : "transparent"
            property color fill_Default     : Colors.standard
            property color fill_Press       : Colors.accent
            property color fill_Focus       : Colors.info
            property real  fill_Opacity     : 1
            property color text_Default     : Colors.text1
            property color text_Press       : Colors.text2
            property color text_Focus       : Colors.text2
            property int   text_hAlignment  : Text.AlignHCenter
            property int   text_vAlignment  : Text.AlignVCenter
            property color inkColor         : Colors.getContrastingColor(fill_Default)
            property color borderColor      : Colors.text1
            property real  inkOpacity       : 1
            property color disabled1        : Colors.names.gray
            property color disabled2        : Qt.darker(Colors.names.gray)
        }

        function has(obj, key){
            if(key.charAt(0) === "@"){  //check for this and slice1
                return typeof obj[key]          !== 'undefined' ||
                       typeof obj[key.slice(1)] !== 'undefined' ? true : false
            }
            return typeof obj[key]              !== 'undefined' ||
                   typeof obj["@" + key]        !== 'undefined' ? true : false
        }


        function injectState(name, key, stateObject){    //makes sure we don't overwrite an existing state!
            if(states[name]){
                if(has(states[name],key)){  //this key already exists!! don't overwrite special values!
                    var type = typeof stateObject
                    if(type === 'object') {
                        for(var s in stateObject){
    //                        console.log(key, s)
                            if(!has(states[name][key],s) ){
                                //do nothing
                                states[name][key][s] = stateObject[s]
                            }
                        }
                    }
                    else { //is flat object! just assign it!
                        console.log("assigned flat object @" , name + "." + key, "=", stateObject)
                        states[name][key] = stateObject
                    }
                }
                else {
                    states[name][key] = stateObject
                }
            }
            else {
                var obj = {}
                obj[key] = stateObject
                states[name] = obj
            }

        }


        function addBorderStates(){
            cache.injectState("b!"  , "rootObject" , { "border.width" : "!" })

            cache.injectState("rounded" , "rootObject" , { "@radius" : [rootObject,"height",1/10]  });
            cache.injectState("rounded!", "rootObject" , { "@radius" : [rootObject,"height","1/!"] });

            cache.injectState("square"   , "rootObject" , { "radius" : 0   });
            cache.injectState("circle"  , "rootObject" , { "@radius" : [rootObject,"height",1/2]  });

            cache.injectState("bblack"    , "graphical" , { "borderColor"  : Colors.names.black });
            cache.injectState("bgray"     , "graphical" , { "borderColor"  : Colors.names.gray });
            cache.injectState("bwhite"    , "graphical" , { "borderColor"  : Colors.names.white });
            cache.injectState("bdisabled" , "graphical" , { "@borderColor" : [graphical,"disabled1"] });
            cache.injectState("baccent"   , "graphical" , { "@borderColor" : [Colors,"accent"] });
            cache.injectState("bdanger"   , "graphical" , { "@borderColor" : [Colors,"danger"] });
            cache.injectState("bwarning"  , "graphical" , { "@borderColor" : [Colors,"warning"] });
            cache.injectState("bsuccess"  , "graphical" , { "@borderColor" : [Colors,"success"] });
            cache.injectState("binfo"     , "graphical" , { "@borderColor" : [Colors,"info"] });
            cache.injectState("bstandard" , "graphical" , { "@borderColor" : [Colors,"standard"] });
            cache.injectState("bt1"       , "graphical" , { "@borderColor" : [Colors,"text1"] });
            cache.injectState("bt2"       , "graphical" , { "@borderColor" : [Colors,"text2"] });
            cache.injectState("btcontrasting","graphical", { "@borderColor" : function() {return Colors.contrastingTextColor(graphical.fill_Default)}} );

            cache.injectState("br!g!b!"   , "graphical",  { "@borderColor" : function(r,g,b)   { return Qt.rgba(r/255,g/255,b/255)       } });
            cache.injectState("br!g!b!a!" , "graphical",  { "@borderColor" : function(r,g,b,a) { return Qt.rgba(r/255,g/255,b/255,a/255) } });


            cache.bordersAdded = true;
        }
        function addFontStates(){

            cache.injectState("default","font", { bold : false, italic : false, "@pixelSize":["@parent","height",1/4],
                                                  weight:Font.Normal, strikeout : false, underline : false ,
                                                 "@family" : [Fonts,"font1"]

                                                  })

            cache.injectState("w1"         , "font" , { weight : Font.Thin                    })
            cache.injectState("w2"         , "font" , { weight : Font.Light                   })
            cache.injectState("w3"         , "font" , { weight : Font.ExtraLight              })
            cache.injectState("w4"         , "font" , { weight : Font.Normal                  })
            cache.injectState("w5"         , "font" , { weight : Font.Medium                  })
            cache.injectState("w6"         , "font" , { weight : Font.DemiBold                })
            cache.injectState("w7"         , "font" , { weight : Font.Bold                    })
            cache.injectState("w8"         , "font" , { weight : Font.ExtraBold               })
            cache.injectState("w9"         , "font" , { weight : Font.Black                   })

            cache.injectState("font1"      , "font" , {"@family" : [Fonts,"font1"]}    )
            cache.injectState("font2"      , "font" , {"@family" : [Fonts,"font2"]}    )
            cache.injectState("fontfa"     , "font" , {"family": "FontAwesome"     }   )
            cache.injectState("fontrosa"   , "font" , {"family": "rosacons"        }   )
            cache.injectState("f!px"       , "font" , { "pixelSize" : "!" } )   //px is pixelSize
            cache.injectState("f!pt"       , "font" , { "@pixelSize" : Units.pt })  //our version of pointSize m device independent, hurr hurr
//            cache.injectState("!test!test!" , "derp" , { "@herp"      : function(a,b,c) { console.log("TEST TEST FUNC YAY", a,b,c)      } })


            cache.injectState("f!", "font" , { "@pixelSize": ["@parent","height","1/!"]})
//            if(objectName.toLowerCase().indexOf("zslider") !== -1)
//                console.log("INJECTED!!")

            cache.injectState("fw!", "font" , { "@pixelSize": ["@parent","width","1/!"]})
            cache.injectState("bold"       , "font" , { bold      : true                      })
            cache.injectState("italic"     , "font" , { italic    : true                      })
            cache.injectState("underline"  , "font" , { underline : true                      })
            cache.injectState("strikeout"  , "font" , { strikeout : true                      })
            cache.injectState("caps"       , "font" , { capitalization : Font.AllUppercase  }  )
            cache.injectState("lowercase"  , "font" , { capitalization : Font.AllLowercase  }  )
            cache.injectState("smallcaps"  , "font" , { capitalization : Font.SmallCaps  }     )
            cache.injectState("capitalize" , "font" , { capitalization : Font.Capitalize  }    )

            cache.fontsAdded = true;
        }
        function addGraphicalStates() {
            cache.injectState("black","graphical", {
               "fill_Empty"      : "transparent",
               "fill_Default"    : Colors.names.black,
               "text_Default"    : Colors.names.white,
               "borderColor"     : Colors.names.white,
               "inkColor"        : Colors.names.gray,
               "fill_Press"      : Colors.names.black,
               "fill_Focus"      : Colors.names.darkgray,
               "text_Press"      : Colors.names.lightgray,
               "text_Focus"      : Colors.names.lightgray,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "inkOpacity"      : 1,
               "fill_Opacity"    : 1
            })

            cache.injectState("white","graphical", {
               "fill_Empty"      : "transparent",
               "fill_Default"   : Colors.names.white,
               "text_Default"   : Colors.names.black,
               "borderColor"    : Colors.names.black,
               "inkColor"       : Colors.names.gray,
               "fill_Press"     : Colors.names.gray,
               "fill_Focus"     : Colors.names.lightgray,
               "text_Press"     : Colors.names.darkgray,
               "text_Focus"     : Colors.names.darkgray,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "inkOpacity"      : 1,
               "fill_Opacity"    : 1
            })

            cache.injectState("gray","graphical", {
               "fill_Empty"      : "transparent",
               "fill_Default"    : Colors.names.gray,
               "text_Default"    : Colors.names.white,
               "borderColor"     : Colors.names.white,
               "inkColor"        : Colors.names.darkgray,
               "fill_Press"      : Colors.names.darkgray,
               "fill_Focus"      : Colors.names.lightgray,
               "text_Press"      : Colors.names.white,
               "text_Focus"      : Colors.names.white,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "inkOpacity"      : 1,
               "fill_Opacity"    : 1
            })


            cache.injectState("standard","graphical", {
               "fill_Empty"      : "transparent",
               "@fill_Default"   : [Colors,"standard"],
               "@text_Default"   : [Colors,"text1"],
               "@fill_Press"     : [Colors,"accent"],
               "@text_Press"     : [Colors,"text2"],
               "@fill_Focus"     : [Colors.lighter, "accent"],
               "@text_Focus"     : [Colors,"text2"],
               "@inkColor"       : [Colors,"accent"],
               "@borderColor"    : [Colors,"text1"],
               "inkOpacity"      : 1,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "fill_Opacity"    : 1
            })

            cache.injectState("default","graphical", {
               "fill_Empty"      : "transparent",
               "@fill_Default"   : [Colors,"standard"],
               "@text_Default"   : [Colors,"text1"],
               "@fill_Press"     : [Colors,"accent"],
               "@text_Press"     : [Colors,"text2"],
               "@fill_Focus"     : [Colors.lighter, "accent"],
               "@text_Focus"     : [Colors,"text2"],
               "@inkColor"       : [Colors,"accent"],
               "@borderColor"    : [Colors,"text1"],
               "inkOpacity"      : 1,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "fill_Opacity"    : 1
            })

            cache.injectState("text1","graphical", {
               "fill_Empty"      : "transparent",
               "@fill_Default"   : [Colors,"text1"],
               "@text_Default"   : [Colors,"text2"],
               "@fill_Press"     : [Colors,"accent"],
               "@text_Press"     : [Colors,"text2"],
               "@fill_Focus"     : [Colors.lighter, "accent"],
               "@text_Focus"     : [Colors,"text2"],
               "@inkColor"       : [Colors,"accent"],
               "@borderColor"    : [Colors,"text1"],
               "inkOpacity"      : 1,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "fill_Opacity"    : 1
            })

            cache.injectState("text2","graphical", {
               "fill_Empty"      : "transparent",
               "@fill_Default"   : [Colors,"text2"],
               "@text_Default"   : [Colors,"text1"],
               "@fill_Press"     : [Colors,"accent"],
               "@text_Press"     : [Colors,"text1"],
               "@fill_Focus"     : [Colors.lighter, "accent"],
               "@text_Focus"     : [Colors,"text1"],
               "@inkColor"       : [Colors,"accent"],
               "@borderColor"    : [Colors,"text2"],
               "inkOpacity"      : 1,
               "text_hAlignment" : Text.AlignHCenter,
               "text_vAlignment" : Text.AlignVCenter,
               "fill_Opacity"    : 1
            })



            cache.injectState("disabled","graphical", {
                 "@fill_Default": [graphical, "disabled1"],
                 "@text_Default": [graphical, "disabled2"],
                 "@fill_Press"  : [graphical, "disabled1"],
                 "@text_Press"  : [graphical, "disabled2"],
                 "@fill_Focus"  : [graphical, "disabled1"],
                 "@text_Focus"  : [graphical, "disabled2"],
                 "@inkColor"    : [graphical, "disabled1"],
                 "@borderColor" : [graphical, "disabled2"]
            })


            cache.injectState("accent","graphical", {
                  "@fill_Default": [Colors,"accent"],
                  "@text_Default": [Colors,"text2"],
                  "@fill_Press"  : [Colors.contrasting,"accent"],
                  "@text_Press"  : [Colors,"text2"],
                  "@fill_Focus"  : [Colors.contrasting,"accent"],
                  "@text_Focus"  : [Colors,"text1"],
                  "@inkColor"    : [Colors.contrasting,"accent"],
                  "inkOpacity"      : 1,
                  "@borderColor" : [Colors,"text1"]
             })

            cache.injectState("info","graphical", {
                "@fill_Default": [Colors,"info"],
                "@text_Default": [Colors,"text2"],
                "@fill_Press"  : [Colors.darker,"info"],
                "@text_Press"  : [Colors,"text2"],
                "@fill_Focus"  : [Colors,"info"],
                "@text_Focus"  : [Colors,"text1"],
                "@inkColor"    : [Colors,"info"],
                "@borderColor" : [Colors,"text1"]
            })

           cache.injectState("danger","graphical", {
                               "@fill_Default": [Colors,"danger"],
                               "@text_Default": [Colors,"text2"],
                               "@fill_Press"  : [Colors.darker,"danger"],
                               "@text_Press"  : [Colors,"text2"],
                               "@fill_Focus"  : [Colors,"danger"],
                               "@text_Focus"  : [Colors,"text1"],
                               "@inkColor"    : [Colors.contrasting,"danger"],
                               "@borderColor" : [Colors,"text1"]
           })

           cache.injectState("success","graphical", {
                               "@fill_Default": [Colors,"success"],
                               "@text_Default": [Colors,"text2"],
                               "@fill_Press"  : [Colors.darker,"success"],
                               "@text_Press"  : [Colors,"text2"],
                               "@fill_Focus"  : [Colors,"success"],
                               "@text_Focus"  : [Colors,"text1"],
                               "@inkColor"    : [Colors.contrasting,"success"],
                               "@borderColor" : [Colors,"text1"]
            })

            cache.injectState("warning","graphical", {
                                "@fill_Default": [Colors,"warning"],
                                "@text_Default": [Colors,"text2"],
                                "@fill_Press"  : [Colors.darker,"warning"],
                                "@text_Press"  : [Colors,"text2"],
                                "@fill_Focus"  : [Colors,"warning"],
                                "@text_Focus"  : [Colors,"text1"],
                                "@inkColor"    : [Colors.contrasting,"warning"],
                                "@borderColor" : [Colors,"text1"]
             })

            cache.injectState("ghost","rootObject", {"border.width" : 2 })
            cache.injectState("ghost","graphical" , {
                                  "fill_Default" : "transparent",
                                  "@text_Default": [Colors,"text1"],
                                  "@fill_Press"  : [Colors.darker,"success"],
                                  "@text_Press"  : [Colors,"text1"],
                                  "@fill_Focus"  : [Colors,"success"],
                                  "@text_Focus"  : [Colors,"text2"],
                                  "@inkColor"    : [Colors,"text1"],
                                  "@borderColor" : [Colors,"text1"],
                                  inkOpacity : 0.5
                            })

            cache.injectState("ghostalt","rootObject", {"border.width" : 1 })
            cache.injectState("ghostalt","graphical" , {
                                  "fill_Default" : "transparent",
                                  "@text_Default": [Colors,"text2"],
                                  "@fill_Press"  : [Colors.lighter,"success"],
                                  "@text_Press"  : [Colors,"text1"],
                                  "@fill_Focus"  : [Colors,"success"],
                                  "@text_Focus"  : [Colors,"text1"],
                                  "@inkColor"    : [Colors,"text2"],
                                  "@borderColor" : [Colors,"text2"],
                                  inkOpacity : 0.5
                            })


            cache.injectState("transparent", "rootObject", {"border.width" : 0})
            cache.injectState("transparent", "graphical" , {
                                  "fill_Default": "transparent",
                                  "@fill_Press"  : [Colors.darker,"success"],
                                  "@fill_Focus"  : [Colors,"success"],
                                  "@inkColor"    : [Colors,"text2"],
                                  "@borderColor" : [Colors,"text2"],
                                  inkOpacity : 0.5
            })

            cache.injectState("noink", "graphical" , { inkOpacity : 0 })

            cache.injectState("semitransparent", "graphical" , { "fill_Opacity" : 0.8  })
            cache.injectState  ("o!"  , "graphical" , { "fill_Opacity" : "!/10"  })


            cache.injectState("tcontrasting","graphical", {
                "@text_Default": function() {return Colors.contrastingTextColor(graphical.fill_Default)},
                "@text_Press"  : function() {return Colors.contrastingTextColor(graphical.fill_Press)},
                "@text_Focus"  : function() {return Colors.contrastingTextColor(graphical.fill_Focus)}
             })


            cache.injectState("tdisabled","graphical", {
                "@text_Default": [graphical,"disabled1"],
                "@text_Press"  : [graphical,"disabled1"],
                "@text_Focus"  : [graphical,"disabled2"],
                "@borderColor" : [graphical,"disabled1"]
            })

            cache.injectState("tblack","graphical", {
                "text_Default": Colors.names.black,
                "text_Press"  : Colors.names.black,
                "borderColor" : Colors.names.black,
                "text_Focus"  : Colors.names.gray
            })

            cache.injectState("tgray","graphical", {
                "text_Default": Colors.names.gray,
                "text_Press"  : Colors.names.gray,
                "borderColor" : Colors.names.gray,
                "text_Focus"  : Colors.names.lightgray
            })

            cache.injectState("twhite","graphical", {
                "text_Default": Colors.names.white,
                "text_Press"  : Colors.names.white,
                "borderColor" : Colors.names.white,
                "text_Focus"  : Colors.names.black
            })

            cache.injectState("t1","graphical", {
                "@text_Default": [Colors,"text1"],
                "@text_Press"  : [Colors,"text1"],
                "@text_Focus"  : [Colors,"text2"],
                "@borderColor" : [Colors,"text1"]
            })
            cache.injectState("t2","graphical", {
                  "@text_Default": [Colors,"text2"],
                  "@text_Press"  : [Colors,"text2"],
                  "@text_Focus"  : [Colors,"text1"],
                  "@borderColor" : [Colors,"text2"]
            })
            cache.injectState("taccent","graphical", {
                "@text_Default": [Colors,"accent"],
                "@text_Press"  : [Colors,"accent"],
                "@text_Focus"  : [Colors.contrasting,"accent"],
                "@borderColor" : [Colors,"accent"]
            })
            cache.injectState("tdanger","graphical", {
                "@text_Default": [Colors,"danger"],
                "@text_Press"  : [Colors,"danger"],
                "@text_Focus"  : [Colors.contrasting,"danger"],
                "@borderColor" : [Colors,"danger"]
            })
            cache.injectState("twarning","graphical", {
                "@text_Default": [Colors,"warning"],
                "@text_Press"  : [Colors,"warning"],
                "@text_Focus"  : [Colors.contrasting,"warning"],
                "@borderColor" : [Colors,"warning"]
            })
            cache.injectState("tsuccess","graphical", {
                "@text_Default": [Colors,"success"],
                "@text_Press"  : [Colors,"success"],
                "@text_Focus"  : [Colors.contrasting,"success"],
                "@borderColor" : [Colors,"success"]
            })
            cache.injectState("tinfo","graphical", {
                "@text_Default": [Colors,"info"],
                "@text_Press"  : [Colors,"info"],
                "@text_Focus"  : [Colors.contrasting,"info"],
                "@borderColor" : [Colors,"info"]
            })
            cache.injectState("tstandard","graphical", {
                "@text_Default": [Colors,"standard"],
                "@text_Press"  : [Colors,"standard"],
                "@text_Focus"  : [Colors.contrasting,"standard"],
                "@borderColor" : [Colors,"standard"]
            })





            cache.injectState("tcenter"      , "graphical" , { text_hAlignment : Text.AlignHCenter, text_vAlignment : Text.AlignVCenter })

            cache.injectState("tright"       , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignVCenter })
            cache.injectState("tleft"        , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignVCenter })
            cache.injectState("tcenterright" , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignVCenter })
            cache.injectState("tcenterleft"  , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignVCenter })

            cache.injectState("ttop"         , "graphical" , { text_hAlignment : Text.AlignHCenter, text_vAlignment : Text.AlignTop     })
            cache.injectState("ttopcenter"   , "graphical" , { text_hAlignment : Text.AlignHCenter, text_vAlignment : Text.AlignTop     })
            cache.injectState("ttopright"    , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignTop     })
            cache.injectState("ttopleft"     , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignTop     })


            cache.injectState("tbottom"      , "graphical" , { text_hAlignment : Text.AlignHCenter  , text_vAlignment : Text.AlignBottom  })
            cache.injectState("tbottomcenter", "graphical" , { text_hAlignment : Text.AlignHCenter  , text_vAlignment : Text.AlignBottom  })
            cache.injectState("tbottomright" , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignBottom  })
            cache.injectState("tbottomleft"  , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignBottom  })

            cache.graphicalAdded = true;
        }
        function addKnobStates() {  //this is for things that have the knob component!
            cache.injectState("default", "knob" , {"@height":  ["@parent", "height", 2]})
            cache.injectState("noknob" , "knob" , {  "visible"    : false   })



//            cache.injectState("f!", "font" , { "@pixelSize": ["@parent","height","1/!"]})
//            cache.injectState("knob!","knob", { "@height" : function(a) { return rootObject.height * (0.25 * a + 1) } } )
            cache.injectState( "knob1"  , "knob" , { "@height" : ["@parent", "height", 1.25 ] })
            cache.injectState( "knob2"  , "knob" , { "@height" : ["@parent", "height", 1.5  ] })
            cache.injectState( "knob3"  , "knob" , { "@height" : ["@parent", "height", 1.75 ] })
            cache.injectState( "knob4"  , "knob" , { "@height" : ["@parent", "height", 2    ] })
            cache.injectState( "knob5"  , "knob" , { "@height" : ["@parent", "height", 2.25 ] })
            cache.injectState( "knob6"  , "knob" , { "@height" : ["@parent", "height", 2.50 ] })
            cache.injectState( "knob7"  , "knob" , { "@height" : ["@parent", "height", 2.75 ] })
            cache.injectState( "knob8"  , "knob" , { "@height" : ["@parent", "height", 3    ] })
            cache.injectState( "knob9"  , "knob" , { "@height" : ["@parent", "height", 3.25 ] })
            cache.injectState( "knob10" , "knob" , { "@height" : ["@parent", "height", 3.5  ] })

            cache.injectState( "spill1" , "knob" , { "spillScale" : 1.1 } )
            cache.injectState( "spill2" , "knob" , { "spillScale" : 1.2 } )
            cache.injectState( "spill3" , "knob" , { "spillScale" : 1.3 } )
            cache.injectState( "spill4" , "knob" , { "spillScale" : 1.4 } )
            cache.injectState( "spill5" , "knob" , { "spillScale" : 1.5 } )
            cache.injectState( "spill6" , "knob" , { "spillScale" : 1.6 } )
            cache.injectState( "spill7" , "knob" , { "spillScale" : 1.7 } )
            cache.injectState( "spill8" , "knob" , { "spillScale" : 1.8 } )
            cache.injectState( "spill9" , "knob" , { "spillScale" : 1.9 } )

            cache.knobAdded = true;
        }
    }









}
