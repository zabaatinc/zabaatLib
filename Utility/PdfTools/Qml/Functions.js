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


function replaceLine(str, searchTerm, newLine, numReplaces)
{
    var strarr = str.split('\n')
    var replaced = 0
    for(var s in strarr)
    {
        if(strarr[s].indexOf(searchTerm) != -1)
        {
            strarr[s] = newLine
            replaced++
            if(numReplaces && replaced >= numReplaces)
                break
        }
    }
     return strarr.join('\n')
}



function matchFromStart(inStr,bigStr)
{
       inStr = inStr.toLowerCase()
       bigStr = bigStr.toLowerCase()

       if(inStr.length > 0 && bigStr.length > 0 && bigStr.length >= inStr.length)
       {
           for(var i = 0; i < inStr.length; i++)
           {
               if(inStr.charAt(i) != bigStr.charAt(i))
               {
                   return false
               }
           }
           return true
       }
       return false
}


function removeImports(str)
{
    var strarr = str.split('\n')
    var remArr = []
    for(var s in strarr)
    {
        if(strarr[s].indexOf("import") != -1)
            remArr.push(s)
        else
            break
    }

    for(s in strarr)
    {
        if(strarr[s].indexOf("ZPage") != -1)
        {
            remArr.push(s)
            remArr.push(s + 1)
            remArr.push(strarr.length - 1)
            break
        }
    }

    for(var i = remArr.length -1; i >= 0; i--)
        strarr.splice(i,1)



    return strarr.join('\n')
}
