#ifndef ZFILEIO_PLUGIN_H
#define ZFILEIO_PLUGIN_H

#include <QQmlExtensionPlugin>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QFileInfo>
#include <QList>
#include "zfilerw.h"
#include "zpaths.h"
#include "zfiledownloader.h"

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
        qmlRegisterType<ZFileRW>       (path.toStdString().c_str() , 1, 0, "ZFileOperations");
        qmlRegisterType<ZPaths>        (path.toStdString().c_str() , 1, 0, "ZPaths" );
        qmlRegisterType<fileDownloader>(path.toStdString().c_str() , 1, 0, "ZFileDownloader");
        engine.addImportPath("qrc:/");
    }


};


#endif // ZFILEIO_PLUGIN_H
