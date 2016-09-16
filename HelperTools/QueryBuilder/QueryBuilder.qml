import QtQuick 2.5
import "Lodash"
import "QueryBuilderComponents"
//provides a nice gui to create query objects
//
Item {
    id : rootObject
    height : mainGroup.height

    QueryGroup {
        id : mainGroup
        width : parent.width
        canBeDeleted : false
        availableVars : ["Status","Name","Family","Tier"]
    }



}
