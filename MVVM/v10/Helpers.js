function getDescriptor(val , path, isReadOnly, updateFunc) {

    var _value = val;
    var _path  = path;

    var r = { enumerable : true }
    r.get =  function() {
        this._signals.beforePropertyUpdated(path,val,"X_X")
        return _value;
    }

    r.set = isReadOnly ? function() { console.error("cannot write to readonly property", _path ) ;} :
                         function(val, noUpdate) {
                            if(val != _value) {
                                var oldVal = _value;
                                this._signals.beforePropertyUpdated(path,oldVal,val);
                                _value = val;

                                if(!noUpdate)
                                    this._signals.propertyUpdated(path,oldVal,val);
                            }
                        }

    return r;
}

function getPath(path,key,val) {
    var k = val && val.id !== null && val.id !== undefined ? val.id : key;
    return path ? path + "/" + k : k;
}

function getDescriptorNonEnumerable(value) {
    var _value = value;
    return {
        enumerable : false,
        value: _value
    }
}

