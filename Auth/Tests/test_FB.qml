import QtQuick 2.0
import Zabaat.Auth 1.0
Item {


    Image {
        id : img
        width : parent.width / 4
        height : width
    }

    Facebook {
        id : fb
        width : parent.width/2
        height : parent.height
        anchors.right: parent.right
        onFbIdChanged: {
//            console.log(fbId)
            publicFuncs.getUserPicture(fbId , function(msg) {
                if(msg && msg.data && msg.data.url) {
//                    console.log("response" , JSON.stringify(msg))
                    img.source = msg.data.url
                }
            }, img.width, img.height)

            publicFuncs.myFriends(function(msg) {

//                console.log(JSON.stringify(msg,null,2))

            })
        }

//        onLoadStarted: console.log(url)
//        onLoadFinished : console.log("finished")

    }

}
