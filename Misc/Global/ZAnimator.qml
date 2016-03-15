import QtQuick 2.0
Item{
    id : rootObject

    function colorAnimation (target, properties, colors , interval, loops, killOnEnd, overwriteOldIfExists){

        if(privates.isUndef(target) || privates.isUndef(properties) || privates.isUndef(colors)  || !privates.isArray(colors) || colors.length < 2 )  return
        if(privates.isUndef(interval))                                                              interval  = 250
        if(privates.isUndef(loops))                                                                 loops     = 4
        if(privates.isUndef(overwriteOldIfExists))                                              overwriteOldIfExists = false
        if(privates.isUndef(killOnEnd))                                                            killOnEnd = true
        if(privates.colorAnimAlreadyRunning(target))                                     return

        if(typeof properties === 'string')
            properties = [properties]

        properties = properties.join(',')

        for(var c in colors)
            colors[c] = privates.spch(colors[c])

        if(!overwriteOldIfExists){
            //check if we already have this animation
            var anim = animHolder.colorAnimMap[target.toString()]
            if(anim){
                anim.loops      = loops
                anim.duration   = interval
                anim.properties = properties

                if(privates.arrEq(anim.colors, colors))
                {
                    anim.start()
                    return
                }
                else{
                    //make new one instead
                    anim.destroy()
                    delete animHolder.colorAnimMap[target.toString()]
                }
            }
        }

        var animLines  = []
        var id         = privates.generateNewId('colorAnim')
        for(var i = 0; i < colors.length; i++){
            var color     = colors[i]
            var nextColor = privates.next(colors,i)
            animLines.push( privates.buildString("ColorAnimation{target: %s._tar; properties:%s.properties; from:%s; to:%s; duration:%s.duration}",id,id,color,nextColor,id) )
        }

        var startStr = privates.buildString('SequentialAnimation{ id:%s; loops:%s; property int duration:%s; property string properties:""; property var colors:[]; property int index:%s; property var _tar:null;',id,loops,interval,animHolder.activeAnims.length)
        var killStr  = 'signal isDying(var obj);Component.onDestruction: isDying(this);'
        killStr      += killOnEnd ? privates.buildString('onStopped: %s.destroy();',id) : 'onStopped : console.log(_tar,"color anim stopped");';

        var seqAnim  = privates.getQmlObject('QtQuick 2.0', startStr + killStr + animLines.join('\n') + '}' , animHolder )

        seqAnim.properties = properties
        seqAnim.colors = colors
        seqAnim._tar   = target
        animHolder.activeAnims.push(seqAnim)
        seqAnim.isDying.connect(animHolder.die)

        if(!killOnEnd){
            if(privates.isUndef(animHolder.colorAnimMap))
                animHolder.colorAnimMap = {}
            animHolder.colorAnimMap[target.toString()] = seqAnim
        }

        seqAnim.start()
    }

    //TODO
    function numberAnimation(target, properties, values, interval, loops, killOnEnd){

    }

    Item{
        id : animHolder
        objectName: 'animHolder'
        property var colorAnimMap : ({})
        property var animMap      : ({})
        property var activeAnims  : []

        function die(obj){
            var target = obj && obj._tar ? obj._tar.toString() : null
            if(target && colorAnimMap[target])
                delete colorAnimMap[target]

            activeAnims.splice(obj.index,1)
        }

    }




    QtObject{
        id : privates

        property int counter : 0
        function getQmlObject(imports,qmlStr,parent) {
            var str = ""

            if(typeof imports !== 'string')
            {
                for(var i in imports)
                    str += "import " + imports[i] + ";\n"
            }
            else
                str = "import " + imports + ";"

            var obj = Qt.createQmlObject(str + qmlStr,parent,null)
            return obj
        }
        function isArray(obj){
            return toString.call(obj) === '[object Array]';
        }
        function next(arr, index){
            index = index + 1
            if(index > arr.length -1)
                return arr[0]
            return arr[index]
        }
        function buildString(str){
            var args = Array.prototype.slice.call(arguments, 1)
            var index = 0
            return str.replace(/%s/g, function(match, number)
            {
                var ret = typeof args[index] != 'undefined' ? args[index] : index ;
                index++
                return ret
            });
        }
        function colorAnimAlreadyRunning(target){
            for(var i = 0; i < animHolder.activeAnims.length; i++){
                var anim = animHolder.activeAnims[i]
                if(anim.running && anim._tar === target){
                    return true
                }
            }
            return false
        }
        function spch(str){
            return  "\"" + str + "\"";
        }
        function generateNewId(type){
            if(isUndef(type))
                type = 'anim'
            var str = type + counter
            counter++
            return str
        }
        function arrEq(arr1, arr2){
            var exists1 = !isUndef(arr1)
            var exists2 = !isUndef(arr2)

            if(exists1 === exists2){
                if(!exists1)
                    return true
                else if(arr1.length === arr2.length){
                    for(var i = 0; i < arr1.length; i++){
                        if(arr1[i] != arr2[i])
                            return false
                    }
                }
            }
            return true
        }
        function isUndef(obj){
            return obj === null || typeof obj === 'undefined'
        }


    }

}
