import QtQuick 2.5
import "Lodash"
QtObject {
    property var model

    function get(strOrArr) {
        if(!model)
            return null;
    }


    property Item logic : Item {
        id : logic

        Component {
            id : vmFactory

        }
    }


}
