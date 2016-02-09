import QtQuick 2.0
QtObject {
    function stdTimeZoneOffset() {
        var today = new Date()

        var jan = new Date(today.getFullYear(), 0, 1);
        var jul = new Date(today.getFullYear(), 6, 1);
        return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
    }
    function getDateTimeZone(date) {
        //return date.getTimezoneOffset() < stdTimezoneOffset();
//            console.log(date.getTimezoneOffset(), stdTimeZoneOffset(), stdTimeZoneOffset() - date.getTimezoneOffset() )
        return stdTimeZoneOffset() - date.getTimezoneOffset();
    }


}
