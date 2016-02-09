import QtQuick 2.4
import Zabaat.Misc.Global 1.0
//import QtQuick.Controls 1.2

/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Creates a radial display of values to be picked. Comes with quite a bit of configuration options. This is preconfigured to deal with time in am and pm :)
    \code
        ZBase_TimePicker
        {

        }
    \endcode

*/
ZBase_RadialPicker
{
    id : rootObject
    property var self : this
    model                             : [12,1,2,3,4,5,6,7,8,9,10,11]

    property double   textOpacity     : 1
    readonly property alias timeStr   : row.timeStr
    readonly property alias  amPm     : apBtn.text
    readonly property alias   time    : apBtn.time
    maxMagnitude                      : 1
    enableMagnitudeChange             : false

    property var uniqueProperties :  ['model','digitalOnly','enableMagnitudeChange','maxMagnitude','magnitude','value','extraHoverPx','amPm']
    property var uniqueSignals    : ({blobClicked  :[]})

    Row {
        id     : row
        width           : apBtn.width + timeReporter.width + spacing
        height          : parent.height/5
        anchors.centerIn: parent
        spacing : 5
        property string timeStr : timeReporter.text + " " + apBtn.text

        ZBase_TextBox {
            id            : timeReporter
            width         : rootObject.width/3
            height        : parent.height
            opacity       : textOpacity
            font.pointSize: 24


            property string hrs  : "12"
            property string mins : "00"

            text : hrs + ":" + mins
            enabled: false
        }
        ZBase_Button  {
            id               : apBtn
            width            : timeReporter.width/2
            height           : parent.height
            text             : "AM"
            opacity          : textOpacity
            onBtnClicked     : {
                if(text == "AM")    text = "PM"
                else                text = "AM"
            }

            property date time : extractTime()
            function extractTime(){
                var date = new Date()
                var val  = Number(rootObject.value)

                var hrs  = Math.floor(val)
                timeReporter.hrs = hrs < 10 ? "0" + hrs : hrs

                var mins = Math.round((val - Math.floor(val)) * 60)
                timeReporter.mins = mins < 10 ? "0" + mins : mins

                if(text == "PM")
                    hrs += 12

                date.setHours(hrs,mins,0,0)
                return date
            }
        }
    }

    function setTime(time) {
        var hrs = time.getHours()
        if(hrs > 12)
        {
            apBtn.text = "PM"
            hrs -= 12
        }
        else
            apBtn.text = "AM"

        var mins = time.getMinutes()
        rootObject.value = hrs + mins/60
    }

}

