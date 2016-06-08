import QtQuick 2.4
import Zabaat.Misc.Global 1.0


/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Creates a radial display of values to be picked. Comes with quite a bit of configuration options.

    \note If the values in the model are numeric, make sure the greatest value is the first thing in the array!
    \code
        //Allows for
        ZBase_RadialPicker
        {
            id : radPicker_1
            model : [4,1,2,3]
            blobColor : "green"
            accentColor : ZGlobal.style.danger
            extraHoverPx : 20
            digitalOnly: true
            enableMagnitudeChange : true
            maxMagnitude : 2
        }

        ZBase_RadialPicker
        {
            id : radPicker_2
            model : ['eat','sleep','derp','more derps']
            extraHoverPx : 20
            digitalOnly: false
            enableMagnitudeChange : false
        }
    \endcode
*/
Rectangle
{
    id : rootObject
    property var self : this
    color : ZGlobal.style._default

    /*! The color of the clickable blobs that are autogenerated after reading the model property. Defaults to \c 'orange'*/
    property color blobColor : "black"

    /*! The color of the line(s). Defaults to \c ZGlobal.style.accent*/
    property color accentColor : ZGlobal.style.accent

    property var uniqueProperties : ['model','digitalOnly','enableMagnitudeChange','maxMagnitude','magnitude','value','extraHoverPx']
    property var uniqueSignals    : ({blobClicked  :[]})

    /*! Easy way to access the clickable blobs. Not recommended to mess with this. They are auto managed by this class.*/
    property var blobs            : []

    /*! The extra amount of pixels that the mouse area extends to (beyond the visual representation of this element). Defaults to 400*/
    property int extraHoverPx     : 50

    /*! The heart of this qml class. The blobs will be titled this. The model can be an array of numbers or an array of strings. Both are acceptable.
        In the case of numbers, the area between the blobs will be treated as ticks to the next blob number.*/
    property var    model                 : ['eat','sleep','derp','more derps']

    /*! If true, will not allow to pick any values except on the blobs themselves. E.g, you can't have analog values in between the blobs. If false, you will be allowed to do so*/
    property bool   digitalOnly           : false

    /*! Allows for magnitude change, which is represented by the length of the line rectangle!*/
    property bool   enableMagnitudeChange : true

    /*! The maximum magnitude that this calendar can achieve. A max magnitude value of 1 allows the line to go as far as the radius of the circle. 2 will double it and so forth. A value of -1 will
        make the qmlclass ignore the maxMagnitude limit so the line can be as long as you want!*/
    property double maxMagnitude          : 1 //-1 means we dont check it! It can be as long as it wants!

    /*! The current magnitude of the component. Auto adjusts as you click around*/
    property double magnitude             : 1

    /*! The current value of the component. This is very smart and behaves kind of differently depending on what type of model it is using and if digitalOnly is turned off or on
        \example
            In the case of a model like this: \c model:[12,3,6,9],
            If digitalOnly is set to true, you can only set the value to 12,3,6 or 9 by changing the value property or by click on the blobs themselves. Otherwise, if you click anywhere
            between the numbers, it will autocalculate what the numbers should be! Let's say you clicked halfway between 3 and 6, you will get a 4.5 as your value!
         \example
            In the case of a model like this: \c model:["eat","sleep","program","repeat"]
            If digitalOnly is set to true, you can only set the value to "eat","sleep","program" or "repeat" by changing the value property or by click on the blobs themselves. Otherwise, if you click anywhere
            between the values, the value returned will be an object which will report the two things you clicked between and how far you were from them. For instance, if you clicked between eat and sleep, the
            value will become: \c { eat : 0.5, sleep : -0.5 }!
    */
    property var    value                 : model && model.length > 0 ? model[0] : 0
    signal blobClicked()
    onValueChanged:
    {
        if(!line.noFeedback && model && model.length > 1)
        {
            line.noFeedback = true

            var theta = 360 / blobs.length
            if(typeof value === 'object')
            {
                for(var o in value)
                {
                    for(var b in blobs)
                    {
                        var k = blobs[b].text.text
                        if(k == o)
                        {
                            var r    =  blobs[b].angle
                            var flt  = value[o] - Math.floor(value[o])

                            if(digitalOnly)    blobHover(b)
                            else               line.rotation = r + (theta * flt)

                            return
                        }
                    }
                }
            }
            else
            {
                for(b = 0 ; b <= blobs.length; b++)
                {
                    k  = Number(blobs[b].text.text)
                    if(k != null && value >= k)
                    {
                        if(digitalOnly)
                            blobHover(b)
                        else
                        {
                            var bb =  b ==  blobs.length - 1? 0 : b + 1
                            var k2 =  Number(blobs[bb].text.text)

                            if(k2)
                            {
                                if(bb == 1)
                                    k2 += k

                                var min, max
                                if(k <= k2)
                                {
                                    r = blobs[b].angle
                                    min = k
                                    max = k2
                                }
                                else
                                {
                                    r = blobs[bb].angle
                                    min = k2
                                    max = k
                                }


                                flt = (value - min) / (max - min)
                                line.rotation = r + (theta * flt)
                            }
                        }
                        break
                    }

                }
            }

            line.noFeedback = false
        }
    }


    width  : 300
    onWidthChanged: refresh()

    height : width
    onHeightChanged:
    {
        if(height != width)
            height = width
    }

    radius : width/2
    onModelChanged: refresh()

    /*! Gets called when the model is changed or the dimensions of the object are changed. Responsible for creating all the blobs and putting them nicely in a circle*/
    function refresh()
    {
        if(model)
        {
            blobs = []
            blobContainer.clear()

            for(var i = 0; i < model.length; i++)
                makeNewBlob(model[i])
        }
    }

//    Text
//    {
//        text : typeof value !== 'object' ? value : JSON.stringify(value,null,2)
//        font.pointSize:  16
//        x : -width
//    }

    /*! The line that represents the value of this qml object through its rotation (the clockhand if you are using this for time!)*/
    Rectangle
    {
        id : line
        width  : parent.width/2 - 20 >= 0 ? magnitude * parent.width/2 - 20 : magnitude * 2
        height : 10

        color               : ZGlobal.style.accent
        anchors.left        : parent.left
        anchors.leftMargin  : parent.width/2
        anchors.top         : parent.top
        anchors.topMargin   : parent.height/2
        transformOrigin     : Rectangle.Left
        border.width: 1
        smooth : true


        property bool noFeedback : false

        onRotationChanged:
        {
            if(blobs.length > 1 && !noFeedback)
            {
                var rot = rotation
                rot     = (rot % 360 )
                if(rot < 0)
                    rot += 360

                for(var b = 0; b < blobs.length ; b++)
                {
                    var bb = b == blobs.length -1 ? 0 : b + 1

                    var angle1 = blobs[b].angle
                    var angle2 = blobs[bb].angle
                    if(angle2 == 0)
                        angle2 = 360

                    if(rot >= angle1 && rot <= angle2)
                    {
                        noFeedback = true

                        var min = Math.min(angle1, angle2)
                        var max = Math.max(angle1, angle2)
                        if(min == max == 360)
                            min = 0

                        var flt = (rot - min) / (max - min)

                        //if its digital, we need to find out what its closer to!
                        if(digitalOnly)
                        {
                            if(flt < 0.51)
                            {
                                value = blobs[b].text.text
                                line.rotation = angle1
                            }
                            else
                            {
                                value = blobs[bb].text.text
                                line.rotation = angle2
                            }
                        }
                        else
                        {
                            //if we are dealing with numbers!
                            if(!isNaN(blobs[b].text.text))
                                value = (Number(blobs[b].text.text) + flt).toFixed(2)
                            else
                            {
                                var valObj = {}
                                valObj[blobs[b].text.text]  =  flt
                                valObj[blobs[bb].text.text] =  flt - 1
                                value = valObj
                            }
                        }

                        noFeedback = false
                        break
                    }
                }
            }

        }
    }


    function printAllPositiveAngles()
    {
        for(var b in blobs)
        {
            if(blobs[b].angle < 0)   console.log(b,  (blobs[b ].angle % 360) + 360)
            else                     console.log(b,  (blobs[b ].angle))
        }
    }


    MouseArea
    {
        id     : msArea
        width  : parent.width + extraHoverPx
        height : parent.height + extraHoverPx
        x      : -extraHoverPx/2
        y      : -extraHoverPx/2

        property bool dothething : false

        onPressed : dothething = true
        onReleased: dothething = false

        hoverEnabled: true
        onPositionChanged :
        {
            if(dothething)
            {
                var pt = mapToItem(rootObject,mouse.x, mouse.y)
                calcAngle(pt.x , pt.y)
            }
        }
    }


    function calcAngle(x,y)
    {
        x -= rootObject.width/2
        y -= rootObject.height/2
        var mag = Math.sqrt(Math.pow(x,2) + Math.pow(y,2)) / (rootObject.width/2 - 20)    //rootoBject.width/2 is the radius!
        var deg = Math.atan(y / x) * 180 / Math.PI

        if     (x < 0 && y < 0)          deg = -180 + deg
        else if(x < 0 && y >= 0)        deg  = -180 + deg

        line.rotation = deg

        if(enableMagnitudeChange)
        {
            magnitude = mag
            if(maxMagnitude >= 0 && magnitude > maxMagnitude)
                magnitude = maxMagnitude
        }
    }




    function makeNewBlob(title)
    {
        var blob = ZGlobal.functions.getQmlObject(['QtQuick 2.4'], 'Rectangle
                                                                    {
                                                                        signal hovered(int index)
                                                                        property double angle : 0
                                                                        property int index : 0
                                                                        property alias text : _text
                                                                        Text { id : _text ; anchors.centerIn: parent }
                                                                        MouseArea
                                                                        {
                                                                            anchors.fill: parent
                                                                            hoverEnabled : true
                                                                            onEntered    : parent.scale = 1.2
                                                                            onExited     : parent.scale = 1
                                                                            onClicked : hovered(index)
                                                                        }

                                                                    }' , blobContainer)

        blob.text.text  = title//Qt.binding(function() { return blob.angle}  )//title
        blob.text.font  = ZGlobal.style.text.normal
        blob.border.width = 1
        blob.border.color='white'
        blob.width      = Qt.binding(function()  {return  rootObject.width/8     } )
        blob.height     = Qt.binding(function()  {return  blob.width             } )
        blob.radius     = Qt.binding(function()  {return  blob.width/2           } )
        blob.text.color = "white"//Qt.binding(function()  { return rootObject.accentColor } )
        blob.color      = Qt.binding(function()  { return rootObject.blobColor   } )
        blob.index      = blobs.length
        blob.hovered.connect(blobHover)
        blobs.push(blob)
        updateBlobs()
    }


    function blobHover(index)
    {
        var blob = blobs[index]
        magnitude = maxMagnitude
        value = blob.text.text
        blobClicked()
    }

    function updateBlobs()
    {
        //sets their positions correctly!!
        if(blobs && blobs.length > 0)
        {
            var r      = rootObject.width/2  //get our radius!
            var theta  = 360 / blobs.length

            var angle  = -90
            for(var b = 0; b < blobs.length; b++)
            {
                blobs[b].x = r * Math.cos(Math.PI * angle/180) - blobs[b].width/2
                blobs[b].y = r * Math.sin(Math.PI * angle/180) - blobs[b].height/2
                blobs[b].angle = angle < 0 ? (angle % 360) + 360 : angle

                //if(blobs[b].angle < 0)   console.log(b,  (blobs[b ].angle % 360) + 360)
                //else                     console.log(b,  (blobs[b ].angle))

                angle += theta
            }
        }
    }


    Item
    {
        id : blobContainer
        x : parent.width / 2
        y : parent.height / 2

        function clear()
        {
            for(var i = 0; i < children.length; i++)
            {
                children[i].parent = null
                try
                {
                    children[i].destroy()
                }catch(e) { console.log('ZBase_RadialPicker.blobContainer.clear() --- ' ,e.message)}
            }
            children = []
        }
    }


}