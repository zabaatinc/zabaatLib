import QtWebKit 3.0
import QtQuick 2.5
Item {
    id : rootObject
    signal loadStarted(url url)
    signal loadFinished()

    property alias input        : inputVars
    property alias output       : outputVars
    property alias publicFuncs  : publicFuncs


    QtObject {
         id : logic
         property InputVars  inputVars  : InputVars  { id : inputVars  }
         property OutputVars outputVars : OutputVars { id : outputVars }
         function getURLParameter(name,url) {
           return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(url) || [null, ''])[1].replace(/\+/g, '%20')) || null;
         }
    }

   QtObject {
        id : publicFuncs
        function me(cb) {
            publicFuncs.apiCall('GET','me', {access_token: output.token } , cb)
        }
        function myFriends(cb) {
            publicFuncs.apiCall('GET','me/friends', {access_token: output.token } , cb)
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
            var source = input.fbhost + "/" + fnName + paramsStr
//            console.log(source)
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


   //              "&client_secret=" + appSecret +
   WebView {
       id : wv
       anchors.fill: parent
       url : {
           if(input.readyFlag){
                return input.authUrl + "?client_id=" + input.appId +
                       "&display=touch&response_type=code&scope=" + input.permissions.join(",") +
                        "&redirect_uri=" + input.redirectUrl
           }
           return ""
       }

//       property var c : 0
       onUrlChanged: {
           var u = url.toString()
           if(u === "")
               return;

           //GREAT SUCESS MARIO!
           if(u.indexOf(input.redirectUrl) === 0) {
               //find access token
//                console.log(u)
               var t = logic.getURLParameter('#access_token', u)
               var e = logic.getURLParameter('expires_in',u)
               var c = logic.getURLParameter(input.appAuthenticatedKey,u);
               if(t)
                    output.token   = t
               if(e)
                    output.expires = e
               if(c)
                   output.appAuthentication = { url : u, code : c }

//               console.log("TOKEN", output.token, output.expires)
//               if(input.appSecret) { //we can actually now use this token to request for a long lived token!
//                   var params = {
//                       client_id          : input.appId,
//                       client_secret      : input.appSecret ,
//                       grant_type         : "fb_exchange_token",
//                       fb_exchange_token  : output.token
//                   }

//                   console.log("CALLING WITH APP SECRET")
//                   publicFuncs.apiCall('GET','oauth/access_token', params,  function(msg){
//                                               output.token    = logic.getURLParameter('access_token', "?" + msg)
//                                               output.expires  = logic.getURLParameter('expires'     , "?" + msg)
//                                               publicFuncs.me(function(response) {
//                                                                   if(response) {
//                                                                       output.fbId = response.id
//                                                                       output.name = response.name
//                                                                   }
//                                                               })

//                                           } , true)
//               }
//               else {

//                   publicFuncs.me(function(response) {
//                                       if(response) {
//                                           output.fbId = response.id
//                                           output.name = response.name
//                                       }
//                                   })
//               }

           }
       }

       onLoadingChanged:  {
           if(!loading)
               loadFinished()
           else  {
                loadStarted(loadRequest.url)
           }
       }

//       onNavigationRequested: {
////            console.log(request.url)
//            var c = logic.getURLParameter(input.appAuthenticatedKey,request.url)
//            if(c){
////                console.log("CANCELLED YOUR REQUEST GENERAL.FU!", request.url)
//                output.appAuthentication = { url : request.url.toString(), code : c }
////                output.appToken = c;  ///YAYYYAYAYAYAYAYAYAY WE GOT THE APP CODE!!
//                request.action = WebView.IgnoreRequest
//            }
//       }

//       function statusMsg(i){
//           switch(i){
//                case WebView.LoadStartedStatus  : return "LoadStarted"
//                case WebView.LoadFailedStatus   : return "LoadFailed"
//                case WebView.LoadStoppedStatus  : return "LoadStopped"
//                case WebView.LoadSucceededStatus: return "LoadSucceeded"
//                default                         : return "LoadUnknown"
//           }
//       }

       Rectangle {
           anchors.fill: parent
           border.width: 1
           color : 'transparent'
       }
   }





}
