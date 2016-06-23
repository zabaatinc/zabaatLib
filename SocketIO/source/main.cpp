#undef main

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "src/qmlSocketIOClient.h"

#include <boost/foreach.hpp>
#include <boost/any.hpp>

#include <vector>
#include <iostream>

typedef boost::any var;
using namespace std;

void testForEach(){
    vector<double> v(10);
    BOOST_FOREACH(double &x, v){
        x = 10;
    }
    BOOST_FOREACH(double x, v){
        cout << x << endl;
    }
}
void testAny(){
    var a = 10;
    var b = std::string("Hello");
    var c = 10.2;

    cout << "running " << BOOST_CURRENT_FUNCTION << endl;
    cout << boost::any_cast<int>   (a) << " " <<
            boost::any_cast<std::string> (b) << " " <<
            boost::any_cast<double>(c) << " " << endl;
}



int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<qmlSocketIOClient>("Zabaat.SocketIO",1,0,"ZSocketIOClient");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

//    testForEach();
//    testAny();


    return app.exec();
}
