#ifndef ZPRINTERPLUGIN_H
#define ZPRINTERPLUGIN_H

#include <QQmlExtensionPlugin>
#include <qqml.h>
#include "zprinter.h"
//#include <QPageSize>

class zprinterplugin : public QQmlExtensionPlugin{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat")

    public:
        void registerTypes(const char *uri){
            //@uri Zabaat.Utility.ZPrinter
//            qRegisterMetaType(QPageSize);
            qmlRegisterType<zprinter>(uri,1,0,"ZPrinter");
        }
};


#endif // ZPRINTERPLUGIN_H
