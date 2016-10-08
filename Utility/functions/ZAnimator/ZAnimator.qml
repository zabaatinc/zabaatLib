import QtQuick 2.5
import "../Lodash"
import "../Promises"
pragma Singleton

//usage
//First define animtions like ->
// ZAnimator.createColorAnimation ("bleed" , ["red",'darkRed'])
// ZAnimator.createNumberAnimation('shake' , [20, 0 , -20, 0]);
//
// Then, get an animationRunner by:
// var ani = ZAnimator.sequentialAnimationRunner(QMLTargetItem)
// ani.add('bleed')
//    .add('shake','x,y',1000,Animation.Infinite)
//    .start().onEnd(function(){
//          console.log("animation finished")
//    });


QtObject{
    id : rootObject
    property int defaultInterval : 333
    property int defaultLoops    : 1

    function savedAnimNames(){
        return Lodash.keys(logic.map);
    }

    function createColorAnimation(animName, colors){
        colors = Lodash.isArray(colors) ? colors : [colors]
        var c = []
        Lodash.each(colors, function(v,k){
            if(Lodash.isString(v) && v.indexOf("#") === -1){
                try {   //we got a string but it's not hex. So maybe it's a qt color liek 'red' etc. lets get that color
                    colorDeterminer.color = v;
                    v = colorDeterminer.color;
                }
                catch(e) {
                    v = "#fffffff";
                }
            }
            if(Lodash.isObject(v))  //always get hex string
                v = logic.rgbToHex(v.r, v.g, v.b, v.a);
            c.push(logic.spch(v));
        })
        logic.createAnimationBluePrint(animName, c, "ColorAnimation");
    }
    function createNumberAnimation(animName, values){
        logic.createAnimationBluePrint(animName, values);
    }

    function sequentialAnimationRunner(item){
        //private variables
        var m_target = item;
        var m_properties
        var m_duration
        var m_loops
        var m_anims = []
        var m_userStopCalled = false
        var m_currentQmlAnimation
        var m_cb   = function() {}  //adjustable by calling .end(fn)
        var retObj = {}            //this is returned all the time

        function getAnimationPromise(animName, props, duration, loops) {
            return Promises.promise(function(resolve, reject){
                var mapEntry = logic.map[animName];
                if(!Qt.isQtObject(m_target) || !mapEntry) {
                    return reject(m_target, mapEntry) ;
                }

                var anim = logic.generateAnimFromBP(m_target, props,duration,loops,mapEntry);
                if(!anim){
                    return reject("Could not create animation dynamically") ;
                }

                anim.target = m_target;
                var stopCb = function(){
                    m_currentQmlAnimation = null;
                    anim.target = null;
                    if(anim && typeof anim.destroy === 'function')
                        anim.destroy();
                    if(!m_userStopCalled)
                        return resolve(retObj);
                    else {
                        m_userStopCalled = false;
                        return reject(retObj);
                    }
                }

                m_currentQmlAnimation = anim;
                anim.onStopped.connect(stopCb);
                anim.start();
            })
        }

        retObj.add   = function(name,props,duration,loops) {
            if(!name || !logic.map[name])
                return retObj;

            m_anims.push([name,props,duration,loops]);

            return retObj;
        }
        retObj.start = function(index){
            if(m_currentQmlAnimation && m_currentQmlAnimation.paused) {
                m_currentQmlAnimation.resume();
                return retObj;
            }
            logic.setTimeOut(0, function(){
                index = index || 0;
                if(index < m_anims.length){
                    var args = m_anims[index];
                    getAnimationPromise.apply(this,args).then(function() { retObj.start(++index) } );
                }
                else {
                    m_cb();
                }
            })
            return retObj;
        }
        retObj.stop  = function() {
            if(m_currentQmlAnimation) {
                m_userStopCalled = true;
                var m = m_currentQmlAnimation;
                m.stop();
                m.running = false;
            }
            return retObj;
        }
        retObj.pause = function() {
            if(m_currentQmlAnimation && m_currentQmlAnimation.running) {
                m_currentQmlAnimation.pause();
            }
            return retObj;
        }
        retObj.onEnd = function(cb){
            if(typeof cb === 'function')
                m_cb = cb;
            return retObj;
        }

        return retObj;
    }


    property QtObject __logic : QtObject{
        id : logic
        property var map      : ({})
        property int uid      : 0;
        property Rectangle colorDeterminer : Rectangle{ id : colorDeterminer }

        function createAnimationBluePrint(animName, values, qmlAnimationName){
            qmlAnimationName = qmlAnimationName || "NumberAnimation"
            if(!animName || typeof animName !== 'string' || !values)
                return;

            values = Lodash.isArray(values) ? values : [values]
            var animLines = []
            Lodash.each(values, function(v,k){
                var str = qmlAnimationName + '{target:<id> && <id>.target ? <id>.target : null; properties:"<properties>"; to:<value>; duration:<duration>}'
                animLines.push({str : str, value : v })
            })

            logic.map[animName] = { type: qmlAnimationName, data : animLines };
        }

        function generateAnimFromBP(target, properties, duration, loops, animBluePrint){

            function relativeValue(p,v){    //returs relative values against numbers, and absolute for others
                var tVal = target[p]
                return typeof tVal === 'number' && typeof v === 'number' ? target[p] + v : v;
            }


            if(!animBluePrint)
                return false;

            var isColorAnimation = animBluePrint.type === 'ColorAnimation'
            var defProperty      = isColorAnimation ? "color" : "x";
            var animLines        = animBluePrint.data;

            var autoId = "zAnimatorGeneratedAnimation_" + logic.uid++;
            loops      = parseInt(loops || defaultLoops);
            duration   = parseInt((duration || defaultInterval) / animLines.length) || defaultInterval;


            var props = properties ? Lodash.compact(properties.split(",")) : [defProperty]
            if(props.length === 0)
                return false;

//            console.log("PROPERTIES=", properties, props);


            //If there's only one property or if its a color anim, no need to do any parallel anims!
            var lines = []
            if(props.length === 1 || isColorAnimation){
                var p = props[0]
                Lodash.each(animLines, function(v,k){
                    var line = logic.replaceAll("<value>"     ,relativeValue(p,v.value)     ,v.str);
                    line     = logic.replaceAll("<properties>",props.join(',')              , line);
                    lines.push(line);
                })
            }
            else {
                Lodash.each(animLines, function(v){
                    lines.push("ParallelAnimation{")
                    Lodash.each(props, function(p){
                        var line = logic.replaceAll("<value>"     ,relativeValue(p,v.value) ,v.str);
                        line     = logic.replaceAll("<properties>",p , line);
                        lines.push(line);
                    })
                    lines.push("}")
                })
            }

            var qmlStr = 'SequentialAnimation{\nid:<id>;\nloops:<loops>;\nproperty var target;\n' + lines.join('\n') + '\n}';
            qmlStr = logic.replaceAll("<id>",autoId, qmlStr);
            qmlStr = logic.replaceAll("<loops>",loops, qmlStr);
            qmlStr = logic.replaceAll("<duration>",duration, qmlStr);
            return logic.getQmlObject('QtQuick 2.5', qmlStr, target);
        }

        function setTimeOut(ms, fn, args) {
            var t = timerFactory.createObject(priv);
            t.fn = fn;
            t.args = args;
            t.interval = ms;
            t.start();
        }

        property Item priv : Item {

            Component {
                id : timerFactory
                Timer {
                    id : timerInstance
                    property var fn
                    property var args
                    onTriggered: {
                        if(typeof fn === 'function') {
                            if(args) {
                                if(toString.call(args) !== '[object Array]')
                                    args = [args]

                                fn.apply(this,args);
                            }
                            else {
                                fn();
                            }
                        }
                        timerInstance.destroy();
                    }
                }
            }

        }


        function getQmlObject(imports,qmlStr,parent) {
            var str = ""
            imports = Lodash.isArray(imports) ? imports : [imports]
            Lodash.each(imports, function(v){
                str += "import " + v + ";\n"
            })
            var obj = Qt.createQmlObject(str + qmlStr,parent,null)
            return obj
        }
        function spch(str){ return  "\"" + str + "\""; }
        function buildString(str){
            var args = Array.prototype.slice.call(arguments, 1)
            var index = 0
            return str.replace(/%s/g, function(match, number) {
                var ret = typeof args[index] != 'undefined' ? args[index] : index ;
                index++
                return ret
            });
        }
        function replaceAll(find, replace, str) {
            function escapeRegExp(string) {
                return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
            }
          return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
        }

        function rgbToHex(r,g,b,a){
            r = Math.floor(parseFloat(r) * 255);
            g = Math.floor(parseFloat(g) * 255);
            b = Math.floor(parseFloat(b) * 255);
            a = Math.floor(parseFloat(a) * 255);
            //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
            function componentToHex(c) {
                var hex = c.toString(16);
                return hex.length == 1 ? "0" + hex : hex;
            }
            return "#" + componentToHex(a) + componentToHex(r) + componentToHex(g) + componentToHex(b);
        }
        function hexToRgb(hex){
            //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
            var defaultVal = { r: 0, g : 0, b : 0, a : 1 }
            var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            if(result !== null){
                return {
                    r: parseInt(result[1], 16)/255,
                    g: parseInt(result[2], 16)/255,
                    b: parseInt(result[3], 16)/255,
                    a : 1
                }
            }

            //try regexing on 4. so we can  get a.
            result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            return result ? {
                a: parseInt(result[1], 16)/255,
                r: parseInt(result[2], 16)/255,
                g: parseInt(result[3], 16)/255,
                b: parseInt(result[4], 16)/255
            } : defaultVal;
        }

    }





}
