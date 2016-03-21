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

    function isArray(obj){
        return toString.call(obj) === '[object Array]';
    }


    function sortList (lm, compareFunc) {


        /* A[] --> Array to be sorted, http://www.geeksforgeeks.org/iterative-quick-sort/
           l  --> Starting index,
           h  --> Ending index */
        var quickSortIterative = function (l, h){

            function cmpFunc(a,b) {

                function defaultCmpFunc(aVal,bVal){
                    if(aVal < bVal)
                        return -1
                    else if(aVal > bVal)
                        return 1
                    return 0
                }


                var sfunc = compareFunc ? compareFunc : defaultCmpFunc
                var aVal  = lm.get(a)
                var bVal  = lm.get(b)

                return sfunc(aVal,bVal)
            }

            function swap(a,b){
                if (a<b) {
                    lm.move(a,b,1);
                    lm.move(b-1,a,1);
                }
                else if (a>b) {
                    lm.move(b,a,1);
                    lm.move(a-1,b,1);
                }
            }
            function partition (l, h) { //l = startIndex, h = endIndex
                var arr = lm

    //            var x = arr.get(h);
                var i = l - 1;

                for (var j = l; j <= h- 1; j++)
                {
                    if (cmpFunc(j,h) <= 0)
                    {
                        i++;
                        swap (i, j);
                    }
                }
                swap (i + 1, h);
                return (i + 1);
            }

            // Create an auxiliary stack
            var stack = [] //[ h - l + 1 ];

            // initialize top of stack
            var top = -1;

            // push initial values of l and h to stack
            stack[ ++top ] = l;
            stack[ ++top ] = h;

            // Keep popping from stack while is not empty
            while ( top >= 0 )
            {
                // Pop h and l
                h = stack[ top-- ];
                l = stack[ top-- ];

                // Set pivot element at its correct position
                // in sorted array
                var p = partition( l, h );

                // If there are elements on left side of pivot,
                // then push left side to stack
                if ( p-1 > l )
                {
                    stack[ ++top ] = l;
                    stack[ ++top ] = p - 1;
                }

                // If there are elements on right side of pivot,
                // then push right side to stack
                if ( p+1 < h )
                {
                    stack[ ++top ] = p + 1;
                    stack[ ++top ] = h;
                }
            }
        }


        if(!lm )
            return false


        quickSortIterative(0, lm.count - 1)
//        console.log("FINISHED SORTING")
        return true;
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
