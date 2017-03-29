QMAKE_CXXFLAGS += -std=c++0x -pthread -w -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8

TEMPLATE = lib
TARGET = wolfsysplugin
QT += qml quick
CONFIG += qt plugin c++11
TARGET = $$qtLibraryTarget($$TARGET)

PLUGIN_CLASS_NAME = wolfsysplugin
uri = Zabaat.Utility.WolfSys

OBJECTS_DIR = tmp
MOC_DIR = tmp

# Input
HEADERS     += wolfsys.h wolfsysplugin.h zSystem.h
DISTFILES   = qmldir
OTHER_FILES = qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}

osx {
   plugin.files = $$OUT_PWD/TARGET
   plugin.path = Contents/Plugins
   QMAKE_BUNDLE_DATA = plugin
}

ios:{
    CONFIG += static
    QMAKE_MOC_OPTIONS += -Muri=Zabaat.Utility.WolfSys
}
