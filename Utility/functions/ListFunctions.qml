import QtQuick 2.0
QtObject {
    function getFromList(list,value,prop, giveMeIndex) {
        if(!list || !prop)
            return giveMeIndex ? -1 : null;

        for(var i = 0 ; i < list.count; ++i){
            var item = list.get(i)
            if(item && item[prop] && item[prop] === value)
                return giveMeIndex ? i : item;
        }
        return giveMeIndex ? -1 : null;
    }

    //ARRAY RELATED
    function getFromArray(arr,value,prop, giveMeIndex){
        if(!arr || !prop)
            return giveMeIndex ? -1 : null;

        for(var i = 0 ; i < arr.length; ++i){
            var item = arr[i]
            if(item){
                if((prop === null || typeof prop === 'undefined') && item === value)
                    return giveMeIndex ? i : item;
                else if(item[prop] && item[prop] === value)
                    return giveMeIndex ? i : item;
            }
        }
        return giveMeIndex ? -1 : null;
    }
    function indexOf(array, item) {
        var i = 0, length = array && array.length;
        for (; i < length; i++)
            if (array[i] === item) return i;
        return -1;
     }
    function moveArrayElem(arr, old_index, new_index) {
       if (new_index >= arr.length) {
           var k = new_index - arr.length;
           while ((k--) + 1) {
               arr.push(undefined);
           }
       }
       arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
       return arr; // for testing purposes
   }
    function arrEq(arr1, arr2){
        var exists1 = isUndef(arr1)
        var exists2 = isUndef(arr2)

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



}
