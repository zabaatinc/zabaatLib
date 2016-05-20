function getNewObject(name,parent)
{
    var cmp = Qt.createComponent(name)
    if(cmp.status != Component.Ready)
        console.log(name,cmp.errorString())

    return cmp.createObject(parent)
}

function spch(str)    {        return  "\"" + str + "\"";    }

function getQmlObject(imports,qmlStr,parent)
{
    var str = ""
    for(var i in imports)
        str += "import " + imports[i] + ";\n"


    var obj = Qt.createQmlObject(str + qmlStr,parent,null)
    return obj
}
