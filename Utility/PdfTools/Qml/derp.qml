import QtQuick 2.0
import QtQuick.Controls 1.0

ApplicationWindow
{
    id    : mainWinda
    width : 400
    height: 400
    visible : true

    Text
    {
        text : "herp im ready!"
        anchors.centerIn: parent
    }

    Rectangle
    {
        id:derpContainer1
        anchors.fill:parent

        Image
        {
            id:derpImage
            source:"https://s-media-cache-ak0.pinimg.com/236x/16/7b/6f/167b6facb95619c3ccc3047b475f957d.jpg"
            anchors.fill:parent

            states: State {
                         name: "p1"
                         ParentChange { target: derpImage; parent: derpContainer1; x: 10; y: 10 }
                     }

                     State {
                         name: "p2"
                         ParentChange { target: derpImage; parent: derpContainer2; x: 10; y: 10 }
                    }



        }
    }



    Button
    {

        width:30
        height:40
        text:"click me"
        onClicked: derpImage.parent=derpContainer2
    }


    ApplicationWindow
    {
        id    : window2
        width : 400
        height: 400
        visible : true

        Text
        {
            text : "herp im ready!"
            anchors.centerIn: parent
        }
        Rectangle
        {
            id:derpContainer2
            anchors.fill:parent
        }

        Button
        {

            width:30
            height:40
            text:"click me"
            onClicked:derpImage.parent=derpContainer1
        }

    }

    Timer
    {
        property bool derpWay : false
        running:true
        repeat:true
        interval: 250
        onTriggered:
        {
            if (!derpWay)
                derpImage.parent=derpContainer2
            else
                derpImage.parent=derpContainer1
            derpWay = !derpWay
        }

    }

}

