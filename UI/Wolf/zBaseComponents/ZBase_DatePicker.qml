import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0
import Zabaat.Misc.Global 1.0


/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Uses ZTextBox and a Calendar to pick a date! The ZTextBox has an input Validator on it, which makes inputting invalid dates impossible.
    \code
        ZBase_DatePicker
        {
            id : startDatePicker
            labelName : "startDate"
            width : parent.width/2 - dateRow.spacing
            winOffsetX : offsetX
            winOffsetY : offsetY
        }
    \endcode
*/
ZBase_TextBox
{
    id : rootObject

    /*! The selected date. This is a Javascript date object. Defaults to \c new Date() */
    property date selectedDate                 : new Date()
    onSelectedDateChanged:
    {
        priv.selectedDay   = selectedDate.getDate()
        priv.selectedMonth = selectedDate.getMonth()  //apparently returns 0 based!
        priv.selectedYear  = selectedDate.getFullYear()

        priv.disableLoop = true
        rootObject.text          = Qt.formatDate(selectedDate, "MM/dd/yyyy")
        calendar.selectedDate = selectedDate
        priv.disableLoop = false


        if(priv.init !== 1)
            priv.init++
    }
    property var self : this

    /*! A quick way to get the selected Day. This is Readonly and it returns an int. -1 if nothing is selected.    */
    readonly property alias selectedDay        : priv.selectedDay

    /*! A quick way to get the selected Month. This is Readonly and it returns an int. -1 if nothing is selected.   */
    readonly property alias selectedMonth      : priv.selectedMonth

    /*! A quick way to get the selected Year. This is Readonly and it returns an int.  -1 if nothing is selected.  */
    readonly property alias selectedYear       : priv.selectedYear

    /*! The background color of the boxes in the Calendar which display the Current Month  */
    property color sameMonthDateTextColor      : "#444"

    /*! The background color of the boxes in the Calendar which don't display the Current Month  */
    property color differentMonthDateTextColor : "#bbb"

    /*! The background color of the box in the Calendar which displays the current Selected Date  */
    property color selectedDateColor           : "#3778d0"

    /*! The hover color on the Calendar when you mouse over the dates  */
    property color hoverDateColor              : "orange"

    /*! The color of invalid dates!  */
    property color invalidDatecolor            : "#dddddd"

    /*! The current status of this Component. automaically becomes ready after creation and setting the text of the ZTextBox   */
    property int   status                      : Component.Loading

    /*! Defaults to making calendar visible on ZTextBox focus and ZTextBox position change. Defaults to \c win ? win.visible : false  */
    property bool  calendarVisible             : win ? win.visible : false

    /*! Allows for deeper embedding of this object within windows other than the main one. Should give this the offset of the window this is in (if not the main one). Defaults to \c 0  */
    property int winOffsetX : 0

    /*! Allows for deeper embedding of this object within windows other than the main one. Should give this the offset of the window this is in (if not the main one). Defaults to \c 0 */
    property int winOffsetY : 0

    onCursorPositionChanged:  if(priv.init && !priv.disableLoop && dTextInput.focus && win) win.visible = true
    onGotFocus             :  win && !priv.disableLoop  &&  priv.init? win.visible = true  :  {}
    onLostFocus            :  win && !priv.disableLoop  ?   win.visible = false :  {}
    onClick                :  win && !priv.disableLoop  &&  priv.init? win.visible = true  :  {}

    /*! The label to display for this date picker. Defaults to \c "" */
    labelName : ""
    Component.onCompleted: { text = (selectedDate.getMonth() + 1) + "/" + selectedDate.getDate() + "/" + selectedDate.getFullYear(); priv.disableLoop = false; status = Component.Ready }
    dTextInput.validator: RegExpValidator  { regExp:  /^([1-9]|0[1-9]|1[012])[- /.]([1-9]|0[1-9]|[12][0-9]|3[01])[- /.]\d\d\d\d$/ }

    property var uniqueProperties : ["text","fontColor","outlineColor","font","fontName","labelName","padding", "sameMonthDateTextColor", "differentMonthDateTextColor", "selectedDateColor", "hoverDateColor", "invalidDateColor", "winOffsetX", "winOffsetY"]
    property var uniqueSignals	  : ({gotFocus:[], lostFocus:[] })

    onTextChanged:
    {
        if(!priv.disableLoop)
        {
            var date = Date.parse(text)
            if(!isNaN(date))
            {
                var dateObj = new Date()
                dateObj.setTime(date)
                selectedDate = dateObj
            }
        }
    }

    QtObject
    {
        id : priv
        property bool disableLoop   : true
        property date today         : new Date()

        property int selectedDay    : -1
        property int selectedMonth  : -1
        property int selectedYear   : -1
        property int init          : -1

        onSelectedMonthChanged: if(selectedMonth != -1) calendar.visibleMonth = selectedMonth
        onSelectedYearChanged:  if(selectedYear  != -1) calendar.visibleYear  = selectedYear
    }


    /*! The container for the Calendar. Perhaps there is a better way to have something always on top but for now, we will use a Window Object.  */
    Item
    {
        id : win

        width  : rootObject.width
        height : width * 0.9
        visible : false
        enabled : visible
        y : rootObject.height

        Calendar
        {
            id: calendar
            anchors.fill: parent
            frameVisible: true
            selectedDate: new Date()

            style: CalendarStyle
            {
                dayDelegate: Rectangle
                {
                        color : calendar.dateEquals(calendar.selectedDate, styleData.date) ? rootObject.selectedDateColor : 'white'
                        clip : false

                        Text
                        {
                            x:parent.x +5
                            y:parent.y +5
                            text: styleData.date.getDate()
                            color : styleData.visibleMonth ? rootObject.sameMonthDateTextColor : rootObject.differentMonthDateTextColor;
                            font.pointSize: 12
                            font.bold:true
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered : parent.color = rootObject.hoverDateColor
                            enabled : win.visible

                            onExited  : parent.color = Qt.binding( function() { return calendar.dateEquals(calendar.selectedDate, styleData.date) ? rootObject.selectedDateColor : 'white' } )
                            preventStealing: false
                            onClicked:
                            {
                                priv.disableLoop         = true

                                calendar.selectedDate    = styleData.date
                                rootObject.selectedDate  = calendar.selectedDate
                                rootObject.text          = Qt.formatDate(calendar.selectedDate, "MM/dd/yyyy")
                                win.visible              = false

                                priv.disableLoop         = false
                            }
                        }
                }
            }

            function dateEquals(date1, date2)
            {
                if(date1.getDate() == date2.getDate() && date1.getMonth() ==  date2.getMonth() && date1.getFullYear() == date2.getFullYear())
                    return true
                return false
            }

        }
    }



//    Rectangle{
//        color : 'transparent'
//        border.width: 4
//        anchors.fill: parent
//    }

}
