//Drop this anywhere and configure its config object
import QtQuick 2.5
import "Components"
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
ZPage {
    id : rootObject
    property alias config : config;
    property string facebookAppId: "";
    signal done();


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
                case 'login'    : return Qt.resolvedUrl("./Components/Login.qml");
                case 'resetpass': return Qt.resolvedUrl("./Components/ResetPass.qml");
                case 'signup'   : return Qt.resolvedUrl("./Components/SignUp.qml");
                case 'loggedin' : return Qt.resolvedUrl("./Components/LoggedIn.qml");
                case ''         : return Qt.resolvedUrl("./Components/Homepage.qml");
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
        id : loader
        anchors.fill: parent
        source : logic.toFileName(logic.state);
        onLoaded : {
            item.sizeDesigner    = Qt.binding(function() { return rootObject.sizeDesigner    });
            item.sizeMainWindow  = Qt.binding(function() { return rootObject.sizeMainWindow  });
            item.scaleMultiplier = Qt.binding(function() { return rootObject.scaleMultiplier });
            item.absoluteMode    = Qt.binding(function() { return rootObject.absoluteMode    });
            item.config          = Qt.binding(function() { return rootObject.config          });

            if(typeof item.action === 'function')
                item.action.connect(handleAction);

        }

        function handleAction(action) {

            switch(action.name) {
                case "tosignup":
                    return logic.state = 'signup';
                case "tologin" :
                    if(action.username)
                        loader.loadArgsOnNext({username:action.username})
                    return logic.state = "login";
                case "skip"    :
                    return UserSystem.skipLogin(done)
                case "login"   :
                    var userData = {};
                    userData[UserSystem.config.keyName_username] = action.username;
                    userData[UserSystem.config.keyName_password] = action.password;

                    blocker.visible = true;
                    return UserSystem.login(userData, function() { handleAction({name:"loggedin"})} , function() { blocker.visible = false; });

                case "loggedin":
                    return logic.state = 'loggedin';
                case 'reset'   :
                    loader.loadArgsOnNext({ username : action.username } )
                    return logic.state = 'resetpass'
                case 'done'    :
                    return done();
                default :
                    console.log("loading home cause action was was set to", action.name)
                    return logic.state = "";
            }
        }


    }

    UIBlocker {
        id : blocker
        anchors.fill: parent
        visible : false;

        onVisibleChanged: if(visible)
                              forceActiveFocus();
    }








}
