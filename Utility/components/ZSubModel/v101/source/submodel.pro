#TEMPLATE = app
QT += qml quick  qml-private core-private
TEMPLATE = lib
TARGET = submodel
CONFIG += qt plugin c++11
TARGET = $$qtLibraryTarget($$TARGET)
uri = Zabaat.Utility

MOC_DIR = $$OUT_PWD/moc
OBJECTS_DIR = $$OUT_PWD/obj

#SOURCES += main.cpp
RESOURCES += qml.qrc data.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += submodel.h mstimer.h nanotimer.h submodelplugin.h

# Ensure that the application will see the import path for the SubModel module:
#   * On Windows, do not build into a debug/release subdirectory.
#   * On OS X, add the plugin files into the bundle.
#osx {
#   plugin.files = $$OUT_PWD/TARGET
#   plugin.path = Contents/Plugins
#   QMAKE_BUNDLE_DATA = plugin
#}
