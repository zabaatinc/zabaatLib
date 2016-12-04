#BUILD With LIB to get dll. Make sure you copy printsupport !
#To test if build works, then build with APP.

TEMPLATE = lib
QT += qml quick printsupport


CONFIG += c++11
SOURCES += main.cpp

RESOURCES += qml.qrc
OBJECTS_DIR    = $$OUT_PWD/tmp
MOC_DIR        = $$OUT_PWD/tmp

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS   += zprinter.h zprinterplugin.h
DISTFILES += Example.qml
