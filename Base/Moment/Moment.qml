import QtQuick 2.4
import "moment.js" as M

pragma Singleton
QtObject {
    objectName: "Moment.qml"
    //todo, moment is weird, try to turn it in to a QMl so we can get intellisense!
    function create(args){return new M.moment(args); }
    function m(obj){ return obj ? obj : create(obj); }

    //GET + SET
    function now(setter_opt){
        if(typeof setter_opt === 'function')
            return M.moment.now(setter_opt);
        return M.moment.now();
    }
    function millisecond(ms, opt_momentObject)  { return m(opt_momentObject)[arguments.callee.name](ms);      }
    function milliseconds(ms, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](ms);      }
    function second(seconds, opt_momentObject)  { return m(opt_momentObject)[arguments.callee.name](seconds); }
    function seconds(seconds, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](seconds); }
    function minute(min, opt_momentObject)      { return m(opt_momentObject)[arguments.callee.name](min);     }
    function minutes(min, opt_momentObject)     { return m(opt_momentObject)[arguments.callee.name](min);     }
    function hour(num, opt_momentObject)        { return m(opt_momentObject)[arguments.callee.name](num);     }
    function hours(num, opt_momentObject)       { return m(opt_momentObject)[arguments.callee.name](num);     }
    function date(num, opt_momentObject)        { return m(opt_momentObject)[arguments.callee.name](num);     }
    function dates(num, opt_momentObject)       { return m(opt_momentObject)[arguments.callee.name](num);     }
    function day(numOrStr, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](numOrStr);}
    function days(numOrStr, opt_momentObject)   { return m(opt_momentObject)[arguments.callee.name](numOrStr);}
    function weekday(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function isoWeekday(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function dayOfYear(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function week(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function weeks(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function isoWeek(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function isoWeeks(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function month(numOrStr, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](numOrStr);}
    function months(numOrStr, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](numOrStr);}
    function quarter(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function year(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function years(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function weekYear(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function isoWeekYear(num, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](num);}
    function weaksInYear(opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name]();}
    function isoWeeksInYear(opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name]();}
    function get(strProperty, opt_momentObject)    { return m(opt_momentObject)[arguments.callee.name](strProperty);}
    function set(str,num,opt_momentObject)  { return m(opt_momentObject)[arguments.callee.name](str,num); }
    function setUsingObj(obj, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](obj); }
    function max(momentArr) { return M.moment.max(momentArr);  }
    function min(momentArr) { return M.moment.min(momentArr);  }

    //Manipulate
    function add(numOrObj, prop, opt_momentObject) {
        if(typeof numOrObj === 'number')
            return m(opt_momentObject)[arguments.callee.name](numOrObj,prop);
        else
            return m(opt_momentObject)[arguments.callee.name](numOrObj);
    }
    function subtract(numOrObj, prop, opt_momentObject) {
        if(typeof numOrObj === 'number')
            return m(opt_momentObject)[arguments.callee.name](numOrObj,prop);
        else
            return m(opt_momentObject)[arguments.callee.name](numOrObj);
    }
    function startOf(str, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](str);    }
    function endOf(str, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](str);    }
    function local( opt_momentObject) { return m(opt_momentObject)[arguments.callee.name]();    }
    function utc( opt_momentObject) { return m(opt_momentObject)[arguments.callee.name]();    }
    function utcOffset(numOrStr, bool, opt_momentObject) {
        if(!bool)
            return m(opt_momentObject)[arguments.callee.name](numOrStr);
        return m(opt_momentObject)[arguments.callee.name](numOrStr,bool);
    }
    function zone(numOrStr, opt_momentObject) {return m(opt_momentObject)[arguments.callee.name](numOrStr); }

    //Display
    function format(str, str2, opt_momentObject) {
        if(str2 === undefined || str2 === null)
            return m(opt_momentObject)[arguments.callee.name](str);
        return m(opt_momentObject)[arguments.callee.name](str,str2);
    }
    function fromNow(nosuffix, opt_momentObject) {return m(opt_momentObject)[arguments.callee.name](nosuffix); }
    function from(momentOrStrOrNumberOrDateOrArr, nosuffix, opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,nosuffix);
    }
    function toNow(nosuffix, opt_momentObject) {return m(opt_momentObject)[arguments.callee.name](nosuffix); }
    function to(momentOrStrOrNumberOrDateOrArr,nosuffix, opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,nosuffix);
    }
    function calendar(referenceTime, formats, opt_momentObject) {
        if(!formats)
            return m(opt_momentObject)[arguments.callee.name](referenceTime);
        return m(opt_momentObject)[arguments.callee.name](referenceTime,formats);
    }
    function diff(momentOrStrOrNumberOrDateOrArr, prop, dontRound, opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop,dontRound);
    }
    function valueOf(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function unix(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function daysInMonth(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toDate(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toArray(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toJSON(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toISOString(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toObject(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function toString(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }

    //QUERY
    function isBefore(momentOrStrOrNumberOrDateOrArr,prop,opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop);
    }
    function isSame(momentOrStrOrNumberOrDateOrArr,prop,opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop);
    }
    function isAfter(momentOrStrOrNumberOrDateOrArr,prop,opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop);
    }
    function isSameOrBefore(momentOrStrOrNumberOrDateOrArr,prop,opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop);
    }
    function isSameOrAfter(momentOrStrOrNumberOrDateOrArr,prop,opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentOrStrOrNumberOrDateOrArr,prop);
    }
    function isBetween(momentlike1, momentlike2, units, inclusivity, opt_momentObject) {
        return m(opt_momentObject)[arguments.callee.name](momentlike1, momentlike2, units, inclusivity);
    }
    function isDST(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function isDSTShifted(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function isLeapYear(opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](); }
    function isMoment(obj) { return M.moment.isMoment(obj); }
    function isDate(obj) { return M.moment.isDate(obj); }

    function locale(strOrStrArr, obj, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](strOrStrArr, obj);}

    function localeData()              { return M.moment.localeData();          }
    function localeMonths()            { return localeData().months()         ; }
    function localeMonthsShort()       { return localeData().monthsShort()    ; }
    function localeMonthsParse()       { return localeData().monthsParse()    ; }
    function localeWeekdays()          { return localeData().weekdays()       ; }
    function localeWeekdaysShort()     { return localeData().weekdaysShort()  ; }
    function localeWeekdaysMin()       { return localeData().weekdaysMin()    ; }
    function localeWeekdaysParse()     { return localeData().weekdaysParse()  ; }
    function localeLongDateFormat()    { return localeData().longDateFormat() ; }
    function localeIsPM()              { return localeData().isPM()           ; }
    function localeMeridiem()          { return localeData().meridiem()       ; }
    function localeCalendar()          { return localeData().calendar()       ; }
    function localeRelativeTime()      { return localeData().relativeTime()   ; }
    function localePastFuture()        { return localeData().pastFuture()     ; }
    function localeOrdinal()           { return localeData().ordinal()        ; }
    function localePreparse()          { return localeData().preparse()       ; }
    function localePostformat()        { return localeData().postformat()     ; }
    function localeWeeks()             { return localeData().weeks()          ; }
    function localeInvalidDate()       { return localeData().invalidDate()    ; }
    function localeFirstDayOfWeek()    { return localeData().firstDayOfWeek() ; }
    function localeFirstDayOfYear()    { return localeData().firstDayOfYear() ; }

    function defineLocale(str,obj)     { return M.moment.defineLocale(str,obj); }
    function updateLocale(str,obj)     { return M.moment.updateLocale(str,obj); }
    function calendarFormat(fn) {
        if(typeof fn === 'function')
            M.moment.calendarFormat = fn;
    }


    function relativeTimeThreshold(unit, limit) {
        return M.moment.relativeTimeThreshold(unit,limit);
    }
    function relativeTimeRounding(retainValue) {
        return M.moment.relativeTimeRounding(retainValue);
    }

    //Durations
    function duration(numberOrObj,string, opt_momentObject) { return M.moment.duration(numberOrObj,string);    }
    function humanize(bool, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](bool);    }
//    function duration(numberOrObj,string, opt_momentObject) { return m(opt_momentObject)[arguments.callee.name](numberOrObj,string);    }











}
