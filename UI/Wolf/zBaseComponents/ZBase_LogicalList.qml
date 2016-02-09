import QtQuick 2.0
import "Functions.js" as Functions


Column
{
    id : rootObject
    property var self : this
    property string actualValueField : ""
    property var model : []
    onModelChanged: if(model)
                       privates.init()

    property int status       : Component.Loading
    property int rowHeight    : 32
    property int currentIndex : -1
    width  : 500
    height : 32
    property var queryObj : []
    signal queryChanged()

    Row
    {
        id     : btnRow
        width  : rootObject.width
        height : rowHeight

        ZBase_Button
        {
            id : addBtn
            showIcon: true
            fontAwesomeIcon: '\uf067'
            onBtnClicked: {if(rootObject.status == Component.Ready)
                            privates.createRow()}
            text : ""
                width  : rootObject.width/2
                height : rootObject.rowHeight
        }

        ZBase_Button
        {
            id : delBtn
            showIcon : true
            fontAwesomeIcon: '\uf068'
            onBtnClicked: if(rootObject.status == Component.Ready)
                              privates.deleteRow()

            text : ""
                width  : rootObject.width/2
                height : rootObject.rowHeight
        }
    }


    Column
    {
        /*! The possible choices (variables, in the left hand side) */
        id     : mainCol
        width  : rootObject.width
        height : rowHeight
        clip   : false
        function clear()
        {
            for(var i = 0; i < children.length; i++)
            {
                var child = children[i]
                child.parent = null
                child.destroy()
            }
            children = []
        }
    }




    QtObject
    {
        id : privates
        property var operators  : [ {op : '==' }, {op : '!='}, {op : '>'}, {op : '>='}, {op : '=<'}, {op : '<'}, {op :'contains'}, {op :'startsWith'} ,{op :'endsWith'} ]
        property var connectors : [ {op : 'AND'}, {op: 'OR'} ]

        property bool disableNotify : false

        function init()
        {
            rootObject.status = Component.Loading
            mainCol.clear()
            rootObject.height = Qt.binding(function() { return btnRow.height + mainCol.childrenRect.height } )
            rootObject.status = Component.Ready
        }

        function createRow()
        {
            var importArr = ['QtQuick 2.0', 'Zabaat.UI.Wolf 1.0']
            var qmlStr    = 'Row
                             {
                                property alias cVar : varCmb;
                                property alias oVar : opCmb;
                                property alias nVar : conCmb;
                                property int queryArrIndex : -1;
                                property var containerPtr : null


                                signal queryChanged(int index, string field, string op, string value, string connector);

                                ZBase_ComboBoxQt
                                {
                                    id     : varCmb;
                                    height : parent.height;
                                    showValueField : true;
                                    onAnswerChanged : queryChanged(queryArrIndex, varCmb.answer, opCmb.answer, queryVal.text, conCmb.answerVal);
                                }

                                ZBase_ComboBoxQt
                                {
                                    id : opCmb;
                                    height : parent.height;
                                    showValueField : true;
                                    onAnswerChanged : queryChanged(queryArrIndex, varCmb.answer, opCmb.answer, queryVal.text, conCmb.answerVal);
                                }

                                ZBase_TextBox
                                {
                                    id : queryVal;
                                    height : parent.height;
                                    onTextChanged : queryChanged(queryArrIndex, varCmb.answer, opCmb.answer, text, conCmb.answerVal);
                                    labelName : "";
                                }

                                ZBase_ComboBoxQt
                                {
                                    id: conCmb;
                                    height : parent.height;
                                    property string answerVal : visible ? answer : "";
                                    onAnswerValChanged : queryChanged(queryArrIndex, varCmb.answer, opCmb.answer, queryVal.text, conCmb.answerVal);

                                    visible : containerPtr && queryArrIndex == containerPtr.children.length - 1 ? false : true

                                    showValueField : true;
                                }
                            }'
            var row = Functions.getQmlObject(importArr,qmlStr,mainCol)
            row.height = Qt.binding(function() { return rootObject.rowHeight })
            row.oVar.setupObj = privates.operators
            row.oVar.actualValueField = 'op'
            row.containerPtr = mainCol

            row.cVar.setupObj = rootObject.model
            row.cVar.actualValueField = rootObject.actualValueField
            row.queryArrIndex = rootObject.queryObj.length

            row.nVar.setupObj = privates.connectors
            row.nVar.actualValueField = 'op'

            queryObj[queryObj.length] = {fieldName : row.cVar.answer, op : row.oVar.answer, value : "", connector : ""}
            //row.nVar.visible = Qt.binding(function() { console.log(row.queryArrIndex, rootObject.queryObj.length -1);if(row.queryArrIndex == rootObject.queryObj.length - 1) return false; return true  })

            row.queryChanged.connect(queryChangedFunc)
//            mainCol.height        += rowHeight
//            mainCol.resizeContent(rootObject.width, mainCol.height, Qt.point(0,0))
//            mainCol.returnToBounds()
        }

        function queryChangedFunc(index, field, op, value, connector)
        {
            queryObj[index] = {fieldName : field, op : op, value : value, connector : connector}
            if(!disableNotify)
                queryChanged()
        }


        //always deletes last row if no id provided
        function deleteRow(index)
        {
            if(mainCol.children.length > 0)
            {
                disableNotify = true

                if(index == null || typeof index === 'undefined')
                    index = mainCol.children.length - 1


                var child = mainCol.children[index]
                child.parent = null
                child.destroy()
                queryObj.splice(index,1)

                //should auto happen
                if(queryObj.length > 0)
                    queryObj[queryObj.length -1].connector = ""

                queryChanged()
                disableNotify = false
//                mainCol.height        -= rowHeight
            }
        }
    }

}
