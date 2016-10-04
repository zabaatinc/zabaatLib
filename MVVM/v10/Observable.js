//Returns us object or array, depending on what we provide!
//Default, returns array!
.import "./ObservableArray.js" as OA
.import "./ObservableObject.js" as OO
.import "../Lodash/lodash.js" as L
var lodash = L._

function create(js, path, signals){
    if(js && lodash.isObject(js)){
        return OO.create(js,path,signals);
    }
    return OA.create(js,path,signals);
}


