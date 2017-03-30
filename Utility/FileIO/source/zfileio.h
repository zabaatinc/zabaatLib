#ifndef ZFILEIO_PLUGIN_H
#define ZFILEIO_PLUGIN_H

#include <QQmlExtensionPlugin>
#include "zfilerw.h"
#include "zpaths.h"
#include "zfiledownloader.h"
#include <qqml.h>
#include <QFileInfo>
#include <QList>
#include <QQmlApplicationEngine>

class zfileio : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat.Utility.FileIO")

public:
    void registerTypes(const char *uri) {
         qmlRegisterType<ZFileRW>(uri , 1, 0, "ZFileOperations");
         qmlRegisterType<ZPaths> (uri , 1, 0, "ZPaths" );
         qmlRegisterType<fileDownloader>(uri, 1,0, "ZFileDownloader");
    }

    static void registerAllQmlTypes(QQmlApplicationEngine &engine, QString path = "Zabaat.Utility.FileIO") {
        qmlRegisterType<ZFileRW>       (path , 1, 0, "ZFileOperations");
        qmlRegisterType<ZPaths>        (path , 1, 0, "ZPaths" );
        qmlRegisterType<fileDownloader>(path , 1, 0, "ZFileDownloader");
        engine.addImportPath("qrc:/");
    }
};


#endif // ZFILEIO_PLUGIN_H
