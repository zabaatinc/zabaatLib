TEMPLATE = app

QT += qml quick qml-private gui-private
CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc data.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += submodel.h mstimer.h nanotimer.h
