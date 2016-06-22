#ifndef SUBMODELPLUGIN_H
#define SUBMODELPLUGIN_H

#include <QQmlExtensionPlugin>
#include "wolfsubmodel.h"
#include <qqml.h>

class submodel : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat.Utility.SubModel")

public :
    void registerTypes(const char *uri) {
        qmlRegisterType<wolfsubmodel>(uri, 1, 0, "CSubModel");
    }

};

#endif // SUBMODELPLUGIN_H
