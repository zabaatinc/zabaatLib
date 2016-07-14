import QtWebKit 3.0
import QtQuick 2.5
import Zabaat.Utility 1.0
import "fb.js" as FB
Item {
    id : rootObject
    signal loadStarted(url url)
    signal loadFinished()

//    //first let's get the fb sdk!
//    property var fb
//    Component.onCompleted: {
//        Functions.file.readFile("http://connect.facebook.net/en_US/sdk.js",function(msg){
//            console.log("READ FINISHED", msg.length);
//            console.log(_.keys(msg));
//            try {
//                fb = JSON.parse(msg);
//            }
//            catch(e) {
//                console.log("Zabaat.Auth.Facebook 1.1 : Could not parse response for Facebook SDK")
//            }

//        })
//    }
    WebView {
//        anchors.fill: parent
//         preferredWidth: 490
//         preferredHeight: 400
//         scale: 0.5
//         smooth: false

//         javaScriptWindowObjects: QtObject {
//                  WebView.windowObjectName: "FB"
//              }
//         html: "<script>console.log(\"This is in WebKit!\"); window.FB.init();</script>"

         function startupFunction() {
             console.log("This call is in QML!");
             FB.init({
                             appId:'1587909424854598', cookie:true,
                             status:true
                          });
             console.log(FB);
             }
        Component.onCompleted: startupFunction();
     }




//    property string appId           : "1587909424854598"
//    property var    appSecret       : "6aa74dc057a670a8300f49691cea248a"   //is used to make session long lived?
//    property alias  redirect_url    : logic.redirect_success
//    property var    permissions     : ["public_profile","email","user_friends"]
//    readonly property alias  fbId   : logic.fbId
//    readonly property alias  name   : logic.name
//    property alias publicFuncs      : publicFuncs
//    readonly property alias token   : logic.token
//    readonly property alias expires : logic.expires


//    QtObject {
//        id : logic
//        property string authUrl          : "https://www.facebook.com/dialog/oauth"
//        property string redirect_success : "http://studiiio.global/facebook"
//        property string token
//        property string expires
//        property string fbhost           : "https://graph.facebook.com"

//        property string fbId
//        property string name


//        function getURLParameter(name,url) {
//          return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(url) || [null, ''])[1].replace(/\+/g, '%20')) || null;
//        }
//    }

//    QtObject {
//         id : publicFuncs
//         function me(cb) {
//             publicFuncs.apiCall('GET','me', {access_token: token } , cb)
//         }
//         function myFriends(cb) {
//             publicFuncs.apiCall('GET','me/friends', {access_token: token } , cb)
//         }

//         function getUserPicture(id, cb , width, height) {
//             width  = width || 720
//             height = height || 720

//             apiCall('GET', id + "/picture", {width : width, height : height, redirect : false} , cb)
//         }



//         function apiCall(method, fnName, params, cb , dontParse) {
//             //turn the params into a nice little str
//             var paramsStr = ""
//             if(params) {
//                 for(var p in params) {
//                     paramsStr += paramsStr === "" ?  "?" + p + "=" + params[p] : "&" + p + "=" + params[p]
//                 }
//             }

//             var  xhr = new XMLHttpRequest;
//             var source = logic.fbhost + "/" + fnName + paramsStr
//             console.log(source)
//             if (method.toLowerCase() === "post" || method.toLowerCase() === "put"){
// //                   console.log("XHR", method, source)
//                 xhr.open(method.toUpperCase(), source);
//                 xhr.setRequestHeader("Content-Type", "application/json");
//                 xhr.send();
//             }
//             else {
// //                   console.log("XHR", method, source)
//                 xhr.open(method.toUpperCase(), source);
//                 xhr.send();
//             }

//             xhr.onreadystatechange = function() {
//                 if (xhr.readyState === 4 && xhr.status === 200 && typeof cb === 'function') {
// //                    console.log("XHR READY", xhr.responseText);
//                     if(dontParse) {
// //                        console.log(JSON.stringify(xhr.getAllResponseHeaders()))
//                         cb(xhr.responseText);
//                     }
//                     else {
//                         var js
//                         try {
//                            js = JSON.parse(xhr.responseText)
//                            cb(js);
//                         }catch(e) {
//                             console.log(e, JSON.stringify({status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText} ,null,2))
//                         }
//                     }
//                 }
//             };
//         }
//    }




}
