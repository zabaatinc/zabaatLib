import QtQuick 2.0

Item
{
    property var ptr                 : null
    property string prop             : ""

    property string modelName        : ""
    property string serverLocation   : ""
    property var sendRequestFunction : null

    property bool dying : false

    function set(value, dontSend)
    {
        if(ptr && prop !== "" && ptr[prop] != value)
        {
//            console.log("set called with" , prop," = ", value)
            ptr[prop] = value
            if(sendRequestFunction && !dontSend)
                sendRequestFunction(modelName + "/" + serverLocation, value)
        }
    }

    function get()
    {
        if(ptr && prop != "")            return ptr[prop]
        else                             return "N/A"
    }







}
