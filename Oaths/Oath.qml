import QtQuick 2.5
import "Lodash"
Item {
    readonly property alias isFulfilled : priv.isFulfilled
    readonly property alias isRejected  : priv.isRejected
    readonly property alias resolveWhen : priv.resolveWhen
    readonly property alias rejectWhen  : priv.rejectWhen
    readonly property bool  isSettled   : isFulfilled || isRejected

    signal fulfilled(var value);
    signal rejected(var reason);
    signal settled(var value);

    function resolve(value){
        priv.blockSignals = true;

        priv.resolveWhen = true;


        priv.blockSignals = false;
    }


    function reset(){
        priv.blockSignals = true;

        priv.isFulfilled = priv.isRejected = priv.resolveWhen = priv.rejectWhen = false;

        priv.blockSignals = false;
    }


    QtObject {
        id: priv
        property bool blockSignals : false;

        property bool resolveWhen
        property bool rejectWhen
        property bool isFulfilled
        property bool isRejected

        onIsFulfilledChanged: if(isFulfilled) {

                              }

        onIsRejectedChanged: if(isRejected) {

                             }


        onResolveWhenChanged: if(resolveWhen) {

                              }

        onRejectWhenChanged: if(rejectWhen) {

                             }




    }

}
