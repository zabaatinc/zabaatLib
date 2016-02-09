import QtQuick 2.0
QtObject {

    function not(variable){
        if(variable !== null && typeof variable !== 'undefined'){
            for(var i = 1 ; i < arguments.length; i++){
                if(variable === arguments[i])
                    return false
            }
        }
        else{
            for(i = 0; i < arguments.length; i++){
                if(arguments[i])
                    return false
            }
        }

        return true
    }
    function or(variable){
        for(i = 0; i < arguments.length; i++){
            if(arguments[i])
                return true
        }
        return false
    }
    function and(){
        for(var i = 0; i < arguments.length; i++){
            if(!arguments[i])
                return false
        }
    }
    function equalsToAny(variable) {
        if(arguments.length > 1) {
            for(var i = 1 ; i < arguments.length; i++){
                if(variable === arguments[i])
                    return true
            }
        }
        return false;
    }



}
