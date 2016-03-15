import QtQuick 2.4
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0
Item {

    Column {
        Button {
            text : "create moment"
            onClicked : {
                var m = Moment.moment(new Date())
                console.log(m)
            }
        }

        Button {
            text : "days in month"
            onClicked : {
                console.log(Moment.daysInMonth(2009,"feb"))
            }
        }
    }



}
