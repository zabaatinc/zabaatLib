import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Window 2.0
import Zabaat.UI.Wolf 1.0


ApplicationWindow
{
    id : mainWindow
    width: Screen.width
    height: Screen.height
    visible : true

    property var dataSection : ({ persons : {programmers : ["Shahan","Brett"]}, cars : ["Infinity","Prius","Chevy"] } )

    Loader
    {
        id : loader
        anchors.fill: parent
        source : "mainMenu.qml"

        onSourceChanged : whBinding()
        Component.onCompleted: whBinding()


        function whBinding()
        {
            if(item)
            {
                item.width  = Qt.binding(function() { return width } )
                item.height = Qt.binding(function() { return width } )
            }
        }
    }

    function loadPage(name, args)
    {
        loader.data = null
        loader.setSource(name)

        if(args)
        {
            for(var i = 0; i < args.length; ++i)
                loader.item[args[i].name] = args[i].value
        }
    }

    function mainDataSection()    {        return dataSection    }



}

