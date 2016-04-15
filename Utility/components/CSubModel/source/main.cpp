#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "submodel.h"
#include <QtQml>
#include <iostream>
#include <vector>
#include <cmath>

using namespace std;
template<typename T, int N> using raw_array = T[N];
int main(int argc, char *argv[])

{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    auto c = 'c';
    auto a(pow(2,512));
    auto &&z    = raw_array<int,5>{1,2,3,4,5};
    auto &&derp = raw_array<string,2>{"brett","green"};
    cout << a << " " << a + 1 << " " << z[4] << endl;


    qmlRegisterType<submodel>("Wolf",1,0,"SubModel");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
