/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2014-2015 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4

pragma Singleton
QtObject {
    id: units

    /*!
       \internal
       This holds the pixel density used for converting millimeters into pixels. This is the exact
       value from \l Screen:pixelDensity, but that property only works from within a \l Window type,
       so this is hardcoded here and we update it from within \l ApplicationWindow
     */
    property real pixelDensity: 4.46
    onPixelDensityChanged: {
//        var diagonal = Math.sqrt( Math.pow(Screen.width,2) + Math.pow(Screen.height,2) )
        console.log("PIXELDENSITY",pixelDensity )

    }

    property real multiplier  : 1 //default multiplier, but can be changed by user

    property real defaultWidth : 1920
    property real defaultHeight : 1080

    property bool loaded: false

    /*!
       This is the standard function to use for accessing device-independent pixels. You should use
       this anywhere you need to refer to distances on the screen.
     */
    function dp(number) {
        if(!loaded) {
            console.log("**********************************")
            console.trace()
            console.log("**********************************")
        }

        var res = (number*((pixelDensity*25.4)/160))*multiplier;
//        console.log("33333333333333  RESULT FOR" , number, "=", res, "px den",pixelDensity, "multi", multiplier)
        return res;
    }

    function gu(number) {
        return number * gridUnit
    }

    onLoadedChanged : if(loaded){
        gridUnit = dp(64);
    }

    property int gridUnit: 0

    readonly property real ptSize : dpCalc.paintedHeight
    onPtSizeChanged               : console.log("1 pt is", ptSize , "pixels")

    property Text dpCalcText : Text{
        id : dpCalc
        height : paintedHeight
        font.pointSize : 1
        text : "|"
    }


}
