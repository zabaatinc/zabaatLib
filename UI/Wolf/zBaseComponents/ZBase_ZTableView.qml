import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "./Functions.js" as Functions

TableView
{
    //This is just so our component menu can see what this is from the sidebar.
    Text
    {
        text : "ZTableView"
        font.pointSize: 12
        visible : model ? false : true
        width : rootObject.width
    }

    id:tableView
    property var self : this
    property string name : "" //TODO - use this to setup the name of the table so it knows what settings to get for itself or something
    property int status : Component.Loading

    property var hideColumns: ["updatedAt","createdAt"]  //TODO - get these from some sort of JSON settings file or some such thing
    property bool sendOnChange : true

    property color cellColor           : "white"
    property color cellColor_Alternate : "#dfdfdf"


    // zcomponents reserved area
    property var uniqueProperties : ["pgWidth","pgHeight","model","headerHeight","hideColumns","cellColor","cellColor_Alternate"]
    property var uniqueSignals    : ({})
    property int headerHeight : 16

    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    style: TableViewStyle
    {
       id: defaultStyle
       activateItemOnSingleClick: true
       backgroundColor: tableView.cellColor
       alternateBackgroundColor: tableView.cellColor_Alternate
       highlightedTextColor: "white"
       headerDelegate: Rectangle
       {
           height: tableView.headerHeight
           width: textItem.implicitWidth
           color: "#002E00"
           Text
           {
               id: textItem
               anchors.fill: parent
               verticalAlignment: Text.AlignVCenter
               horizontalAlignment: styleData.textAlignment
               anchors.leftMargin: 12
               text: styleData.value
               elide: Text.ElideRight
    //                    color: textColor
               color:"#E0F0E0"
               renderType: Text.NativeRendering
               font
               {
                    bold: true
               }
           }
           Rectangle // header column divider
           {
               anchors.right: parent.right
               anchors.top: parent.top
               anchors.bottom: parent.bottom
               anchors.bottomMargin: 1
               anchors.topMargin: 1
               width: 1
               color: "black"
           }
       }
    }

    itemDelegate: Component
    {
        Item
        {
            Text
            {
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: styleData.value !== undefined ? styleData.value : ""
                color: styleData.textColor
                visible: !styleData.selected
            }

            Loader
            {
                id: loaderEditor
                anchors.fill: parent
                anchors.margins: 4
                Connections
                {
                    target: loaderEditor.item
                    onEditingFinished :
                    {
//                        if (typeof styleData.value === 'number')
//                            tableView.model.setVal(styleData.row + "/vehicle_make", text)
//    //                                tableView.setProperty(styleData.row, styleData.role, Number(parseFloat(loaderEditor.item.text).toFixed(0)))
//                        else
                        if(tableView.model.setVal)
                            tableView.model.setVal(styleData.row + "/"+tableView.getColumn(styleData.column).role, loaderEditor.item.text, sendOnChange)
                        else
                            tableView.setProperty(styleData.row, styleData.role, loaderEditor.item.text)

                    }
                }
                sourceComponent: styleData.selected ? editor : null
                Component
                {
                    id: editor
                    TextInput
                    {
                        id: textinput
                        color: styleData.textColor
                        text : styleData.value ? styleData.value : "N/A"
                        MouseArea
                        {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: textinput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    onModelChanged:
    {
        if (model && typeof model !== 'undefined' && model != 'null')
        {
            var counter = 0;
            for (var k in model.get(0))
            {
                if (typeof k  === 'string' && (columnExclusionCheck(k)))
                {
                    k = Functions.spch(k)
                    tableView.insertColumn(counter, Functions.getQmlObject(["QtQuick 2.0","QtQuick.Controls 1.3"],"TableViewColumn{role: "+ k +"  ; title: "+k+" ; width: 100  }",tableView))
                    counter++
                }
            }

            tableView.status = Component.Ready  //TODO - get READY only when the TableView is actually ready
        }
    }

    Item
    {
        id:privates
        //config area
        property var invalidColumns: ["objectName","objectNameChanged"] //if for some reason you get weird default columns showing up in list models you can throw them in here
        property bool filterUnderscoresInColumnNames: true  //stupid list model contains some weird properties like   '__0'   '__1'   so... we kill them if this is true
    }

    function columnExclusionCheck(k)
    {  //santize the columns that need supressed or stupid ones that are not worthy of life
        if (privates.filterUnderscoresInColumnNames)
        {
            if ((k[0] === k[1]) &&  k[0] === "_")
                return false
        }
        for (var h in hideColumns)
        {
            if(k === hideColumns[h])
                return false
        }

        for (var h in privates.invalidColumns)
        {
            if(k === privates.invalidColumns[h])
                return false
        }

        return true
    }


}

