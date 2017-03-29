TEMPLATE    = lib
QT          += qml quick
CONFIG      += qt c++11 no_keywords plugin
#RESOURCES   += qml.qrc
TARGET      = qmlsocketIO
TARGET      = $$qtLibraryTarget($$TARGET)

uri         = Zabaat.SocketIO

OBJECTS_DIR = tmp
MOC_DIR     = tmp

#Input
HEADERS += src/qmlSocketIOClient.h \
           src/mstimer.h  \
           src/qmlsocketIO.h \
           $$PWD/socketio_module/src/sio_client.h  \
           $$PWD/socketio_module/src/sio_message.h \
           $$PWD/socketio_module/src/sio_socket.h  \
           $$PWD/socketio_module/src/internal/sio_client_impl.h \
           $$PWD/socketio_module/src/internal/sio_packet.h
#    src/qmlsocketioclientstring.h


SOURCES += $$PWD/socketio_module/src/sio_client.cpp \
           $$PWD/socketio_module/src/sio_socket.cpp \
           $$PWD/socketio_module/src/internal/sio_packet.cpp \
           $$PWD/socketio_module/src/internal/sio_client_impl.cpp #main.cpp

DISTFILES += main.qml \
             android/AndroidManifest.xml \
             android/gradle/wrapper/gradle-wrapper.jar \
             android/gradlew \
             android/res/values/libs.xml \
             android/build.gradle \
             android/gradle/wrapper/gradle-wrapper.properties \
             android/gradlew.bat \
             qmldir


INCLUDEPATH += $$PWD/socketio_module/lib/rapidjson/include \
               $$PWD/socketio_module/lib/websocketpp


win32:{ #include include and link boost! Fix this and android later!!! OH BOYO!!!
    INCLUDEPATH +=  C:/boost/include/boost-1_60
    LIBS        += "-LC:/boost/lib" -lboost_random
    LIBS        += "-LC:/boost/lib" -lboost_system
    LIBS        += "-LC:/boost/lib" -lboost_date_time
    LIBS        += -lws2_32     #include WINSOCKETS to stop the stupid ass WSA startup errors!
#libboost_random-mgw49-mt-1_60
}

android:{
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    INCLUDEPATH +=  C:/boost_android/include/

    contains(ANDROID_TARGET_ARCH, armeabi-v7a) {
        LIBS  += "-LC:/boost_android/armeabi-v7a/lib/"
        LIBS  += -lboost_date_time -lboost_system -lboost_random
        #ANDROID_EXTRA_LIBS += C:/boost_android/armeabi-v7a/lib/libboost_random.a
        #ANDROID_EXTRA_LIBS += C:/boost_android/armeabi-v7a/lib/libboost_system.a
        #ANDROID_EXTRA_LIBS += C:/boost_android/armeabi-v7a/lib/libboost_date_time.a
    }
}

osx {
  INCLUDEPATH += $$PWD/boost/include/1_5_0
  LIBS        += -L$$PWD/boost/osx/
  LIBS        += -lboost_date_time -lboost_system -lboost_random


   plugin.files = $$OUT_PWD/TARGET
   plugin.path = Contents/Plugins
   QMAKE_BUNDLE_DATA = plugin
}

ios:{
  INCLUDEPATH += $$PWD/boost/include/1_6_0
  LIBS        += -L$$PWD/boost/ios/ -lboost
  PRE_TARGETDEPS += $$PWD/boost/ios/libboost.a

  CONFIG += static
  QMAKE_MOC_OPTIONS += -Muri=Zabaat.SocketIO
}

#include(deployment.pri)
# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH =



#macx: LIBS += -L$$PWD/boost/ios/ -lboost
#INCLUDEPATH += $$PWD/boost/include/1_6_0
#DEPENDPATH += $$PWD/boost/include/1_6_0
#macx: PRE_TARGETDEPS += $$PWD/boost/ios/libboost.a
