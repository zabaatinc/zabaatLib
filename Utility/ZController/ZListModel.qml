import QtQuick 2.0
ListModel
{
    id  : rootObject
        property var map       : []
        property var memoryMap : []
        function getFromMap(mapStr)                { if(map[mapStr]) return  map[mapStr].get(); return "N/A"            }
        function setToMap(mapStr,value, dontSend)  { if(map[mapStr])         map[mapStr].set(value,dontSend)            }
        function setVal(location, value, dontSend) { if(memoryMap[location]) memoryMap[location].set(value,dontSend)    }

        function getById(id)
        {
            for(var i = 0; i < rootObject.count; i++)
            {
                var elem = rootObject.get(i)
                if(elem.id && id === elem.id)
                    return elem
            }
            return null
        }

//        dynamicRoles: true
}
