function getDescriptor(val , path, isReadOnly, updateFunc) {

}

function getPath(path,key,val) {
    var k = val && val.id !== null && val.id !== undefined ? val.id : key;
    return path ? path + "/" + k : k;
}

function getDescriptorNonEnumerable(value) {
    return {
        enumerable : false,
        value: value
    }
}

