#ifndef PDFWRITERPLUGIN
#define PDFWRITERPLUGIN

#include <QQmlExtensionPlugin>
#include "pdfwriter.h"
#include <qqml.h>

class PdfWriterPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Zabaat")

public :
    void registerTypes(const char *uri)
    {
        //@uri Zabaat.PdfTools
        qmlRegisterType<pdfWriter>(uri, 1,0, "PdfWriter");
    }
};

#endif // PDFWRITERPLUGIN

