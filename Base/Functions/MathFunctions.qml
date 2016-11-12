import QtQuick 2.0
QtObject {

    function isInt(term) {
        var n = Number(term);
        return !isNaN(n) && n % 1 === 0;
    }

    function isFloat(term) {
        var n = Number(term);
        return !isNaN(n) && n % 1 !== 0;
    }

}
