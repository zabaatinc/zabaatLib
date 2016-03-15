#ifndef ZFILERW_H
#define ZFILERW_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QFileInfo>
#include <QTextStream>
#include <QDebug>

class ZFileRW : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ZFileRW)

public:
    ZFileRW(QObject *parent = 0) : QObject(parent) {}
    ~ZFileRW(){}

    Q_INVOKABLE QString readFile(QString fileName) {
        if(fileName.contains("qrc:///"))
            fileName = fileName.replace("qrc:///", ":");

        QString content = "";
        QFile file(fileName);
        if (file.open(QIODevice::ReadOnly)) {
            QTextStream stream(&file);
            content = stream.readAll();
        }
        else {
            qDebug() << "C++ zfileio::readFile - unable to open file : " << fileName;
        }
        return content;
    }
    Q_INVOKABLE bool createDirIfDoesNotExist(QString dir){
        if(!QDir(dir).exists()){
            return QDir().mkdir(dir);
        }
        return true;
    }
    Q_INVOKABLE bool writeFile(QString folder, QString file, QString text, QString user = "", QString pw = "") {

        createDirIfDoesNotExist(folder);
        QUrl url(folder + "/" + file);

        if(user != "" && pw != "") {
            url.setUserName(user);
            url.setPassword(pw);
        }


        QFile f(url.toString());
        if(f.open(QFile::WriteOnly)){
            f.write(text.toStdString().c_str(), text.length());
            f.close();
            return true;
        }
        else {
            return false;
        }
    }
};

#endif // ZFILEIO_H
