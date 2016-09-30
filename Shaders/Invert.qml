import QtQuick 2.5
Effect {
    property var fill
    property vector4d dim : !source || !fill ? Qt.vector4d(-1,-1,-1,-1) :
                                               Qt.vector4d(source.x/fill.width,
                                                           source.y/fill.height,
                                                           (source.x + source.width)/fill.width,
                                                           (source.y + source.height)/fill.height
                                                          )
    fragmentShaderName: "invert.fsh"
}
