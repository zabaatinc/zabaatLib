function ZIterator(model) {
    this.model            = model;
    this.type             = this.getType();

    this.isArray          = this.type === 'array'
    this.isListModel      = this.type === 'listmodel'
    this.isObject         = this.type === 'object'

    this.properties       = this.getProperties()
    this.itr              = 0;
    this.lastReadProperty = null;
}

ZIterator.prototype.getProperties = function (){
    var propArr = []

    if(this.model !== null && typeof this.model !== 'undefined') {
        if(this.type === 'array' || this.type === 'listmodel'){
            var isArray = this.type === 'array'
            var len = isArray ? 'length' : 'count'
            for(var i = 0; i < this.model[len] ; i++)
                propArr.push(i)
        }
        else{
            for(var o in this.model){
                propArr.push(o)
            }
        }
    }

    return propArr
}
ZIterator.prototype.getType       = function(){
    var obj = this.model
    if(obj === null || typeof obj === 'undefined')
        return obj

    if(toString.call(obj) === '[object Array]')
        return 'array'
    if(obj.toString().toLowerCase().indexOf('listmodel') !== -1)
        return 'listmodel'

    if(typeof obj === 'object')
        return 'object'

    return typeof obj
}
ZIterator.prototype.prev          = function() {
    var prop = this.properties[this.itr]
    if(this.hasPrev()){
        this.itr--
        return this.get(prop)
    }
    return null
}
ZIterator.prototype.next          = function() {
    var prop = this.properties[this.itr]
    if(this.hasNext()){
        this.itr++
        return this.get(prop)
    }
    return null
}


ZIterator.prototype.toEnd      = function(){
    this.itr = this.properties.length - 1
}
ZIterator.prototype.toStart    = function(){
    this.itr = 0
}
ZIterator.prototype.hasPrev    = function(){
    return this.itr >= 0 && this.properties.length > 0
}
ZIterator.prototype.hasNext    = function(){
    return this.itr  < this.properties.length
}
ZIterator.prototype.get        = function(idxOrProp){
    if(this.isArray || this.isListModel){
        var len = this.isArray ? 'length' : 'count'
        if(idxOrProp >= 0 && idxOrProp < this.model[len]) {
//            console.trace()
            return this.isArray ? this.model[idxOrProp] : this.model.get(idxOrProp)
        }
    }
    else if(this.isObject){
        return this.model[idxOrProp]
    }
    return null
}
ZIterator.prototype.indexOf    = function(array, item) {
    for(var i = 0; i < array.length; i++){
        if(array[i] === item)
            return i
    }
    return -1;
}







