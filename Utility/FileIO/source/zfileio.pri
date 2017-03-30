QT += qml quick network

# Input
INCLUDEPATH += $$PWD
HEADERS += $$PWD/zpaths.h $$PWD/zfilerw.h $$PWD/progress.h $$PWD/zfiledownloader.h $$PWD/zfileio.h
QML_IMPORT_PATH += $$PWD
RESOURCES += $$PWD/fileio.qrc

ios:{
    QMAKE_CXXFLAGS += -fobjc-arc
}



