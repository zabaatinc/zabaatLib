function each(collection, fn) {
    if(typeof fn !== 'function' || typeof collection !== 'object')
        return;

    for(var k in collection){
        if(fn(collection[k],k) === false)
            return;
    }
}
function eachRight(collection, fn){
    if(typeof fn !== 'function' || typeof collection !== 'object')
        return;

    var keyArr = keys(collection).sort(function(a,b){ return b-a; });
//    keyArr.sort(function(a,b){ return b-a; });

    for(var k = 0; k < keyArr.length; k++){
        var i = keyArr[k];
        if(fn(collection[i],i) === false)
            return;
    }
}

function indexOf(arr,v) {
    if(typeof arr !== 'object')
        return -1;

    for(var k in arr){
        if(arr[k] == v)
            return k;
    }
    return -1;
}
function isObject(obj){
    return toString.call(obj) === '[object Object]'
}
function isArray(arr) {
    return toString.call(arr) === "[object Array]"
}
function keys(collection) {
    var arr = []
    each(collection,function(v,k){
        arr.push(k)
    })
    return arr;
}
function boundingRect(items) {
    if(!items || typeof items !== 'object')
        return rect();

    var topLeft  = Qt.point(Number.MAX_VALUE,Number.MAX_VALUE);
    var botRight = Qt.point(0,0);
    each(items, function(v,k) {
        topLeft.x  = Math.min(v.x, topLeft.x);
        topLeft.y  = Math.min(v.y, topLeft.y);
        botRight.x = Math.max(v.x + v.width, botRight.x);
        botRight.y = Math.max(v.y + v.height, botRight.y);
    })
    return rect(topLeft.x, topLeft.y, botRight.x - topLeft.x, botRight.y - topLeft.y)
}
function has(item, properties) {
    if(typeof item !== 'object')
        return false;

    for(var i = 1; i < arguments.length; ++i){
        var p = arguments[i];
        if(isArray(p)){
            if(!has(item,p))
                return false;
        }
        if(typeof p !== 'string')
            continue;
        if(!item.hasOwnProperty(p))
            return false;
    }

    return true;
}

function rect(item) {
    var r = { x: 0, y: 0, width: 0, height : 0 }
    if(arguments.length <= 1) {
        if(typeof item !== 'object' || !has(item,'x','y','width','height'))
            return r;

        return { x : item.x,
                 y : item.y,
                 width: item.width,
                 height : item.height
        }
    }
    return  { x : item,
              y : arguments[1] || 0,
              width : arguments[2] || 0,
              height : arguments[3] || 0 }
}

function copyProperties(copier, copiee) {
    if(typeof copier !== 'object' || typeof copiee !== 'object')
        return;

    each(copiee,function(v,k){
        if(copier.hasOwnProperty(k)){
            try {
                copier[k] = v;
            }catch(e){ }
        }
    })
}
