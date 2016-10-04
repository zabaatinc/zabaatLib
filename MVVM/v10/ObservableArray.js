.import "./Helpers.js" as Helpers
.import "../Lodash/lodash.js" as L
var lodash = L._
function create(arr_opt, path, signals) {
    var arr = [];
    path = path || "";

    //signals are the things that lets us talk back to QML! It will pass them along here.
    Object.defineProperty(arr,"_signals", Helpers.getDescriptorNonEnumerable(signals));



    return arr;
}




