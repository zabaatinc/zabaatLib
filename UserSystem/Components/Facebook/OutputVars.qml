import QtQuick 2.5
QtObject {
    id : outputVars
    property string token
    property string expires

    //user stuff
    property string fbId
    property string name
    property var    appAuthentication   //holds the token and the redirect uri!

//    property string appToken    //this is called code ! But we so fancy


}
