import QtQuick 2.4
import QtQuick.Controls 1.4
import "../"
Item {

    Column {
        Button {
            text : "Now"
            onClicked : console.log(Moment.now())
        }

        Button {
            text : "days in month"
            onClicked : {
//                console.log(Moment.daysInMonth(2009,"feb"))
            }
        }
    }



}
