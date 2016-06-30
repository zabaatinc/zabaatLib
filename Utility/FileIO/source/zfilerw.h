#ifndef ZFILERW_H
#define ZFILERW_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QFileInfo>
#include <QTextStream>
#include <QDebug>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>
#include <QDirIterator>
#include <memory>   //to get shared_ptr

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
    Q_INVOKABLE QString readFileAsB64(QString fileName) {
        if(fileName.contains("qrc:///"))
            fileName = fileName.replace("qrc:///", ":");

        QFile file(fileName);
        file.open(QIODevice::ReadOnly);
        QByteArray image = file.readAll();

        return QString(image.toBase64());
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

    Q_INVOKABLE QStringList filesInFolder(QString folder, QStringList filters = QStringList() << "*.*", bool recursive = false){
        if(folder.contains("qrc:///"))
            folder = folder.replace("qrc:///", ":");

        QStringList files;

        std::shared_ptr<QDirIterator> it; //EMPTY

        if(recursive) {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, filters, QDir::Files, QDirIterator::Subdirectories  ));
        }
        else {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, filters, QDir::Files));
        }

        while(it->hasNext()){
            files.push_back(it->next());
        }

        return files;
    }
    Q_INVOKABLE QStringList foldersInFolder(QString folder, bool recursive = false){
        if(folder.contains("qrc:///"))
            folder = folder.replace("qrc:///", ":");

        QStringList folders;

        std::shared_ptr<QDirIterator> it; //EMPTY

        if(recursive) {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoDot, QDirIterator::Subdirectories  ));
        }
        else {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoDot));
        }

        while(it->hasNext()){
            folders.push_back(it->next());
        }

        return folders;
    }
    Q_INVOKABLE QString filesInFolderInfo(QString folder, QStringList filters = QStringList() << "*.*", bool recursive = false){
        if(folder.contains("qrc:///"))
            folder = folder.replace("qrc:///", ":");

        QJsonArray arr;

        std::shared_ptr<QDirIterator> it; //EMPTY

        if(recursive) {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, filters, QDir::Files, QDirIterator::Subdirectories  ));
        }
        else {
            it =  std::shared_ptr<QDirIterator>(new QDirIterator(folder, filters, QDir::Files));
        }

        while(it->hasNext()){
            it->next();
            QFileInfo f = it->fileInfo();

            //construct object
            QJsonObject o;
            addTo(o, "absoluteDir"         , f.absoluteDir().path()      );
            addTo(o, "absoluteFilePath"    , f.absoluteFilePath() );
            addTo(o, "absolutePath"        , f.absolutePath()     );
            addTo(o, "baseName"            , f.baseName()         );
            addTo(o, "bundleName"          , f.bundleName()       );
            addTo(o, "caching"             , f.caching()          );
            addTo(o, "canonicalFilePath"   , f.canonicalFilePath());
            addTo(o, "canonicalPath"       , f.canonicalPath()    );
            addTo(o, "completeBaseName"    , f.completeBaseName() );
            addTo(o, "completeSuffix"      , f.completeSuffix()   );
            addTo(o, "created"             , f.created()         );
            addTo(o, "dir"                 , f.dir().path()              );
            addTo(o, "exists"              , f.exists()           );
            addTo(o, "fileName"            , f.fileName()         );
            addTo(o, "filePath"            , f.filePath()         );
            addTo(o, "group"               , f.group()            );
            addTo(o, "groupId"             , f.groupId()          );
            addTo(o, "isAbsolute"          , f.isAbsolute()       );
            addTo(o, "isBundle"            , f.isBundle()         );
            addTo(o, "isDir"               , f.isDir()            );
            addTo(o, "isExecutable"        , f.isExecutable()     );
            addTo(o, "isFile"              , f.isFile()           );
            addTo(o, "isHidden"            , f.isHidden()         );
            addTo(o, "isNativePath"        , f.isNativePath()     );
            addTo(o, "isReadable"          , f.isReadable()       );
            addTo(o, "isRelative"          , f.isRelative()       );
            addTo(o, "isRoot"              , f.isRoot()           );
            addTo(o, "isSymLink"           , f.isSymLink()        );
            addTo(o, "isWritable"          , f.isWritable()       );
            addTo(o, "lastModified"        , f.lastModified()     );
            addTo(o, "lastRead"            , f.lastRead()         );
            addTo(o, "owner"               , f.owner()            );
            addTo(o, "ownerId"             , f.ownerId()          );
            addTo(o, "path"                , f.path()             );
            addTo(o, "size"                , f.size()             );
            addTo(o, "suffix"              , f.suffix()           );
            addTo(o, "symLinkTarget"       , f.symLinkTarget()    );

            //add object to array
            addTo(arr,o);
        }

        QJsonDocument doc(arr);
        return QString(doc.toJson());
    }

    Q_INVOKABLE bool deleteFile(QString path){
        if(path.contains("qrc:///"))
            path = path.replace("qrc:///", ":");

        QStringList arr = path.split(QDir::separator());
        if(arr.length() > 0){
            QString fileName = arr[arr.length() - 1];

            arr.removeLast();
            QString p = "";
            foreach(QString s, arr){
                p += s + "/";
            }

            QDir dir(p);
            return dir.remove(fileName);
        }

        return false;
    }
    Q_INVOKABLE int deleteAllFilesInFolder(QString path,  QStringList filters = QStringList() << "*.*"){
        if(path.contains("qrc:///"))
            path = path.replace("qrc:///", ":");

        QDir dir(path);
        dir.setNameFilters(filters);
        dir.setFilter(QDir::Files);

        int removeCount = 0;

        foreach(QString dirFile, dir.entryList()) {
            if(dir.remove(dirFile))
                removeCount++;
        }

        return removeCount;
    }
    Q_INVOKABLE bool deleteDirectory(QString path){
        if(path.contains("qrc:///"))
            path = path.replace("qrc:///", ":");

        QDir dir(path);
        return dir.removeRecursively();
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

#endif // ZFILEIO_H
