.import "./Helpers.js" as Helpers
.import "../Lodash/lodash.js" as L
var lodash = L._
function create(obj_opt, path, signals) {
    var obj = {}
    path = path || "";

    //signals are the things that lets us talk back to QML! It will pass them along here.
    Object.defineProperty(obj,"_signals", Helpers.getDescriptorNonEnumerable(signals));



    return obj;
}
