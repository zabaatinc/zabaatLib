import QtQuick 2.4
import "moment.js" as M
import Zabaat.Utility 1.0

pragma Singleton
QtObject {

    //todo, moment is weird, try to turn it in to a QMl so we can get intellisense!
//    function create(args){
//        var m = M.moment.apply(this,args);
//        return m;
//    }

//    function daysInMonth(year,month){
//        var m = create()
//        return m.daysInMonth(year,month)
//    }
    property QtObject __logic : QtObject {
        id : logic

        function create(args){
            return new M.m();
        }
    }

    function now(){
        var m = logic.create()
        _.each(_.keys(m), function(a){
            console.log(a)
        })
        return m;
    }







}
