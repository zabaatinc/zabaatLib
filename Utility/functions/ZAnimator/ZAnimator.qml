import QtQuick 2.5
import "../Lodash"
import "../Promises"
pragma Singleton
QtObject{
    id : rootObject
    property int defaultInterval : 333

    function savedAnimNames(){
        return Lodash.keys(logic.map);
    }

    function createUniformColorAnimation(animName, colors){
        if(!animName || typeof animName !== 'string' || !colors)
            return;

        colors = Lodash.isArray(colors) ? colors : [colors]
        var colorAnimLines = []
        Lodash.each(colors, function(v,k){
            if(Lodash.isString(v) && v.indexOf("#") === -1){
                //maybe we got a qt color, lets get that!
                try {
                    colorDeterminer.color = v;
                    v = colorDeterminer.color;
                }
                catch(e) {
                    v = "#fffffff";
                }
            }

            if(Lodash.isObject(v))  //always get hex string
                v = logic.rgbToHex(v.r, v.g, v.b, v.a);


            v = logic.spch(v);  //always surround by ""
            colorAnimLines.push(logic.buildString('ColorAnimation{target:<id> && <id>.target ? <id>.target : null; properties:"<properties>"; to:%s; duration:<duration>}', v))
        })

        var seqAnimStr = 'SequentialAnimation{\nid:<id>;\nloops:<loops>;\nproperty var target;\n' + colorAnimLines.join('\n') + '\n}';
        logic.map[animName] = seqAnimStr;
    }

    function runAnimation(target, animName, propertiesStr_opt, duration_opt, loops_opt, cbOnEnd_opt){
        function animProm() {
            return Promises.promise(function(resolve, reject){
                var qmlStr = logic.map[animName]
                if(!Qt.isQtObject(target) || !qmlStr)
                    return reject();

                var autoId        = "zAnimatorGeneratedAnimation_" + logic.uid++;
                duration_opt      = duration_opt      || defaultInterval;
                duration_opt      = parseInt(duration_opt);
                loops_opt         = loops_opt         || Animation.Infinite;
                propertiesStr_opt = propertiesStr_opt || 'color'

                qmlStr = logic.replaceAll("<id>"        , autoId       , qmlStr);
                qmlStr = logic.replaceAll("<loops>"     , loops_opt        , qmlStr);
                qmlStr = logic.replaceAll("<properties>", propertiesStr_opt, qmlStr);
                qmlStr = logic.replaceAll("<duration>"  , duration_opt     , qmlStr);
        //        console.log(qmlStr);

                var anim = logic.getQmlObject('QtQuick 2.5', qmlStr, target);
                anim.target = target;

                var stopCb = function(){
                    anim.target = null;
                    if(anim && typeof anim.destroy === 'function')
                        anim.destroy();
                    resolve();
                }


                anim.onStopped.connect(stopCb);
                anim.start();
            })

        }

        return animProm().then(cbOnEnd_opt).catch(function(err){console.log("ERROR", err)})
    }

    function factory(){
        var _target, _propertiesStr_opt, _duration_opt, _loops_opt,_anims = [], _runningQMLAnimation, _stopped = false;

        var run = function(animName, _propertiesStr_opt, _loops_opt) {
            console.log('RUN', animName)
            return Promises.promise(function(resolve, reject){
                var qmlStr = logic.map[animName]
                if(!Qt.isQtObject(_target) || !qmlStr)
                    return reject({target:_target, qmlStr : qmlStr});

                var autoId        = "zAnimatorGeneratedAnimation_" + logic.uid++;
                _duration_opt      = _duration_opt      || defaultInterval;
                _duration_opt      = parseInt(_duration_opt);
                _loops_opt         = _loops_opt         || Animation.Infinite;
                _propertiesStr_opt = _propertiesStr_opt || 'color'

                qmlStr = logic.replaceAll("<id>"        , autoId       , qmlStr);
                qmlStr = logic.replaceAll("<loops>"     , _loops_opt        , qmlStr);
                qmlStr = logic.replaceAll("<properties>", _propertiesStr_opt, qmlStr);
                qmlStr = logic.replaceAll("<duration>"  , _duration_opt     , qmlStr);
        //        console.log(qmlStr);

                var anim = logic.getQmlObject('QtQuick 2.5', qmlStr, _target);
                anim.target = _target;

                var stopCb = function(){
                    anim.target = null;
                    if(anim && typeof anim.destroy === 'function')
                        anim.destroy();
                    return resolve(f);
                }


                anim.onStopped.connect(stopCb);
                _runningQMLAnimation = anim;
                anim.start();
            })
        }
        function clone(a) {
            return JSON.parse(JSON.stringify(a))
        }

        var f = function(target){
            _target = target;
            return f;
        }
        f.add=function(){
            _anims.push(arguments)
            return f;
        }

        f.start= function(index){
            index = index || 0
            if(!_stopped && _anims.length > 0 && _anims.length >= index){
                run.apply(this,_anims[index]).then(function(){f.start(++index)})
            }
        }

        f.stop = function() {
            console.log("SETOP WAS CALLED" ,_runningQMLAnimation , toString.call(_runningQMLAnimation))
            if(_runningQMLAnimation) {
                _runningQMLAnimation.stop();
                _runningQMLAnimation.running = false;
                _stopped = true;
            }
            return f;
        }

        return f;
    }


    property QtObject __logic : QtObject{
        id : logic
        property var map      : ({})
        property int uid      : 0;
        property Rectangle colorDeterminer : Rectangle{ id : colorDeterminer }

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
