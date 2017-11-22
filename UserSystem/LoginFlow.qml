//Drop this anywhere and configure its config object
import QtQuick 2.5
import "Components"
import Zabaat.UserSystem 1.0
import QtQuick.Controls 1.4
ZPage {
    id : rootObject
    property var config : UserSystem.componentsConfig;
    property string facebookAppId: "";
    readonly property alias state : logic.state

    function resetState() {
        logic.state = logic.defaultState;
    }

    signal done();

    //block everything behind this!!!!!!
    UIBlocker {
        anchors.fill: parent
        color : 'transparent'
    }


    QtObject {
        id : logic
        property string state : defaultState
        property string defaultState: {
            var hasLogin = typeof UserSystem.functions.loginFunc === 'function'
            var hasSignUp = typeof UserSystem.functions.createUserFunc === 'function'
            var canSkipLogin = UserSystem.skipLoginAllowed

            if(hasLogin && !hasSignUp && !canSkipLogin)
                return 'login'
            return '';
        }


        function toFileName(state){
            switch(state) {
                case 'login'    : return Qt.resolvedUrl("./Components/Login.qml");
                case 'resetpass': return Qt.resolvedUrl("./Components/ResetPass.qml");
                case 'signup'   : return Qt.resolvedUrl("./Components/SignUp.qml");
                case 'loggedin' : return Qt.resolvedUrl("./Components/LoggedIn.qml");
                case ''         : return Qt.resolvedUrl("./Components/Homepage.qml");
            }
        }

        property bool watchLogout : false
        property Connections userStatusConn : Connections{
            target : UserSystem
            onStatusChanged : {
                if(UserSystem.status === UserState.attemptingLogout) {
                    logic.watchLogout = true;
                }
                else if(UserSystem.status === UserState.notloggedIn && logic.watchLogout) {
                    logic.watchLogout = false;
                    logic.state = logic.defaultState;
                }
            }
        }
    }

    FlexibleLoader {    //loads the background of the currentState we're in!
        id : loaderBackground
        anchors.fill: parent
        source: {
            if(!config)
                return ""
            if(!logic.state)
                return config.background.component;
            return config['background_' + logic.state].component
        }
    }

    FlexibleLoader {
        id : loader
        anchors.fill: parent
        source : logic.toFileName(logic.state);

        function attachBindings(item, name){
            var m_name = name;
            if(item.hasOwnProperty(name))
                item[name] = Qt.binding(function() { return rootObject[m_name]  });
        }

        onLoaded : {
            attachBindings(item, 'sizeDesigner'   );
            attachBindings(item, 'sizeMainWindow' );
            attachBindings(item, 'scaleMultiplier');
            attachBindings(item, 'absoluteMode'   );
            attachBindings(item, 'config'         );

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
                    return UserSystem.login(userData,
                                            function() { blocker.visible = false; handleAction({name:"loggedin"})} ,
                                            function() { blocker.visible = false; }
                                           );

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
