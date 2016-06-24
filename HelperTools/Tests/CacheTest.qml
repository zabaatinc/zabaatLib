import QtQuick 2.5
import Zabaat.Cache 1.0
import Zabaat.HelperTools 1.0

Item {


    ImageCache {
        id : imgCache
    }

    CacheView {
         id : cv
         anchors.fill: parent
         cachePtr: imgCache
    }

}
