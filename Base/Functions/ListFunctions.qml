import QtQuick 2.0
import "../Lodash"
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

    function getFromList_v2(list,matchElemOrFunc,giveMeIndex,startingIndex,loopAround){
        var badVal = giveMeIndex ? -1 : null;
        if(!list)
            return;

        startingIndex = startingIndex || 0;
        if(startingIndex >= list.count)
            startingIndex = 0;

        var isFunc = typeof matchElemOrFunc === 'function'
        var finderFunc = function(i) {
            var item = list.get(i);
            if(isFunc){
                if(matchElemOrFunc(item))
                   return giveMeIndex? i : item;
            }
            else {
                if(item == matchElemOrFunc)
                    return giveMeIndex? i : item;
            }
            return undefined;
        }

        for(var i = startingIndex; i < list.count; ++i){
            var r = finderFunc(i);
            if(r !== undefined)
                return r;
        }

        if(loopAround) {
            for(i = 0; i < startingIndex; ++i) {
                r = finderFunc(i);
                if(r !== undefined)
                    return r;
            }
        }


        return badVal
    }

    function cloneListOrArray(item) {
        if(!item || typeof item !== 'object')
            return null;

        var itemIsArray = isArray(item);
        var len = itemIsArray ? item.length : item.count;
        var obj = itemIsArray ? []          : listGenerator.createObject(listContainer);

        for(var i = 0; i < len; i++) {
            var val = itemIsArray ? item[i] : item.get(i);
            var rDerp

            if(typeof val !== 'object'){
                rDerp = itemIsArray ? obj.push(val) : obj.append(val);
            }
            else {
                var newObj = cloneObject(val);
                rDerp = itemIsArray ? obj.push(newObj) : obj.append(newObj);
            }
        }

        return obj;
    }

    function containsIn(collection,val_s) {
        if(Lodash.isArray(collection))
            return findInArray(collection,val_s) !== -1;
        return findInList(collection,val_s) !== -1;
    }

    function findIn(collection,val_s) {
        if(Lodash.isArray(collection))
            return findInArray(collection,val_s)
        return findInList(collection,val_s)
    }



    function findInArray(collection, val_s) {
        if(!collection)
            return true;

        if(Lodash.isArray(collection) && collection.length == 0)
            return true;

        var r = Lodash.isArray(collection) ?  collection : [collection];
        var vals = Lodash.isArray(val_s) ?  val_s : [val_s];
        for(var i = 0; i < vals.length; ++i) {
            var v = vals[i];
            var idx = collection.indexOf(v);
            if(idx !== -1)
                return idx;
        }

        return -1;
    }

    function findInList(collection, val_s, fn) {
        if(!collection)
            return true;

        fn = Lodash.isFunction(fn) ? null :function(a,b) {
                                                    return a == b
                                                }

        var r = Lodash.isArray(collection) ?  collection : [collection];
        var vals = Lodash.isArray(val_s) ?  val_s : [val_s];
        for(var i = 0; i < vals.length; ++i) {
            var v = vals[i];
            var idx = getFromList_v2(collection,fn,true);
            if(idx !== -1)
                return idx;
        }

        return -1;
    }




    function cloneObject(obj, r) {
        r = r || {}
        function isQmlType(v) {
            if(!v || !v.hasOwnProperty || !v.hasOwnProperty('objectName') || !v.hasOwnProperty('objectNameChanged'))
                return false;
            return true;
        }

        if(typeof obj !== 'object')
            return obj;

        Lodash.each(obj, function(v,k) {
            var type = toString.call(v);
            if(type === '[object Array]') {
                r[k] = [];
                cloneObject(v, r[k]);
            }
            else if(isQmlType(v) ) {
                //TODO, make better.
                r[k] = v.toString();
            }
            else if(type === '[object Object]') {
                r[k] = {}
                cloneObject(v, r[k]);
            }
            else {
                r[k] = v;
            }
        })

        return r;
    }




    function quickSort (lm, compareFunc) {
        if(!lm )
            return false

        return isArray(lm) ? hidden.qsArr(lm,compareFunc) : hidden.qs(lm, compareFunc)
    }
    function heapSort(lm, compareFunc) {
        if(!lm)
            return false;

        return isArray(lm) ? hidden.hsArr(lm, compareFunc) : hidden.hs(lm, compareFunc)
    }

    function insert(lmOrArr, index, value) {
        if(isArray(lmOrArr)) {
           lmOrArr.splice(index, 0 , value);
        }
        else {
            lmOrArr.insert(index,value);
        }
    }


    property QtObject __hidden : QtObject {
        id : hidden

        function qs(lm, compareFunc) {
            var l = 0;
            var h = lm.count - 1
            var cmpFunc = compareFunc ? function(a,b) { return compareFunc(lm.get(a), lm.get(b)) }  :
                                        function(a,b) { return lm.get(a) - lm.get(b); }


            function swap(a,b){
//                console.time('swapTime')
                if (a<b) {
                    lm.move(a,b,1);
                    lm.move(b-1,a,1);
                }
                else if (a>b) {
                    lm.move(b,a,1);
                    lm.move(a-1,b,1);
                }
//                console.timeEnd('swapTime')
            }
            function partition (l, h) { //l = startIndex, h = endIndex
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


            return true;
        }
        function qsArr(lm, compareFunc){
            var l = 0;
            var h = lm.length - 1;
            var cmpFunc = compareFunc ? function(a,b) { return compareFunc(lm[a],lm[b]) } :
                                        function(a,b) { return lm[a] - lm[b]}

            function swap(a,b){
                var c = lm[b];
                lm[b] = lm[a];
                lm[a] = c;
            }
            function partition (l, h) { //l = startIndex, h = endIndex
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


            return lm;
        }

        function hs(lm, compareFunc) {
            var cmpFunc = compareFunc ? function(a,b) { return compareFunc(lm.get(a), lm.get(b)) }  :
                                        function(a,b) { return lm.get(a) - lm.get(b); }

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
            function heapify(array, index, heapSize) {
                var left    = 2 * index + 1,
                    right   = 2 * index + 2,
                    largest = index;

                if (left < heapSize &&  cmpFunc(left,index) > 0 )
                    largest = left;

                if (right < heapSize && cmpFunc(right,largest) > 0)
                    largest = right;

                if (largest !== index) {
                    swap(index,largest);
                    heapify(array, largest, heapSize);
                }
            }
            function buildMaxHeap(array) {
                var s =  array.count

                for (var i = Math.floor(s / 2); i >= 0; i -= 1) {
                    heapify(array, i, s);
                }
                return array;
            }

            var size = lm.count;
            var temp;

            buildMaxHeap(lm);
            for (var i = size - 1; i > 0; --i) {
                swap(0,i);
                size -= 1;
                heapify(lm, 0, size);
            }

            return lm;

        }
        function hsArr(lm, compareFunc) {

            var cmpFunc = compareFunc ? function(a,b) { return compareFunc(lm[a],lm[b]) } :
                                        function(a,b) { return lm[a] - lm[b]}

            function swap(a,b){
                var c = lm[b];
                lm[b] = lm[a];
                lm[a] = c;
            }
            function heapify(array, index, heapSize) {
                var left    = 2 * index + 1,
                    right   = 2 * index + 2,
                    largest = index;

                if (left < heapSize &&  cmpFunc(left,index) > 0 )
                    largest = left;

                if (right < heapSize && cmpFunc(right,largest) > 0)
                    largest = right;

                if (largest !== index) {
                    swap(index,largest);
                    heapify(array, largest, heapSize);
                }
            }
            function buildMaxHeap(array) {
                var s =  array.length
                for (var i = Math.floor(s / 2); i >= 0; i -= 1) {
                    heapify(array, i, s);
                }
                return array;
            }

            var size = lm.length;
            var temp;

            buildMaxHeap(lm);
            for (var i = size - 1; i > 0; --i) {
                swap(0,i);
                size -= 1;
                heapify(lm, 0, size);
            }

            return lm;
        }
    }


    function binarySearch(lm, searchElement, compareFunc) {
        function cmpFunc(a,b) {
            function defaultCmpFunc(aVal,bVal){
                return aVal - bVal;
            }
            var sfunc = compareFunc ? compareFunc : defaultCmpFunc
            return sfunc(a,b)
        }

        if(!Lodash.isUndefined(lm))
            return -1;

        var isArr = isArray(lm);
        var minIndex = 0;
        var maxIndex = isArr?  lm.length - 1 :lm.count - 1;
        var currentIndex;
        var currentElement;

        while (minIndex <= maxIndex) {
            currentIndex = (minIndex + maxIndex) / 2 | 0;
            currentElement = isArr? lm[currentIndex] : lm.get(currentIndex);

            var cmpRes = cmpFunc(currentElement, searchElement)

            if (cmpRes < 0) {
                minIndex = currentIndex + 1;
            }
            else if (cmpRes > 0) {
                maxIndex = currentIndex - 1;
            }
            else {
                return currentIndex;
            }
        }

        return -1;
    }
    function binarySearchInsert(lm, insertElement, compareFunc) {
        if(!Lodash.isUndefined(lm))
            return -1;

        var minIndex = 0;
        var maxIndex = lm.count - 1;
        var currentIndex;
        var currentElement;

        function cmpFunc(a,b) {
            function defaultCmpFunc(aVal,bVal){
                return aVal - bVal;
            }
            var sfunc = compareFunc ? compareFunc : defaultCmpFunc
            return sfunc(a,b)
        }

        while (minIndex <= maxIndex) {
            currentIndex = (minIndex + maxIndex) / 2 | 0;
            currentElement = lm.get(currentIndex);

            var cmpRes = cmpFunc(currentElement, insertElement)

            if (cmpRes < 0) {
                minIndex = currentIndex + 1;
            }
            else if (cmpRes > 0) {
                maxIndex = currentIndex - 1;
            }
            else {
                break;
            }
        }

        lm.insert(currentIndex, insertElement)
        return currentIndex;
    }

    //ARRAY RELATED
    function getFromArray_v2(arr,matchElemOrFunc,giveMeIndex, startingIndex, loopAround){
        var badVal = giveMeIndex ? -1 : null;
        if(!arr || !isArray(arr))
            return;

        startingIndex = startingIndex || 0;
        if(startingIndex >= arr.length)
            startingIndex = 0;

        var isFunc = typeof matchElemOrFunc === 'function'
        var finderFunc = function(i) {
            var item = arr[i]
            if(isFunc){
                if(matchElemOrFunc(item))
                   return giveMeIndex? i : item;
            }
            else {
                if(item == matchElemOrFunc)
                    return giveMeIndex? i : item;
            }
            return undefined;
        }

        for(var i = startingIndex; i < arr.length; ++i){
            var r = finderFunc(i);
            if(r !== undefined)
                return r;
        }

        if(loopAround) {
            for(i = 0; i < startingIndex; ++i) {
                r = finderFunc(i);
                if(r !== undefined)
                    return r;
            }
        }


        return badVal
    }
    function isArray(obj){
        return toString.call(obj) === '[object Array]';
    }
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


    function removeFirstThatMatches(list, killerFunc){
        for(var i = 0; i < list.count ; ++i){
            if(killerFunc(list.get(i)))
                list.remove(i)
        }
    }
    function removeLastThatMatches(list, killerFunc) {
        removeAllThatMatch(list, killerFunc, 1)
    }
    function removeAllThatMatch(list, killerFunc, count) {
        var remCount = 0;
        for(var i = list.count - 1; i >= 0 ; --i){
            if(killerFunc(list.get(i))) {
                list.remove(i)
                remCount++
                if(count && remCount === count) {
                    return
                }
            }
        }
    }


    property Component listGenerator : Component { id : listGenerator;  ListModel { dynamicRoles : true } }
    property Item listContainer : Item { id : listContainer }

}
