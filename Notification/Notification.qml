import QtQuick 2.5
import Zabaat.Base 1.0
pragma Singleton

//manages a list of notification list models
QtObject {
    id : rootObject
    property int unseenNotifications : 0
    signal newGroupAdded(string group);

    function add(group, message, time_opt) {
        time_opt = time_opt || new Date();

        var lm = logic.groupMap[group]
        if(!lm) {
            lm               = lmGen.createObject(null);
            lm.unseenChanged.connect(logic.countTotalUnseen)
            lm.objectName    = group;

            logic.groupMap[group] = lm;
            rootObject.newGroupAdded(group);
        }

        lm.append({msg : message, time : time_opt, seen : false});
    }
    function getNotificationList(groupName) {
        if(!groupName)
            return null;

        return logic.groupMap[groupName];
    }
    function getAllNotificationLists() {
        return logic.groupMap;
    }

    property Item logic : Item {
        id : logic
        property var groupMap : ({})

        function countTotalUnseen() {
            var unseen = 0;
            Lodash.each(groupMap, function(v) {
                unseen += v.unseen;
            })
            rootObject.unseenNotifications = unseen;
        }

        Component {
            id : lmGen;
            ListModel {
                id : lmDel
                property int unseen : 0;
                onDataChanged : lmDel.unseen = countUnseen();
                onRowsInserted: lmDel.unseen = countUnseen();
                function countUnseen(){
                    var unseen = 0;
                    for(var i = 0; i < count; i++) {
                        var item = get(i);
                        if(!item.seen)
                            unseen++
                    }
                    return unseen;
                }
            }
        }
    }


}
