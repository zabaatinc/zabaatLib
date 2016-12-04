import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
Item {
    id : rootObject
    property var    model
    property alias  menuObj : rootObject.model
    property string menuItemState
    property var    menuSortFn
    property alias  spacing : lv.spacing

    property real   menuItemHeight
    property alias cellHeight : rootObject.menuItemHeight
    onModelChanged:  logic.assignModel();
    QtObject {
        id : logic
        function assignModel(){
            if(!model)
                return false;

            var arr = Lodash.keys(model);
            if(Lodash.isFunction(menuSortFn))
                arr.sort(menuSortFn);

            lv.model = arr;
            return true;
        }
    }

    ListView {
        id : lv
        anchors.fill: parent
        delegate: ZButton {
            id : lvInstance
            width : rootObject.width
            height : menuItemHeight
            state : Lodash.isObject(v) && Lodash.isString(v.state)? v.state : menuItemState
            property string icon : Lodash.isObject(v) && Lodash.isString(v.icon)? v.icon + " " : ""
            property var v : rootObject && rootObject.model ? rootObject.model[modelData] : null;
            text : modelData
            onClicked : {
                var fn = Lodash.isFunction(v) ? v : Lodash.isObject(v) && Lodash.isFunction(v.fn) ? v.fn : null;
                if(Lodash.isFunction(fn))
                    fn();
            }
            ZText {
                anchors.fill: parent
                anchors.margins: 5
                state : parent.state + "-transparent-tleft"
                text : parent.icon
                visible : parent.icon
            }
        }
        interactive: height < contentItem.height
    }


}
