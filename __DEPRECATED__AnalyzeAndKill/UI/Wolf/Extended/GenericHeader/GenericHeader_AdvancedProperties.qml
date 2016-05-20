import QtQuick 2.0
QtObject{
    id : adv
    property var    fields_typeOverride      : null
    property var    fields_override          : null
    property var    global_override          : null
    property var    fields_valueField        : null
    property var    fields_addtlQml          : null
    property var    fields_enabled           : null
    property var    fields_ignoreProperties  : null
    property var    fields_dontBind          : null

    property string itemType                 : 'ZTextBox'
    property string valueField               : "text"
    property string additionalItemProperties : ""
    property bool   itemIsEnabled            : false

}

