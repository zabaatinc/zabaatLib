import QtQuick 2.0
QtObject {

    function isInt(term) {
        var n = Number(term);
        return !isNaN(n) && n % 1 === 0;
    }

    function isFloat(term) {
        var n = Number(term);
        return !isNaN(n) && n % 1 !== 0;
    }

    function clamp(val, min,max) {
        if(val < min)            return min;
        else if(val > max)       return max;
        return val;
    }

    function clamp01(val){
        return clamp(val,0,1);
    }
}
