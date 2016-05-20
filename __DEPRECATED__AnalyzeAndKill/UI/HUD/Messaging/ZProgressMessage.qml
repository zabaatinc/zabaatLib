import QtQuick 2.0

ZDefaultMessage
{
    bgkColor: "white"
    Rectangle
    {
        id : rect
        width : 32
        height : width
        radius : height/2
        x : -width
        gradient : Gradient
        {
            GradientStop { position : 0.0 ; color : "green" }
            GradientStop { position : 1.0 ; color : ZGlobal.style.danger }
        }
        visible : parent.height > 0
    }

    RotationAnimation
    {
        target : rect
        property : "rotation"
        from : 0
        to : 360
        direction: RotationAnimation.Clockwise
        duration : 250
        loops : Animation.Infinite
        running : true
    }


}
