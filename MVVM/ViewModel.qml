import QtQuick 2.5
QtObject {
    id : rootObject
    //Add a qml parent, incrementing the parentCount, when the parent dies or no longer wnats this

    function addParent(qmlitem) {
        var uniqueStr = qmlitem.toString();
        if(!priv.parentNames)
            priv.parentNames = {}

        if(!priv.parentNames[uniqueStr]) {
            priv.parentCount++;
            priv.parentNames[uniqueStr] = true;

            if(!priv.hasInit)
                priv.hasInit = true;

            qmlitem.Component.destruction.connect(function() {
                delete priv.parentNames[uniqueStr]
                priv.parentCount--
            })
        }
    }
    property QtObject __priv : QtObject {
        id : priv
        property var parentNames : ({})
        property int parentCount : 0
        onParentCountChanged: if(parentCount === 0 && hasInit) {
                                  rootObject.destroy()
                              }

        property bool hasInit : false;
    }
}
