QMAKE_CXXFLAGS += -std=c++0x -pthread -w -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8

TEMPLATE = lib
CONFIG   += plugin
QT       += qml quick

uri     = WolfMan
DESTDIR = WolfMan.WolfSys      #File
TARGET  = wolfsysplugin        #filereaderplugin

OBJECTS_DIR = tmp
MOC_DIR = tmp

# Input
HEADERS     += wolfsys.h wolfsysplugin.h zSystem.h
OTHER_FILES = qmldir
