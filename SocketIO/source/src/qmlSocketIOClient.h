#ifndef QMLSOCKETIOCLIENT_H
#define QMLSOCKETIOCLIENT_H

#include <QObject>
#include <QDebug>
#include "../socketio_module/src/sio_client.h"
#include "../socketio_module/src/sio_message.h"
#include <QStringList>
#include <QFile>

#include <QJSEngine>
#include <functional>
#include <mutex>
#include <cstdlib>
#include <boost/function.hpp>
#include <boost/any.hpp>
#include <QJSValue>
#include <QJSValueIterator>
#include <string>
#include <QJSValueList>

#include <QVariant>

#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonDocument>
#include <map>
#include <QTimer>
#include <QQmlEngine>

//#include <rapidjson/rapidjson.h>

#ifdef WIN32
#define BIND_EVENT(IO,EV,FN) \
    do{ \
        socket::event_listener_aux l = FN;\
        IO->on(EV,l);\
    } while(0)

#else
#define BIND_EVENT(IO,EV,FN) \
    IO->on(EV,FN)
#endif


using std::placeholders::_1;
using std::placeholders::_2;
using std::placeholders::_3;
using std::placeholders::_4;

struct dataHolder {
    QJSValue     function;
    QJSValueList params;

    void call(){
        if(function.isCallable()){
            function.call(params);
        }
    }

};


class qmlSocketIOClient : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString sessionId READ sessionId NOTIFY sessionIdChanged) //ready only property
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QStringList registeredEvents READ registeredEvents WRITE setRegisteredEvents NOTIFY registeredEventsChanged)
    Q_PROPERTY(uint attemptedReconnects READ attemptedReconnects NOTIFY attemptedReconnectsChanged)
    Q_PROPERTY(int reconnectLimit READ reconnectLimit WRITE setReconnectLimit NOTIFY reconnectLimitChanged)
    Q_PROPERTY(bool reconnecting READ reconnecting NOTIFY reconnectingChanged)

public :
    qmlSocketIOClient(QObject * parent = 0) : QObject(parent) {
        init();
    }
    ~qmlSocketIOClient() {
        timer->stop();
//        timer->deleteLater();
    }

    QString sessionId() { return m_sessionId; }
    bool isConnected()  { return m_connected; }

    Q_INVOKABLE void connect(QString uri , QJSValue js = QJSValue::NullValue){
        if(reconnecting()){ //yay. disconnect if we are in our reconnect mode!
            disconnect();
        }

        std::map<std::string,std::string> query;

        if(js.isObject()) {
            QJSValueIterator it(js);
            while(it.hasNext()){
                it.next();
                query[it.name().toStdString()] = it.value().toString().toStdString();
            }

            if(query.size() > 0){
                Q_EMIT info(QString(BOOST_CURRENT_FUNCTION) + " connecting with " + query.size() + " params to:" + uri);
            }

        }

        client.connect(uri.toStdString(), query);
    }
    Q_INVOKABLE void disconnect(){
        setAttemptedReconnects(0);
        client.close();
//        client.get_sessionid()
    }

    //REGISTERED EVENTS
    QStringList registeredEvents() { return m_registeredEvents; }
    void setRegisteredEvents(QStringList nl) {
        client.socket()->off_all();
        m_registeredEvents.clear();

        setDefaultListeners();
        addEvents(nl);
    }

    Q_INVOKABLE void addEvents(QStringList l){
        for(int i = l.size() -1; i >=0; --i){
            addEvent(l[i]);
        }
    }
    Q_INVOKABLE bool addEvent(QString event){
        if(!m_registeredEvents.contains(event)){

            client.socket()->on(event.toStdString(), [&](sio::event &ev){
                                                       Q_EMIT serverResponse(QString::fromStdString(ev.get_name()), transformMessage(ev.get_message()));
                                                    });

            m_registeredEvents.append(event);
            Q_EMIT registeredEventsChanged();
            return true;
        }
        return false;
    }

    Q_INVOKABLE void removeEvents(QStringList l){
        for(int i = l.size() -1; i >=0; --i){
            removeEvent(l[i]);
        }
    }
    Q_INVOKABLE bool removeEvent(QString event){
        for(int i = m_registeredEvents.size() -1; i >=0; --i){
            QString thisItem = m_registeredEvents[i];
            if(thisItem == event){

                client.socket()->off(event.toStdString());

                m_registeredEvents.removeAt(i);
                Q_EMIT registeredEventsChanged();
                return true;
            }
        }
        return false;
    }

    //SIALS RELATED
    Q_INVOKABLE void sailsGet   (QString url, QJSValue params = QJSValue::NullValue, QJSValue cb = QJSValue::NullValue, QJSValue headers = QJSValue::NullValue){
        sailsReq("get",url,params,headers,cb);
    }
    Q_INVOKABLE void sailsPut   (QString url, QJSValue params = QJSValue::NullValue, QJSValue cb = QJSValue::NullValue, QJSValue headers = QJSValue::NullValue){
        sailsReq("put",url,params,headers,cb);
    }
    Q_INVOKABLE void sailsPost  (QString url, QJSValue params = QJSValue::NullValue, QJSValue cb = QJSValue::NullValue, QJSValue headers = QJSValue::NullValue){
        sailsReq("post",url,params,headers,cb);
    }
    Q_INVOKABLE void sailsDelete(QString url, QJSValue params = QJSValue::NullValue, QJSValue cb = QJSValue::NullValue, QJSValue headers = QJSValue::NullValue){
        sailsReq("delete",url,params,headers,cb);
    }


    uint attemptedReconnects() {  return m_attemptedReconnects;    }
    bool reconnecting()        {  return m_reconnecting;           }

    int reconnectLimit() { return m_reconnectLimit; }
    void setReconnectLimit(int value) {
         if(value != m_reconnectLimit) {
             client.set_reconnect_attempts(value);
             Q_EMIT reconnectLimitChanged(value);
         }
    }

