import QtQuick 2.5
QtObject {
    id : rootObject
    signal logAdded(var log);
    signal warningAdded(var warning);
    signal errorAdded(var error);


    function add(type, fileAndLine, text) {
        var logObject = { file : "", line : "", ts : new Date(), text : text  }
        if(typeof fileAndLine === 'string') {
            fileAndLine = fileAndLine.split("::");
            logObject.file = fileAndLine[0];
            logObject.line = fileAndLine[1];
        }

        switch(type) {
            case "log"     : _members.logs.push(logObject);
                             return logAdded(logObject);
            case "warning" : _members.warnings.push(logObject);
                             return warningAdded(logObject);
            case "error"   : _members.errors.push(logObject);
                             return errorAdded(logObject);
        }
    }


    function logs()     { return _members.logs;      }
    function warnings() { return _members.warnings ; }
    function errors()   { return _members.errors ;   }

    property QtObject _members: QtObject {
        id : _members
        property var logs     : []
        property var warnings : []
        property var errors   : []
    }

}
