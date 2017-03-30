#ifndef QMLSOCKETIOCLIENTPLUGIN_H
#define QMLSOCKETIOCLIENTPLUGIN_H

#include <QQmlExtensionPlugin>
#include "qmlSocketIOClient.h"
#include <qqml.h>
#include <QQmlApplicationEngine>

class qmlsocketIO : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat.SocketIO")

public:
    void registerTypes(const char *uri) {
         qmlRegisterType<qmlSocketIOClient>(uri , 1, 0, "ZSocketIO");
    }

    static void registerAllQmlTypes(QQmlApplicationEngine &engine, QString path = "Zabaat.SocketIO") {
        qmlRegisterType<qmlSocketIOClient>(path.toStdString().c_str() , 1, 0, "ZSocketIO");
    }
};

#endif // QMLSOCKETIOCLIENTPLUGIN_H
