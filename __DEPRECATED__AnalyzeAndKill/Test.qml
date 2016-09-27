import QtQuick 2.5
import Zabaat.Utility 1.0
Item {
    id : rootObject

    Component.onCompleted:  {
        var m = Moment.create("12/12/2006");
        var m2 = Moment.create("12/12/2008");

        var dur = Moment.duration(Moment.diff(m,"year",true,m2) , "year");
        console.log(dur, dur.humanize());
    }

}
