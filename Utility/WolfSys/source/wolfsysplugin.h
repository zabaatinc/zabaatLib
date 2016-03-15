#ifndef WOLFSYSPLUGIN_H
#define WOLFSYSPLUGIN_H

#include <QQmlExtensionPlugin>
#include "wolfsys.h"
#include <qqml.h>

class WolfSysPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "WolfMan")

public:
    void registerTypes(const char *uri)
    {
        // @uri WolfMan
        qmlRegisterType<WolfSys>(uri, 1, 0, "WolfSys");
    }
};

#endif // WOLFSYSPLUGIN_H

