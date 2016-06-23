#ifndef QMLSOCKETIOCLIENTPLUGIN_H
#define QMLSOCKETIOCLIENTPLUGIN_H

#include <QQmlExtensionPlugin>
#include "qmlSocketIOClient.h"
#include <qqml.h>

class qmlsocketIO : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat.SocketIO")

public:
    void registerTypes(const char *uri) {
         qmlRegisterType<qmlSocketIOClient>(uri , 1, 0, "ZSocketIO");
    }
};

#endif // QMLSOCKETIOCLIENTPLUGIN_H
