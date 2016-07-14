import QtWebKit 3.0
//import QtWebView 1.1
import QtQuick 2.5
Item {
    id : rootObject
    signal loadStarted(url url)
    signal loadFinished()

    property string appId        : "1587909424854598"
    property var    appSecret    : "6aa74dc057a670a8300f49691cea248a"   //is used to make session long lived?
    property alias  redirect_url : logic.redirect_success
    property var    permissions  : ["public_profile","email","user_friends"]
    readonly property alias  fbId : logic.fbId
    readonly property alias  name : logic.name
    property alias publicFuncs    : publicFuncs
    readonly property alias token : logic.token
    readonly property alias expires : logic.expires


    QtObject {
        id : logic
        property string authUrl          : "https://www.facebook.com/dialog/oauth"
        property string redirect_success : "http://studiiio.global/facebook"
        property string token
        property string expires
        property string fbhost           : "https://graph.facebook.com"

        property string fbId
        property string name


        function getURLParameter(name,url) {
          return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(url) || [null, ''])[1].replace(/\+/g, '%20')) || null;
        }
    }

   QtObject {
        id : publicFuncs
        function me(cb) {
            publicFuncs.apiCall('GET','me', {access_token: token } , cb)
        }
        function myFriends(cb) {
            publicFuncs.apiCall('GET','me/friends', {access_token: token } , cb)
        }

        function getUserPicture(id, cb , width, height) {
            width  = width || 720
            height = height || 720

            apiCall('GET', id + "/picture", {width : width, height : height, redirect : false} , cb)
        }



        function apiCall(method, fnName, params, cb , dontParse) {
            //turn the params into a nice little str
            var paramsStr = ""
            if(params) {
                for(var p in params) {
                    paramsStr += paramsStr === "" ?  "?" + p + "=" + params[p] : "&" + p + "=" + params[p]
                }
            }

            var  xhr = new XMLHttpRequest;
            var source = logic.fbhost + "/" + fnName + paramsStr
            console.log(source)
            if (method.toLowerCase() === "post" || method.toLowerCase() === "put"){
//                   console.log("XHR", method, source)
                xhr.open(method.toUpperCase(), source);
                xhr.setRequestHeader("Content-Type", "application/json");
                xhr.send();
            }
            else {
//                   console.log("XHR", method, source)
                xhr.open(method.toUpperCase(), source);
                xhr.send();
            }

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200 && typeof cb === 'function') {
//                    console.log("XHR READY", xhr.responseText);
                    if(dontParse) {
//                        console.log(JSON.stringify(xhr.getAllResponseHeaders()))
                        cb(xhr.responseText);
                    }
                    else {
                        var js
                        try {
                           js = JSON.parse(xhr.responseText)
                           cb(js);
                        }catch(e) {
                            console.log(e, JSON.stringify({status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText} ,null,2))
                        }
                    }
                }
            };
        }




   }


    Item {
        width : parent.width
        height : parent.height
        anchors.centerIn: parent
        WebView {
            id : wv

            anchors.fill: parent

            url : logic.authUrl + "?client_id=" + appId +
    //              "&client_secret=" + appSecret +
                  "&redirect_uri=" + logic.redirect_success +
                  "&display=iframe&response_type=token&scope=" + permissions.join(",")

    //        interactive : false


            onUrlChanged: {
//                wv.runJavaScript('document.body.style.zoom="200%"')
                var u = url.toString()
                console.log(u)
                if(u.indexOf(logic.redirect_success) === 0) {
                    //find access token
    //                console.log(u)
                    logic.token     = logic.getURLParameter('#access_token', u)
                    logic.expires   = logic.getURLParameter('expires_in',u)

                    if(appSecret) { //we can actually now use this token to request for a long lived token!
                        var params = {
                            client_id          : appId,
                            client_secret      : appSecret ,
                            grant_type         : "fb_exchange_token",
                            fb_exchange_token : token
                        }

                        publicFuncs.apiCall('GET','oauth/access_token', params,  function(msg){
                                                    logic.token     = logic.getURLParameter('access_token', "?" + msg)
                                                    logic.expires   = logic.getURLParameter('expires'  , "?" + msg)
                                                    publicFuncs.me(function(response) {
                                                                        if(response) {
                                                                            logic.fbId = response.id
                                                                            logic.name = response.name
                                                                        }
                                                                    })

                                                } , true)
                    }
                    else {

                        publicFuncs.me(function(response) {
                                            if(response) {
                                                logic.fbId = response.id
                                                logic.name = response.name
                                            }
                                        })
                    }

    //                console.log("access_token=", token, "expires", expires)



                }
            }

            onLoadingChanged:  {
                if(!loading)
                    loadFinished()
                else
                    loadStarted(url)

            }
            Rectangle {
                anchors.fill: parent
                border.width: 1
                color : 'transparent'
            }
        }

    }




}
