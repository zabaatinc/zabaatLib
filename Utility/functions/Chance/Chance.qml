import QtQuick 2.5
import "chance.js" as C

//r end = Moment.moment({month : endMonth, year : endYear})

pragma Singleton
QtObject {
    id : rootObject
    objectName : "Chance.qml"

    property var seed: null
    property QtObject _logic : QtObject{
        id : logic
        property var store       : null
        property int storeIdGen  : 0

        //returns a new chance object or one from the store. If seed is an object, it should have
        //id OR store key.
        function chance(seed){
            if(typeof seed === 'object') {
                if(store){
                    if(seed.id !== undefined && store[seed.id])
                        return store[seed.id]
                    else if(seed.store !== undefined && seed.store !== undefined)
                        return store[seed.store]
                }
                seed = null
            }
            seed = seed || rootObject.seed
            return seed ? new C.Chance(seed) : new C.Chance();
        }


        //is used in unique!
        property var chanceJsFuncs :
        [
            "bool", "character", "floating", "integer", "natural",
            "string","paragraph","sentence", "syllable", "word",
            "age","birthday","cf","cpf","first","gender","last",
            "name","prefix","ssn","suffix","android_id","apple_token",
            "bb_pin","wp7_anid","wp8_anid2","avatar","color",
            "domain","email","fbid","google_analytics","hashtag",
            "ip","ipv6","klout","tld","twitter","url","address",
            "altitude","areacode","city","coordinates","country",
            "depth","geohash","latitude","longitude","phone",
            "postal","province","state","street","zip","ampm",
            "date","hammertime","hour","millisecond","minute",
            "month","second","timestamp","year","cc","cc_type","currency",
            "currency_pair","dollar","euro","exp","exp_month","exp_year",
            "capitalize","mixin","pad","pick","pickone","pickset",
            "set","shuffle","dice","guid","hash","hidden","n","normal",
            "radio","rpg","tv","unique","weighted"
        ]

    }

    function unstoreChance(storeNumber) {
        if(logic.store && logic.store[storeNumber]){
            delete logic.store[storeNumber]
        }
    }

    //This stores a Chance Instance (for syncing purposes!!!). Returns the number you can
    //Use to refrence that chance, in all other functions.
    function storeChance(seed){
        if(!logic.store)
            logic.store = ({})

        logic.store[logic.storeIdGen] = seed ? new C.Chance(seed) : new C.Chance();
        return logic.storeIdGen++;

    }


    //BASIC
    function bool     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function character(options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function floating (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function integer  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function natural  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function string   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }


    //TEXT
    function paragraph(options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function sentence (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function syllable (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function word     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }


    //PERSON
    function age        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function birthday   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function cf         (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function cpf        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function first      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function gender     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function last       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function name       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function prefix     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function ssn        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function suffix     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //MOBILE
    function android_id    (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function apple_token   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function bb_pin        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function wp7_anid      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function wp8_anid2     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //WEB
    function avatar             (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function color              (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function domain             (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function email              (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function fbid               (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function google_analytics   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function hashtag            (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function ip                 (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function ipv6               (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function klout              (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function tld                (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function twitter            (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function url                (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //LOCATION
    function address       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function altitude      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function areacode      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function city          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function coordinates   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function country       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function depth         (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function geohash       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function latitude      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function longitude     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function phone         (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function postal        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function province      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function state         (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function street        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function zip           (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //TIME
    function ampm          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function date          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function hammertime    (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function hour          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function millisecond   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function minute        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function month         (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function second        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function timestamp     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function year          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //FINANICE
    function cc            (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function cc_type       (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function currency      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function currency_pair (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function dollar        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function euro          (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function exp           (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function exp_month     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function exp_year      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //MISC
    function d4   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d6   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d8   (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d10  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d12  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d20  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d30  (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function d100 (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    function guid      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function hash      (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
//    function hidden    (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    function normal    (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function radio     (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }
    function rpg       (str, options,seed){ return logic.chance(seed)[arguments.callee.name](str, options) }
    function tv        (options,seed){ return logic.chance(seed)[arguments.callee.name](options) }

    //SUPER SPECIAL FUNCS, THAT HVE DIFF API A LITTLE BIT
    function weighted  (answerArr, weightArr,seed){
        return logic.chance(seed)[arguments.callee.name](answerArr,weightArr)
    }


    function unique    (fnName,length,options, seed){
        if(fnName !== null && typeof fnName !== 'undefined' && logic.chanceJsFuncs.indexOf(fnName) !== -1){
            var c  = logic.chance(seed);
            var fn = c[fnName]
            return options ? c.unique(fn, length, options) : c.unique(fn, length, {})
        }
        return []
    }
    function n (fnName,length, options, seed) {
        if(fnName !== null && typeof fnName !== 'undefined' && logic.chanceJsFuncs.indexOf(fnName) !== -1){
            var c  = logic.chance(seed);
            var fn = c[fnName]
            return c.n(fn, length, options)
        }
        return []
    }


}
