#ifndef SUBMODELPLUGIN_H
#define SUBMODELPLUGIN_H

#include <QQmlExtensionPlugin>
#include "wolfsubmodel.h"
#include <qqml.h>
#include <QQmlApplicationEngine>

class submodel : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat.Utility.SubModel")

public :
    void registerTypes(const char *uri) {
        qmlRegisterType<wolfsubmodel>(uri, 1, 0, "CSubModel");
    }

    static void registerAllQmlTypes(QQmlApplicationEngine &engine, QString path = "Zabaat.Utility.SubModel") {
        qmlRegisterType<wolfsubmodel>(path.toStdString().c_str(), 1, 0, "CSubModel");
        engine.addImportPath("qrc:/");
    }

};

#endif // SUBMODELPLUGIN_H
