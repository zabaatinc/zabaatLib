import QtQuick.Controls 1.4
import QtQuick 2.5
import "../Lodash"
ComboBox {
    model : ['==','!=','>','>=','<','<=', 'contains']
    function set(op){
        var idx = _.indexOf(model,op);
        if(idx !== -1)
            currentIndex = idx;
    }
}
