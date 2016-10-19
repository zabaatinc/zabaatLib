import QtQuick 2.5
import Qt.labs.settings 1.0
Item {
    id : rootObject
    signal loadStarted(url url)
    signal loadFinished()
    signal appCodeReceived(string code, string url);    //this is the code that fb gives us after we have authenticated with the app!

    property alias input        : inputVars
    property alias output       : outputVars
    property alias publicFuncs  : publicFuncs

    QtObject {
         id : logic
         property InputVars  inputVars  : InputVars  { id : inputVars  }
         property OutputVars outputVars : OutputVars { id : outputVars }

         function getURLParameter(name,url) {
           return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(url) || [null, ''])[1].replace(/\+/g, '%20')) || "cannot find " + name;
         }
    }
    QtObject {
         id : publicFuncs

         function me(cb){
             var item = webViewLoader.item
             if(item){
                 return item.publicFuncs[arguments.callee.name].apply(this,arguments);
             }
             console.error("webview isnt loaded")
         }
         function myFriends(cb){
             var item = webViewLoader.item
             if(item){
                 return item.publicFuncs[arguments.callee.name].apply(this,arguments);
             }
             console.error("webview isnt loaded")
         }
         function getUserPicture(id, cb, width, height){
             var item = webViewLoader.item
             if(item){
                 return item.publicFuncs[arguments.callee.name].apply(this,arguments);
             }
             console.error("webview isnt loaded")
         }
         function apiCall(method, fnName, params, cb, dontParse){
             var item = webViewLoader.item
             if(item){
                 return item.publicFuncs[arguments.callee.name].apply(this,arguments);
             }
             console.error("webview isnt loaded")
         }
    }
    Loader {
        id : webViewLoader
        anchors.fill: parent
        //source : Qt.platform.os === "windows" ? "webkit.qml" : "webview.qml"
        source : "webview.qml"
        onLoaded: {
            //make sure all the inputs go into the webview
            item.input.appId           = Qt.binding(function() { return inputVars.appId       } )
            item.input.appSecret       = Qt.binding(function() { return inputVars.appSecret   } )
            item.input.authUrl         = Qt.binding(function() { return inputVars.authUrl     } )
            item.input.redirectUrl     = Qt.binding(function() { return inputVars.redirectUrl } )
            item.input.permissions     = Qt.binding(function() { return inputVars.permissions } )
            item.input.fbhost          = Qt.binding(function() { return inputVars.fbhost      } )
            item.input.appAuthenticatedKey = Qt.binding(function() { return inputVars.appAuthenticatedKey } )

            item.input.readyFlag       = Qt.binding(function() { return inputVars.readyFlag } );

//            console.log(typeof item.loadStarted, typeof item.loadFinished)
        }

        //connect the output vars
        Connections {
            target            : webViewLoader.item && webViewLoader.item.output ? webViewLoader.item.output : null
            onFbIdChanged     : outputVars.fbId     = webViewLoader.item.output.fbId   ;
            onNameChanged     : outputVars.name     = webViewLoader.item.output.name   ;
            onTokenChanged    : outputVars.token    = webViewLoader.item.output.token  ;
            onExpiresChanged  : outputVars.expires  = webViewLoader.item.output.expires;
            onAppAuthenticationChanged : {
                output.appAuthentication = webViewLoader.item.output.appAuthentication;
                //{ url : request.url, code : c }
                rootObject.appCodeReceived(outputVars.appAuthentication.code, outputVars.appAuthentication.url)
            }
        }

        //connect the signals
        Connections {
            target           : webViewLoader.item ? webViewLoader.item : null
            onLoadStarted    : rootObject.loadStarted(webViewLoader.item.url);
            onLoadFinished   : rootObject.loadFinished();
        }
    }


}
