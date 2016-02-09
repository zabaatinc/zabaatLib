/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:LGPL21$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** As a special exception, The Qt Company gives you certain additional
** rights. These rights are described in The Qt Company LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.2
import Qt.labs.folderlistmodel 2.1
//import Zabaat.Misc.Global 1.0
import Zabaat.UI.Wolf 1.1

Item {
    id: fileBrowser
    z : 4

    property int itemWidth       : 32
    property int itemHeight      : 32
    property int fontSize        : 14
    property double scaledMargin : 2

    property color  backGroundColor   : ZGlobal.style._default
    property color  textColor         : ZGlobal.style.text.color1
    property color  secondaryTextColor: ZGlobal.style.text.color2
    property color  highlightColor    : ZGlobal.style.accent
    property color  iconColor         : ZGlobal.style.info
    property var filters              : ["*.*"]

    property string folder
    property bool shown: loader.sourceComponent

    signal fileSelected(string file)

    function selectFile(file) {
        if (file !== "") {
            folder = loader.item.folders.folder
            fileBrowser.fileSelected(file)
        }
        loader.sourceComponent = undefined
    }



    Loader {
        id: loader
        anchors.fill: parent
    }

    function show() {
        loader.sourceComponent   = fileBrowserComponent
//        loader.item.parent       = fileBrowser
//        loader.item.anchors.fill = fileBrowser
        loader.item.folder       = fileBrowser.folder
    }

    Component {
        id: fileBrowserComponent

        Rectangle {
            id: root
            color:   backGroundColor
            property bool showFocusHighlight: false
            property variant folders: folders1
            property variant view: view1
            property alias folder: folders1.folder
            property color textColor: fileBrowser.textColor

            FolderListModel {
                id: folders1
                folder: folder
                nameFilters: fileBrowser.filters
            }
            FolderListModel {
                id: folders2
                folder: folder
                nameFilters: fileBrowser.filters
            }

            Component {
                id: folderDelegate

                Rectangle {
                    id: wrapper
                    function launch() {
                        var path = "file://";
                        if (filePath.length > 2 && filePath[1] === ':') // Windows drive logic, see QUrl::fromLocalFile()
                            path += '/';
                        path += filePath;
                        if (folders.isFolder(index))
                            down(path);
                        else
                            fileBrowser.selectFile(path)
                    }
                    width: root.width
                    height: itemHeight
                    color : 'transparent'

                    Rectangle {
                        id: highlight; visible: false
                        anchors.fill: parent
                        color: fileBrowser.highlightColor
                    }

                    Item {
                        width: itemHeight; height: itemHeight
                        Text {
                            anchors.fill: parent
                            anchors.margins: scaledMargin
                            visible: folders.isFolder(index)
                            font.family: "fontAwesome"; text : "\uf07b"
                            font.pixelSize: fontSize + 4
                            color : fileBrowser.iconColor
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        id: nameText
                        anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                        text: fileName
                        anchors.leftMargin: itemHeight + scaledMargin
                        font.pixelSize: fontSize
                        color: (wrapper.ListView.isCurrentItem && root.showFocusHighlight) ? palette.highlightedText : textColor
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: mouseRegion
                        anchors.fill : parent
                        onPressed: {
                            root.showFocusHighlight = false;
                            wrapper.ListView.view.currentIndex = index;
                        }
                        onClicked: { if (folders == wrapper.ListView.view.model) launch() }
                    }

                    states: [
                        State {
                            name: "pressed"
                            when: mouseRegion.pressed
                            PropertyChanges { target: highlight; visible: true }
                            PropertyChanges { target: nameText; color: fileBrowser.secondaryTextColor }
                        }
                    ]
                }
            }

            ListView {
                id: view1
                anchors.top: titleBar.bottom
                anchors.bottom: cancelButton.top
                x: 0
                width: parent.width
                model: folders1
                delegate: folderDelegate
                highlight: Rectangle {
                    color: fileBrowser.highlightColor
                    visible: root.showFocusHighlight && view1.count != 0
                    width: view1.currentItem == null ? 0 : view1.currentItem.width
                }
                highlightMoveVelocity: 1000
                pressDelay: 100
                focus: true
                state: "current"
                states: [
                    State {
                        name: "current"
                        PropertyChanges { target: view1; x: 0 }
                    },
                    State {
                        name: "exitLeft"
                        PropertyChanges { target: view1; x: -root.width }
                    },
                    State {
                        name: "exitRight"
                        PropertyChanges { target: view1; x: root.width }
                    }
                ]
                transitions: [
                    Transition {
                        to: "current"
                        SequentialAnimation {
                            NumberAnimation { properties: "x"; duration: 250 }
                        }
                    },
                    Transition {
                        NumberAnimation { properties: "x"; duration: 250 }
                        NumberAnimation { properties: "x"; duration: 250 }
                    }
                ]
                Keys.onPressed: root.keyPressed(event.key)
            }
            ListView {
                id: view2
                anchors.top: titleBar.bottom
                anchors.bottom: parent.bottom
                x: parent.width
                width: parent.width
                model: folders2
                delegate: folderDelegate
                pressDelay: 100
                states: [
                    State {
                        name: "current"
                        PropertyChanges { target: view2; x: 0 }
                    },
                    State {
                        name: "exitLeft"
                        PropertyChanges { target: view2; x: -root.width }
                    },
                    State {
                        name: "exitRight"
                        PropertyChanges { target: view2; x: root.width }
                    }
                ]
                transitions: [
                    Transition {
                        to: "current"
                        SequentialAnimation {
                            NumberAnimation { properties: "x"; duration: 250 }
                        }
                    },
                    Transition {
                        NumberAnimation { properties: "x"; duration: 250 }
                    }
                ]
                Keys.onPressed: root.keyPressed(event.key)
            }

            ZButton {
                id: cancelButton
                width : itemWidth * 2
                height: itemHeight
//                color: "#353535"
                anchors { bottom: parent.bottom; right: parent.right; margins: 5 * scaledMargin }
                text: "Cancel"
//                horizontalAlign: Text.AlignHCenter
                onBtnClicked: fileBrowser.selectFile("")
            }

            Keys.onPressed: {
                root.keyPressed(event.key);
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Select || event.key === Qt.Key_Right) {
                    view.currentItem.launch();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    up();
                }
            }

            // titlebar
            Rectangle {
                id: titleBar
                color: fileBrowser.backGroundColor
                width: parent.width;
                height: itemHeight


                Rectangle {
                    id: upButton
                    width: titleBar.height
                    height: titleBar.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: scaledMargin

                    Text { color : fileBrowser.iconColor; anchors.fill: parent; anchors.margins: scaledMargin; font.family: "fontAwesome"; text : "\uf148"; verticalAlignment: Text.AlignVCenter; font.pixelSize: fontSize +4}
                    MouseArea { id: upRegion; anchors.fill: parent; onClicked: up() }
                    states: [
                        State {
                            name: "pressed"
                            when: upRegion.pressed
                            PropertyChanges { target: upButton; color: Qt.darker(fileBrowser.iconColor) }
                        }
                    ]
                }
                Text {
                    anchors.left: upButton.right; anchors.right: parent.right; height: parent.height
                    anchors.leftMargin: 10; anchors.rightMargin: 4
                    text: folders.folder
                    color: fileBrowser.textColor
                    elide: Text.ElideLeft; horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
                }
            }

            Rectangle {
                color: "#353535"
                width: parent.width
                height: 1
                anchors.top: titleBar.bottom
            }

            function down(path) {
                if (folders == folders1) {
                    view = view2
                    folders = folders2;
                    view1.state = "exitLeft";
                } else {
                    view = view1
                    folders = folders1;
                    view2.state = "exitLeft";
                }
                view.x = root.width;
                view.state = "current";
                view.focus = true;
                folders.folder = path;
            }
            function up() {
                var path = folders.parentFolder;
                if (path.toString().length === 0 || path.toString() === 'file:')
                    return;
                if (folders == folders1) {
                    view = view2
                    folders = folders2;
                    view1.state = "exitRight";
                } else {
                    view = view1
                    folders = folders1;
                    view2.state = "exitRight";
                }
                view.x = -root.width;
                view.state = "current";
                view.focus = true;
                folders.folder = path;
            }
            function keyPressed(key) {
                switch (key) {
                    case Qt.Key_Up:
                    case Qt.Key_Down:
                    case Qt.Key_Left:
                    case Qt.Key_Right:
                        root.showFocusHighlight = true;
                    break;
                    default:
                        // do nothing
                    break;
                }
            }
        }
    }


        Rectangle {
            id : __titleBorders
            width  : parent.width + border.width
            height : itemHeight
            border.width: 1
            color : 'transparent'
            visible : shown
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            width : parent.width + border.width
            height : parent.height + border.width - itemHeight
            border.width: 1
            color : 'transparent'
            visible : shown
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top : __titleBorders.bottom
        }





}
