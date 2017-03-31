QT += qml quick qml-private core-private

#Input
HEADERS += $$PWD/mstimer.h $$PWD/nanotimer.h $$PWD/wolfsubmodel.h $$PWD/submodel.h
RESOURCES += $$PWD/submodel.qrc
INCLUDEPATH += $$PWD
ios:{
    QMAKE_CXXFLAGS += -fobjc-arc
}
