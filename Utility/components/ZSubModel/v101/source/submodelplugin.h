#ifndef SUBMODELPLUGIN_H
#define SUBMODELPLUGIN_H

#include <QQmlExtensionPlugin>
#include "submodel.h"
#include <qqml.h>

class submodelplugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat")

public :
    void registerTypes(const char *uri) {
        qmlRegisterType<submodel>(uri, 1, 1, "CSubModel");
    }

};

#endif // SUBMODELPLUGIN_H
