import QtQuick 2.4
import Zabaat.UI.Wolf 1.0
import Zabaat.Misc.Global 1.0
import QtQuick.Layouts 1.1

GridLayout
{
    id : rootObject
    property var    model: []
    property string checkedItem : ""
    property color  textColor   : 'black'
    property int size           : 32
    clip : true

    onModelChanged: updateModel()

    function updateModel()
    {
        if(model && model.length > 0)
        {
            clear()
            for(var i = 0; i < model.length; i++)
            {
                var chkbox                  = ZGlobal.functions.getQmlObject(['QtQuick 2.4','Zabaat.UI.Wolf 1.0'], 'ZCheckbox { property int index : -1}', rootObject)
                chkbox.index                = rootObject.children.length
                chkbox.label.text           = model[i]
                chkbox.size                 = rootObject.size
                chkbox.isRadioButton        = true
                chkbox.textColor            = Qt.binding(function() { return rootObject.textColor})
                chkbox.click.connect(clickFunc)         //we can expect to always get checked!
            }
        }
    }

    function clear()
    {
        for(var c in children.length)
        {
            var child = children[c]
            child.parent = null
            child.destroy()
        }
        children = []
    }

    function deselectAll()
    {
        for(var c in children)
        {
            var child = children[c]
            child.state = 'normal'
        }
    }

    function clickFunc(checked,label, thisObj)
    {
        deselectAll()
        thisObj.state = 'checked'
        checkedItem   = label
    }


}
