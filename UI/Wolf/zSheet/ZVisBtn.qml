import QtQuick 2.0
import Zabaat.UI.Wolf 1.0

ZButton
{
    property var self
    property var target

    onBtnClicked:
    {
        target.visible   = true
        self.visible     = false
    }
}
