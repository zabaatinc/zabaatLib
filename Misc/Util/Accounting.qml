import QtQuick 2.4
import 'accounting.js' as Acct

QtObject{
    id : accountingLib

    property var settings : Acct.settings

    function unformat(valueOrArr, decimal)                                     { return Acct.unformat.apply(this, arguments) }
    function toFixed(value, precision)                                         { return Acct.apply(this,precision) }
    function formatNumber(number, precision, thousand, decimal)                {  return Acct.formatNumber.apply(this, arguments) }
    function formatMoney(number, symbol, precision, thousand, decimal, format) { return Acct.formatMoney.apply(this, arguments)   }
    function formatColumn(list, symbol, precision, thousand, decimal, format)  { return Acct.formatColumn.apply(this,arguments) }



}
