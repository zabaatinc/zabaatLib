QT += qml quick network

# Input
HEADERS         += zpaths.h zfilerw.h progress.h zfiledownloader.h zfileio.h
QML_IMPORT_PATH += $$PWD

ios:{
    QMAKE_CXXFLAGS += -fobjc-arc
}



