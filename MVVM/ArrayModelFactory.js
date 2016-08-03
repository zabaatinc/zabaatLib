//essentially takes an array and adds some nice signals slots to it!!
.import "Lodash/lodash.js" as L

var emitUpdateFunc
var emitCreateFunc
var emitDeleteFunc

var arrayModel = {
    arr : undefined,
    get : function(path) {
        if(!this.arr)
            return null;
        if(!path)
            return arr;

        return L._.get(this.arr, path);
    },
    set : function(path,data,onlyUpdate) {
        if(!this.arr)
            this.arr = []

        var updatedValues = []

        var existing = this.get(path);
        if(existing) {
            //compare things!!!

        }
        else if(!onlyUpdate){

        }
    },
    get count() {
      if(this.arr && L._.isArray(this.arr))
        return this.arr.length;
      return 0;
    }
}

function getArrayModel(arr) {
    var a = Object.create(arrayModel);
    a.arr = arr;
    return a;
}



