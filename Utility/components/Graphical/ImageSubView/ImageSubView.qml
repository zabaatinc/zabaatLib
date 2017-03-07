import QtQuick 2.5
//Displays the part of the image determined by the subRect property
//subRect and imgSize are both needed.
//imgSize is the size of the image in which the subRect exists
//subRect is the location (x,y,width,height) within (imgSize);
//the width & the height of rootObject is the canvas into which the subrect is painted.
Item {
    id : rootObject
    property point imgSize
    property rect  subRect
    property alias source    : img.source
    property alias cache     : img.cache
    property alias fillMode  : img.fillMode
    clip : true
    Image {
        id       : img
        fillMode : Image.PreserveAspectFit
        x        : -r.x      * width
        y        : -r.y      * height
        width    : r.width   * rootObject.width
        height   : r.height  * rootObject.height
        property rect r : {
            //uses imgSize && subRect to determine stuffs
            var x      = subRect.x  / imgSize.x;
            var y      = subRect.y  / imgSize.y;
            var width  = imgSize.x / subRect.width;
            var height = imgSize.y / subRect.height;
            return Qt.rect(x,y,width,height);
        }
    }
}
