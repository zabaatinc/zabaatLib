import QtQuick 2.5
import Zabaat.Base 1.0
import Zabaat.Utility.SubModel 1.1
pragma Singleton

//manages a list of notification list models
QtObject {
    id : rootObject
    property alias unseen         : masterMessageList.unseen;
    property alias groupNamesList : groupNames;
    signal newGroupAdded(string group);

    function add(group, message, time_opt) {
        time_opt = time_opt || new Date();

        masterMessageList.append({ msg   : message,
                                   time  : time_opt,
                                   group : group,
                                   seen  : false
                                 })

        if(!groupNames.exists(group)) {
            groupNames.append({name:group})
            logic.createNewSubmodel(group);
            newGroupAdded(group);
        }
    }

    //generates a zsubmodel if we don't have one and passes it along
    function getNotificationList(group) {
        var submodel = logic.submodelMap[group]
        if(submodel)
            return submodel;

        return logic.createNewSubmodel(group);
    }



    property Item logic : Item {
        id : logic
        property var submodelMap : ({ "All" : masterMessageList })


        function createNewSubmodel(group) {
            //otherwise, we have to generate a submodel here.
            var submodel = submodelGenerator.createObject(null);
            submodel.filterFunc = function(a) {
                return a.group === group;
            }

            logic.submodelMap[group] = submodel;
        }
        function countTotalUnseen(lm) {
            var count = 0;
            for(var i = 0; i < lm.count; ++i) {
                var messageItem = lm.get(i);
                if(!messageItem.seen)
                    count++;
            }
            return count;
        }
        function sortFn_dateDesc(a,b) {
            return a.time.getTime() - b.time.getTime();
        }


        //contains all the messages
        //each message has these fields:
        //group
        //msg
        //time
        //color <optional>
        ListModel {
            id : masterMessageList
            property int unseen
            onRowsInserted: unseen = logic.countTotalUnseen(this);
            onDataChanged : unseen = logic.countTotalUnseen(this);
        }


        ListModel {
            id : groupNames
            dynamicRoles: true;
            Component.onCompleted: {
                append({name : "All"})
            }

            function exists(group) {
                for(var i = 0; i < count; i++) {
                    var item = get(i);
                    if(item.name === group)
                        return true
                }
                return false;
            }
        }


        Component {
            id : submodelGenerator
            ZSubModel {
                property int unseen
                sourceModel: masterMessageList;
                sortFunc: logic.sortFn_dateDesc;
                onRowsInserted: unseen = logic.countTotalUnseen(this);
                onDataChanged : unseen = logic.countTotalUnseen(this);
            }
        }


    }


}
