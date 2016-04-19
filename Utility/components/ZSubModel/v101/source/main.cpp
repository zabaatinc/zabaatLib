#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "submodel.h"
#include <QtQml>
#include <iostream>
#include <vector>
#include <cmath>

using namespace std;
int main(int argc, char *argv[])

{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<submodel>("Zabaat.Utility.ZSubModel",1,1,"CSubModel");
    engine.load(QUrl(QStringLiteral("qrc:/Test_Empty.qml")));

    return app.exec();
}
