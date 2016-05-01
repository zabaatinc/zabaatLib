import QtQuick 2.3
import Zabaat.Misc.Global 1.0

//version 1.0

//todo - possibly pass in hero object so we can draw portrait / bind to the effects that are on the hero state (i.e. treat this as a delegate to the hero model)

Item{
    id:rootItem
    width : parent.width/8
    height: width / 5

    property alias total:                            mainBar.total
    property alias barColor:                      mainBar.barColor
    property alias showText:                     mainBar.showText
    property alias enableFancyContainer :   mainBar.enableFancyContainer //the flashing red border if the life is low
    property alias radius:                          mainBar.radius
    property alias value:                           mainBar.value
    property alias showActualValues:            mainBar.showActualValues
    property alias readoutGain:                 mainBar.readoutGain
    property alias bar : mainBar

    property bool _initialized : false

    //initialization values only, if you change these most likely will have to call the draw function again?
    property int setValue: total  //DO NOT USE THIS directly  unless you want to bypass all logic of the shifty bars

    onSetValueChanged: _initialized ? console.log("mr. derp... use the 'damage' or 'heal' function instead") : mainBar.value = setValue // initialization use only!

    Bar{
        id:mainBar
        barColor    : "dark green"
        maxColor   : "green"
        minColor   :  ZGlobal.style.danger
        enableFancyContainer: true
        enableDamageIndicator: true
        radius:10
    }

    function damage(amount){
        mainBar.takeDamage(amount);
    }
    function heal(amount){
        mainBar.takeHeal(amount);
    }

    Component.onCompleted: {
        _initialized = true
    }
}
