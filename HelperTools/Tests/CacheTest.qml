import QtQuick 2.5
import Zabaat.Cache 1.0
import Zabaat.HelperTools 1.0

Item {


    ImageCache {
        id : ic

        Component.onCompleted: {
            ic.add("http://icons.iconarchive.com/icons/limav/game-of-thrones/512/Stark-icon.png", "GOT/Stark")
            ic.add("http://vignette3.wikia.nocookie.net/gameofthrones/images/8/8a/House-Lannister-Main-Shield.PNG/revision/latest/scale-to-width-down/250?cb=20151207184048", "GOT/Lannister")

            ic.add("http://vignette2.wikia.nocookie.net/fantendo/images/f/fa/MP10_U_Mario_icon.png/revision/latest?cb=20120731170647", "Nintendo/Mario")
            ic.add("http://vignette3.wikia.nocookie.net/fantendo/images/a/ac/MP10_U_Luigi_icon.png/revision/latest?cb=20120731171018" , "Nintendo/Luigi")
//            cv.cachePtr = ic
        }
    }

    CacheView {
         id : cv
         anchors.fill: parent
         cachePtr: ic


    }


}
