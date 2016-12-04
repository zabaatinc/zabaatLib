#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "zprinter.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<zprinter>("Zabaat.Utility.ZPrinter",1,0,"ZPrinter");
    //engine.addImportPath(QStringLiteral("qrc:///lib"));
    engine.load(QUrl(QStringLiteral("qrc:/Example.qml")));

    return app.exec();
}
