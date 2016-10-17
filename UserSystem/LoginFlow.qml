//Drop this anywhere and configure its config object
import QtQuick 2.5
import "Components"
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
ZPage {
    id : rootObject
    property alias config : config;
    property string facebookAppId: "";


    ComponentsConfig {
        id : config
        //button
        //button_alt
        //background
        //background_login
        //background_resetpass
        //background_signup
        //background_loggedin
        //textbox
        //textbox_password
        //title_text
        //title_img
      }

    QtObject {
        id : logic
        property string state : ''
        function toFileName(state){
            switch(state) {
                case 'login'    : return Qt.resolvedUrl("./Components/Login.qml")
                case 'restpass' : return Qt.resolvedUrl("./Components/ResetPass.qml")
                case 'signup'   : return Qt.resolvedUrl("./Components/SignUp.qml")
                case 'loggedin' : return Qt.resolvedUrl("./Components/LoggedIn.qml")
                case ''         : return Qt.resolvedUrl("./Components/Homepage.qml")
            }
        }
    }

    FlexibleLoader {    //loads the background of the currentState we're in!
        id : loaderBackground
        anchors.fill: parent
        source: {
            if(!logic.state)
                return config.background.component;
            return config['background_' + logic.state].component
        }
    }

    FlexibleLoader {
        id : loaderState
        anchors.fill: parent
        source : logic.toFileName(logic.state);
        onLoaded : {
            item.sizeDesigner    = Qt.binding(function() { return rootObject.sizeDesigner    });
            item.sizeMainWindow  = Qt.binding(function() { return rootObject.sizeMainWindow  });
            item.scaleMultiplier = Qt.binding(function() { return rootObject.scaleMultiplier });
            item.absoluteMode    = Qt.binding(function() { return rootObject.absoluteMode    });
            item.config          = Qt.binding(function() { return rootObject.config          });
        }
    }






}
