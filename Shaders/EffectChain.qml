import QtQuick 2.4
Item {
    id : rootObject
    property real  dividerValue : 0.5
    property variant source
    property var   model      : null  //expects listModel of name and value
    onModelChanged            : privates.modelChangeFunction()

    function set(name,value){
        console.log("setting", name, "to", value)
        if(privates.effectMap && privates.effectMap[name]){
            console.log("FOUND")
            var effectList = privates.effectMap[name]
            for(var e in effectList){
                var item = effectList[e]
                if(item.set)      item.set(value);
                else              item.value = value;
            }
        }
    }


    QtObject {
        id : privates
        property var effectArr : []
        property var effectMap : ({})
        property bool hasInit  : rootObject.source ? true : false
        onHasInitChanged: if(hasInit)
                              modelChangeFunction()

        function modelChangeFunction(){
            if(!hasInit || model === null || typeof model === 'undefined')
                return

            effectsContainer.clean()
            effectArr = []
            effectMap = {}

            for(var i = 0; i < model.count; i++){
                var item = model.get(i)
//                console.log("creating" , item.name)
                var obj = effectFactory.createObject(effectsContainer)
                effectArr.push(obj)
                if(typeof effectMap[item.name] === 'undefined') effectMap[item.name] = [obj]
                else                                            effectMap[item.name].push(obj)


                obj.index      = i
                obj.sourceItem = i === 0 ? rootObject.source : effectArr[i - 1].chainPtr
                obj.source     = item.name + ".qml"

            }
        }
    }
    Item {
        id : effectsContainer
        width : source === null || typeof source === 'undefined' ? 0 : source.width
        height: source === null || typeof source === 'undefined' ? 0 : source.height
        function clean(){
            visible = false;
            for(var i = children.length - 1; i >= 0; i--){
                var child = children[i]
                child.destroy()
                child.parent = null
            }
            children = []
            visible = true;
        }
    }
    Component {
        id : effectFactory
        Loader {
            id : effectLoader
            anchors.fill: effectsContainer ? effectsContainer : null
            property int     index      : -1
            property variant sourceItem
            property var     chainPtr   : effectLoader.item && effectLoader.item.chainPtr ? effectLoader.item.chainPtr : null
            property var     value      : rootObject && rootObject.model && index !== -1 ?
                                          rootObject.model.get(index).value : null

            onLoaded : {
                console.log(source)
                item.source       = effectLoader.sourceItem ?  effectLoader.sourceItem : null
                item.anchors.fill = effectLoader
                item.value        = Qt.binding(function() { return effectLoader ? effectLoader.value : 0  })
                item.dividerValue = Qt.binding(function() { return rootObject? rootObject.dividerValue :0 })
            }
        }


    }
}