Q_SIGNALS:
    void sessionIdChanged();
    void isConnectedChanged(QString details);
    void failed();
    void serverResponse(QString eventName, QVariant value);
    void registeredEventsChanged();
    void attemptedReconnectsChanged(uint value);
    void reconnectingChanged(bool value);
    void reconnectLimitChanged(int value);
    void binaryServerResponse(QByteArray valueAsArray, QString valueAsString);
    void info(QString message);
    void error(QString message);
    void warning(QString message);

public Q_SLOTS:
    void timerTick() {  //The timer is thread safe. It will run on the UI thread. This is the only reason it exists!
        if(!cbListLocked){
            while(!cbList.isEmpty()) {
                cbList[0].call();
                QQmlEngine::setObjectOwnership(cbList[0].function.toQObject(), QQmlEngine::JavaScriptOwnership);
                cbList.pop_front();
            }
        }
    }


private:
    QStringList       m_registeredEvents;
    bool              m_connected;
    QString           m_sessionId;
    sio::client       client;
    QList<dataHolder> cbList;
    bool              cbListLocked;
    QTimer            *timer;

    int               m_reconnectLimit;
    unsigned int      m_attemptedReconnects;
    bool              m_reconnecting;


    void setAttemptedReconnects(uint value){
        if(value != m_attemptedReconnects){
            m_attemptedReconnects = value;
            Q_EMIT attemptedReconnectsChanged(value);
        }
    }
    void setReconnecting(bool value) {
        if(value != m_reconnecting){
            m_reconnecting = value;
            Q_EMIT reconnectingChanged(value);
        }
    }

    void init(){
        m_reconnectLimit = 0xFFFFFFFF;
        m_attemptedReconnects = 0;
        m_reconnecting = m_connected = false;
        m_sessionId = "";
        m_registeredEvents.clear();

        cbListLocked = false;
        cbList.clear();

//        client.set_reconnect_delay(2000);
//        client.set_reconnect_delay_max(4000);

        setDefaultListeners();


        timer = new QTimer(this);
        QObject::connect(timer, SIGNAL(timeout()) , this, SLOT(timerTick()));
        timer->start(10);
    }

    void setDefaultListeners(){
    //        The std::placeholders namespace contains the placeholder objects [_1, . . . _N] where N is an
    //        implementation defined maximum number.
    //        When used as an argument in a std::bind expression, the placeholder objects
    //        are stored in the generated function object, and when that function object
    //        is invoked with unbound arguments, each placeholder _N is replaced by
    //        the corresponding Nth unbound argument.
            //client.set_reconnecting_listener();
            //client.set_reconnect_listener();
            client.set_socket_open_listener(std::bind(&qmlSocketIOClient::onConnected,this,_1));
            client.set_close_listener      (std::bind(&qmlSocketIOClient::onClosed   ,this,_1));
            client.set_fail_listener       (std::bind(&qmlSocketIOClient::onFailed   ,this));


            client.set_reconnecting_listener(std::bind(&qmlSocketIOClient::onReconnecting, this));
            client.set_reconnect_listener(std::bind(&qmlSocketIOClient::onReconnect, this, _1, _2));

    }



    Q_INVOKABLE void sailsReq(QString method, QString url, QJSValue params, QJSValue headers, QJSValue cb = QJSValue::NullValue, bool isBinary = false){
        if(m_connected){
            sio::message::ptr om = sio::object_message::create();
            auto &map = om->get_map();

            QQmlEngine::setObjectOwnership(params.toQObject(), QQmlEngine::CppOwnership);
            QQmlEngine::setObjectOwnership(headers.toQObject(), QQmlEngine::CppOwnership);
            QQmlEngine::setObjectOwnership(cb.toQObject(), QQmlEngine::CppOwnership);


            std::pair<std::string,sio::message::ptr> _url   ("url"      , sio::string_message::create(url.toStdString())     );
            std::pair<std::string,sio::message::ptr> _params("params"  , transformJSValue(params , isBinary));
            std::pair<std::string,sio::message::ptr> _headers("headers", transformJSValue(headers, isBinary));

            QQmlEngine::setObjectOwnership(params.toQObject(), QQmlEngine::JavaScriptOwnership);
            QQmlEngine::setObjectOwnership(headers.toQObject(), QQmlEngine::JavaScriptOwnership);


            map.insert(_url);
            map.insert(_params);
            map.insert(_headers);

            //create callback
            std::function<void (sio::message::list const&)> const& func  =
                    [=](const sio::message::list &list) mutable->void {
                        if(cb.isCallable()){
//                            qDebug() << "is callable";
                            QJSValueList args;
                            for(uint i = 0; i < list.size(); i++){
                                QJSValue v = transformMessageToJs(list[i]);
                                args.push_back(v);
                            }
//                            cb.call(args);

                            dataHolder d;
                            d.function = cb;
                            d.params   = args;
                            cbListLocked = true;        //for safety! though we append at the end!
                            cbList.push_back(d);
                            cbListLocked = false;
//                            Q_EMIT jsCb(cb,args);
                        }
                        else {
                            Q_EMIT this->warning("cb provided for " + url + " is not callable");
                        }


                        QStringList arr   = method.split("/");
                        QString eventName = "";
                        if(!arr.empty()){
                            if(arr[0] != "")
                                eventName = arr[0];
                            else if(arr.length() > 1)
                                eventName = arr[1];
                        }

                        sailsResponse(eventName, list);
                    };

            //send it out and pass in the func cb
            client.socket()->emit(method.toStdString(), om, func);
        }
        else {
            Q_EMIT warning(QString(BOOST_CURRENT_FUNCTION) + " : socket is not connected " + url);
        }
    }


    sio::message::ptr transformJSValue(QJSValue js, bool isBinary = false){ //turns any jsValue into a message::ptr object that we can send!
        if(js.isUndefined() || js.isNull()){
            return sio::null_message::create();
        }
        else if(isBinary) {
            QJsonDocument json = QJsonDocument::fromVariant(js.toVariant());
            const std::string s = json.toJson().toStdString();
            auto ptr = std::make_shared<const std::string>(s);
            return sio::binary_message::create(ptr);
        }
        else if(js.isArray()){
//            qDebug() << "oh mario it's an array";
            sio::message::ptr m = sio::array_message::create();
            auto &vec           = m->get_vector();
            QJSValueIterator it(js);
            while(it.hasNext()){
                it.next();

                std::string key = it.name().toStdString();
                QJSValue val    = it.value();

                if(key != "length"){
                    int idx = std::atoi(key.c_str());    //get int from the std::string
                    vec.insert(vec.begin() + idx,transformJSValue(val));
                }
            }

            return m;
        }
        else if(js.isObject()){
            sio::message::ptr m = sio::object_message::create();
            auto &map           = m->get_map();

            QJSValueIterator it(js);
            while(it.hasNext()){
                it.next();

                try {
                    std::string key = it.name().toStdString();
                    QJSValue val    = it.value();
                    std::pair<std::string, sio::message::ptr> pair(key, transformJSValue(val));
                    map.insert(pair);

                } catch(std::exception &e) {
                    qDebug() << "qmlSocketIOClient.h::transformJsValue EXCEPTION::"  << QString(e.what());
                    Q_EMIT error(QString(e.what())) ;
                }


            }

            return m;
        }
        else if(js.isString()){
//            qDebug() << BOOST_CURRENT_FUNCTION <<" is string";
            return sio::string_message::create(js.toString().toStdString());
        }
        else if(js.isNumber()){
            double d = js.toNumber();
            double dummy = 0;
            if(std::modf(d,&dummy) == 0.0){ //is int
                return sio::int_message::create((int)d);
            }
            return sio::double_message::create(js.toNumber());
        }
        else if(js.isDate()){
            return sio::string_message::create(js.toString().toStdString());
        }
        else if(js.isBool()){
            return sio::bool_message::create(js.toBool());
        }

        return sio::null_message::create();
    }
    QVariant transformMessage(const sio::message::ptr &msg, uint depth = 0){    //turns any message::ptr object into something QML can read!
        auto flag = msg->get_flag();
        switch(flag){
            case sio::message::flag_array : {
                QJsonArray arr;
                auto &ref = msg->get_vector();
                for(uint i = 0; i < ref.size(); ++i){
                    addTo(arr,transformMessage(ref[i], depth + 1));
                }
                return arr;
            }
            case sio::message::flag_binary : {
                //TODO
                std::shared_ptr<const std::string> bin = msg->get_binary();
                Q_EMIT binaryServerResponse(QByteArray(bin->c_str(), bin->length()),   QString::fromStdString(*bin));
//                QFile outFile("temp.jpg");
//                outFile.open(QFile::WriteOnly | QFile::Truncate);
//                outFile.write(bin->c_str(), bin->length());
//                outFile.close();
                break;
            }
            case sio::message::flag_boolean : {
                return msg->get_bool();
            }
            case sio::message::flag_double : {
                return msg->get_double();
            }
            case sio::message::flag_integer : {
                return msg->get_int();
            }
            case sio::message::flag_string : {
                return QString::fromStdString(msg->get_string());
            }
            case sio::message::flag_null : {
                return QVariant(QJSValue::NullValue);
            }
            case sio::message::flag_object: {
                auto &map = msg->get_map();
                QJsonObject jsObject;

                for(std::map<std::string, sio::message::ptr>::iterator it = map.begin(); it!=map.end(); ++it){
                    QString       key       = QString::fromStdString(it->first);
                    sio::message::ptr value = it->second;

                    addTo(jsObject,key, transformMessage(value, depth + 1));
//                    if(depth == 0){
//                        if(key == "body"){
//                            return transformMessage(value,depth + 1);
//                        }
//                    }
//                    else {
//                        addTo(jsObject,key, transformMessage(value, depth + 1));
//                    }
                }
                return jsObject;
            }
        }
//        qDebug() << "returning blank";
        return QVariant();
    }
    QJSValue transformMessageToJs(const sio::message::ptr &msg, uint depth = 0){
        auto flag = msg->get_flag();
        switch(flag){
            case sio::message::flag_array : {
                QJsonArray arr;
                auto &ref = msg->get_vector();
                for(uint i = 0; i < ref.size(); ++i){
                    addTo(arr,transformMessage(ref[i], depth + 1));
                }
                QJsonDocument doc(arr);
                return QString(doc.toJson());
            }
            case sio::message::flag_binary : {  //this is for callbacks!
                std::shared_ptr<const std::string> bin = msg->get_binary();
                return QString::fromStdString(*bin);
            }
            case sio::message::flag_boolean : {
                return msg->get_bool();
            }
            case sio::message::flag_double : {
                return msg->get_double();
            }
            case sio::message::flag_integer : {
                return (int)msg->get_int();
            }
            case sio::message::flag_string : {
                return QString::fromStdString(msg->get_string());
            }
            case sio::message::flag_null : {
                return QJSValue::NullValue;
            }
            case sio::message::flag_object: {
                auto &map = msg->get_map();
                QJsonObject jsObject;

                for(std::map<std::string, sio::message::ptr>::iterator it = map.begin(); it!=map.end(); ++it){
                    QString       key       = QString::fromStdString(it->first);
                    sio::message::ptr value = it->second;
                    addTo(jsObject,key, transformMessage(value, depth + 1));
//                    if(depth == 0){
//                        if(key == "body"){
//                            return transformMessageToJs(value,depth + 1);
//                        }
//                    }
//                    else {
//                        addTo(jsObject,key, transformMessage(value, depth + 1));
//                    }
                }
                return QString(QJsonDocument(jsObject).toJson());
            }
        }
        return QJSValue::NullValue;
    }


    //functions to keep stuff in sync
    void sync_isConnected(bool isConnected, QString r){
        if(m_connected != isConnected){
            m_connected = isConnected;
            Q_EMIT isConnectedChanged(r);
        }
    }
    void sync_sessionId(){
        QString sid = QString::fromStdString(client.get_sessionid());
        if(sid != m_sessionId){
            m_sessionId = sid;
            Q_EMIT sessionIdChanged();
        }
    }

    void onConnected(std::string const &nsp){
        setAttemptedReconnects(0);
        setReconnecting(false);

        sync_isConnected(true,QString::fromStdString(nsp));
        sync_sessionId();
    }
    void onClosed(sio::client::close_reason const & reason){
        setReconnecting(false);

        QString r = reason == sio::client::close_reason_drop ? "dropped" : "normally";
        sync_isConnected(false,r);
        sync_sessionId();
    }
    void onReconnecting(){
        qDebug() << "qmlSOcketIOClient.h::onReconecting()" ;
    }
    void onReconnect(unsigned int attempt, unsigned int timeMs){
//        qDebug() << "qmlSOcketIOClient.h::onReconnect(" << a << "," << b <<  ")";
        setAttemptedReconnects(attempt);
        setReconnecting(true);
    }

    void onFailed(){
        setReconnecting(false);
        setAttemptedReconnects(0);
        sync_sessionId();

        Q_EMIT failed();
    }
    void sailsResponse(QString eventName, sio::message::list const &list){
//        qDebug() << "server replied with" << list.size() << "elements";
        QVariantList var;
        for(uint i = 0; i < list.size(); i++){
             //we have to figure out what it is that the server is trying to send, up in here!
             var.push_back(transformMessage(list[i]));
        }
        Q_EMIT serverResponse(eventName, var);
    }

    void addTo(QJsonArray &array, QVariant v){
        if(v.userType() == QMetaType::QJsonObject){
            array.push_back(v.toJsonObject());
        }
        else if(v.userType() == QMetaType::QJsonArray){
            array.push_back(v.toJsonArray());
        }
        else if(v.userType() == QMetaType::QString){
            array.push_back(v.toString());
        }
        else if(v.userType() == QMetaType::Int) {
            array.push_back(v.toInt());
        }
        else if(v.userType() == QMetaType::Double){
            array.push_back(v.toDouble());
        }
        else if(v.userType() == QMetaType::Bool){
            array.push_back(v.toBool());
        }
        else {
            array.push_back(v.toString());
        }
    }
    void addTo(QJsonObject &jsObject, QString key, QVariant v){
        if(v.userType() == QMetaType::QJsonObject){
            jsObject.insert(key,v.toJsonObject());
        }
        else if(v.userType() == QMetaType::QJsonArray){
            jsObject.insert(key,v.toJsonArray());
        }
        else if(v.userType() == QMetaType::QString){
            jsObject.insert(key,v.toString());
        }
        else if(v.userType() == QMetaType::Int) {
            jsObject.insert(key,v.toInt());
        }
        else if(v.userType() == QMetaType::Double){
            jsObject.insert(key,v.toDouble());
        }
        else if(v.userType() == QMetaType::Bool){
            jsObject.insert(key,v.toBool());
        }
        else {
            jsObject.insert(key,v.toString());
        }
    }

};


#endif // QMLSOCKETIO_H
