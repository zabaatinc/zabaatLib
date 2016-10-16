import QtQuick 2.5
import "Lodash"
import "Promises"
import Qt.labs.settings 1.0
pragma Singleton

//notloggedIn         : 0;
//loggedIn            : 1;
//skippedLogin        : 2;
//attemptingLogin     : 3;
//attemptingLogout    : 4;
//attemptingSkipLogin : 5;


QtObject{
    id : rootObject
    readonly property alias status       : priv.status
    readonly property alias statusString : priv.statusString

    property alias userInfo  : userInfo
    property alias settings  : settings
    property alias functions : functions
    property alias config    : config
    property alias userObj   : userInfo.obj

//    signal loggedIn();
//    signal loggedOut();
//    signal skippedLogin();
    function login(userData, success, fail){
        if(status != 0)
            return console.error("Cannot Log In because you are", priv.statusString);

        var blankFn = function(){}
        success = typeof success === 'function' ? success : blankFn
        fail    = typeof fail    === 'function' ? fail    : blankFn

        var oldStatus = priv.status;
        priv.status = 3;

        return priv.genFuncPromise(functions.loginFunc, userData).then(function(msg) {
            //adjust more vars hurr
            var userObj = Lodash.isArray(msg.data) ? msg.data[0] : msg.data;

            settings.userLoginData = userData;
            settings.id          = priv.get(userObj, config.keyName_id          ,config.role_guest);
            settings.username    = priv.get(userObj, config.keyName_username    ,""               );
            settings.firstname   = priv.get(userObj, config.keyName_firstName   ,""               );
            settings.lastname    = priv.get(userObj, config.keyName_lastName    ,""               );
            settings.gender      = priv.get(userObj, config.keyName_gender      ,""               );
            settings.email       = priv.get(userObj, config.keyName_email       ,""               );
            settings.dateOfBirth = priv.get(userObj, config.keyName_dateOfBirth ,""               );
            settings.role        = priv.get(userObj, config.keyName_role       , config.role_guest);
            if(settings.id === config.role_guest)
                settings.role = config.role_guest;

            userInfo.obj = userObj;

            priv.status = 1; //sucessfully logged in!
            var promises = [];
            Lodash.each(functions.loginFuncs, function(v,k){
                if(typeof v === 'function')
                    promises.push(priv.genFuncPromise(v));
            })
            return promises.length == 0 ? success() :
                                          Promises.all(promises).finally(success);
        }).catch(function(err){
            //return status to old status cause logout failed!
            console.error("Error when Logging In", err);
            status = oldStatus
            fail();
        });
    }
    function skipLogin(success,fail){
        if(status != 0)
            return console.error("Cannot skip login because you are", priv.statusString);

        priv.status = 5;     //attemptSkipLogin
        var blankFn = function(){}
        success = typeof success === 'function' ? success : blankFn
        fail    = typeof fail    === 'function' ? fail    : blankFn

        var promises = [];
        Lodash.each(functions.skippedLoginFuncs, function(v,k){
            if(typeof v === 'function')
                promises.push(priv.genFuncPromise(v));
        })

        //make da userInfo based on our settings cause we remember it, then call the onSkippedLoginFuncs!!
        var userObj = {}
        userObj[config.keyName_id]          = settings.id
        userObj[config.keyName_username]    = settings.username
        userObj[config.keyName_firstName]   = settings.firstname
        userObj[config.keyName_lastName]    = settings.lastname
        userObj[config.keyName_gender]      = settings.gender
        userObj[config.keyName_email]       = settings.email
        userObj[config.keyName_dateOfBirth] = settings.dateOfBirth
        userObj[config.keyName_role]        = settings.role

        userInfo.obj = userObj;

        return promises.length === 0 ? success() :
        Promises.all(promises)
        .then(function(){
            priv.status = 2; //skippedLogin
            success();
        })
        .catch(function(err) {
            console.log(err);
            userInfo.obj = undefined;
            priv.status = 0; //notLoggedIn
            fail();
        });
    }
    function logout(success, fail){
        //can only log out if you aren't loggedIn and if state isn't busy!
        if(status == 0 || status >= 3)
            return console.error("Cannot log out because you are", priv.statusString);

        var blankFn = function(){}
        success = typeof success === 'function' ? success : blankFn
        fail    = typeof fail    === 'function' ? fail    : blankFn

        var oldStatus = priv.status;
        priv.status = 4;

        return priv.genFuncPromise(functions.logoutFunc).then(function() {
            priv.status = 0; //sucessfully logged out
            userInfo.obj = undefined;
            var promises = [];
            Lodash.each(functions.logoutFuncs, function(v,k){
                if(typeof v === 'function')
                    promises.push(priv.genFuncPromise(v));
            })
            return promises.length === 0 ? success() :
                                           Promises.all(promises).finally(success);

        }).catch(function(err){
            //return status to old status cause logout failed!
            console.error("Error when Logging out", err.stack);
            priv.status = oldStatus
            fail();
        });
    }



    property Item __priv : Item {
        id : priv
        QtObject {
            id : userInfo
            property var    obj
            property string id          : obj && obj[config.keyName_id]          ? obj[config.keyName_id]          : config.role_guest
            property string username    : obj && obj[config.keyName_username]    ? obj[config.keyName_username]    : ""
            property string firstname   : obj && obj[config.keyName_firstName]   ? obj[config.keyName_firstName]   : ""
            property string lastname    : obj && obj[config.keyName_lastName]    ? obj[config.keyName_lastName]    : ""
            property string gender      : obj && obj[config.keyName_gender]      ? obj[config.keyName_gender]      : ""
            property string email       : obj && obj[config.keyName_email]       ? obj[config.keyName_email]       : ""
            property string dateOfBirth : obj && obj[config.keyName_dateOfBirth] ? obj[config.keyName_dateOfBirth] : ""
            property string role        : {
                if(!obj)
                    return "";
                if(obj[config.keyName_role])
                    obj[config.keyName_role];
                return id === config.role_guest ? config.role_guest :
                                                  config.role_default
            }
        }
        QtObject {
            id : functions
            property var loginFunc: function(userInfo, cb){
                cb();
            }
            property var logoutFunc : function(cb){
                cb();
            }
            property var createUserFunc : function(cb){
                cb();
            }

            property var skippedLoginFuncs : []
            property var loginFuncs        : []
            property var logoutFuns        : []
        }
        Settings {
            id : settings
            property var    userLoginData
            property string id
            property string username
            property string firstname
            property string lastname
            property string gender
            property string email
            property string dateOfBirth
            property string role
        }
        QtObject {
            id : config
            property string keyName_username    : 'identifier'
            property string keyName_email       : 'email'
            property string keyName_password    : 'password'
            property string keyName_id          : 'id'
            property string keyName_role        : 'role'
            property string keyName_firstName   : 'firstname'
            property string keyName_lastName    : 'lastname'
            property string keyName_gender      : 'sex'
            property string keyName_dateOfBirth : 'dob'

            property string role_default : 'user'
            property string role_guest   : 'guest'
        }

        property int    status       : 0;
        property string statusString : switch(status) {
                                           case 0  : return "Not Logged In" ;
                                           case 1  : return "Logged In"     ;
                                           case 2  : return "Skipped Login" ;
                                           case 3  : return "Logging In"    ;
                                           case 4  : return "Logging Out"   ;
                                           case 5  : return "Skipping Login";
                                           default : return "Unknown"     ;
                                       }


        function genFuncPromise(fn){
            fn = typeof fn === 'function' ? fn :
                                            function(cb){ cb({ err : 'no function provided' }) }

            var args = Array.prototype.slice.call(arguments,1); //get all args except func


            return Promises.promise(function(resolve,reject){
                args.push(function(msg) { //return msg && msg.err ? reject(msg.err) : resolve(msg);
                    if(msg && msg.err) {
                        console.log("REJECTING WITH", msg.err);
                        reject(msg.err);
                    }
                    resolve(msg);
                })

                //this makes it so the cb is always the last thing passed onto the fn. all the params
                //from genFuncPromise are passed into fn (except fn of course).
                fn.apply(this,args);
            })
        }
        function get(obj,propertyName,defaultVal){
            if(!obj || !obj.hasOwnProperty(propertyName))
                return defaultVal;
            return obj[propertyName];
        }
    }
}
