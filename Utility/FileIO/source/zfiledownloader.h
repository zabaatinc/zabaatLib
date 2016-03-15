#ifndef FILEDOWNLOADER
#define FILEDOWNLOADER

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSslError>
#include <QStringList>
#include <QUrl>
#include <QHash>
#include <QDateTime>
#include "progress.h"
#include <QProcess>
#include <iostream>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QObject>

class fileDownloader: public QObject
{
    Q_OBJECT
    QNetworkAccessManager   manager;
    QList<QNetworkReply*>   activeDownloads;
    QHash<QUrl, progress>   timeList;

public:
    fileDownloader(QObject * parent =  0):QObject(parent)   //ctor
    {
        connect(&manager, SIGNAL(finished(QNetworkReply*)) , SLOT(downloadFinished(QNetworkReply*)));
    }
    ~fileDownloader(){

    }

    Q_INVOKABLE void download (const QUrl &url, QString path = "")
    {
        QNetworkRequest request(url);
        QNetworkReply  *reply = manager.get(request);
        timeList[url]         = progress(url, path);


        connect(reply         , &QNetworkReply::downloadProgress,
                &timeList[url], &progress::change);

        connect(&timeList[url], &progress::progressChanged,
                this          , &fileDownloader::downloadProgressChanged);

        //apparently this is a lambda expression, teehee
        connect(reply, &QNetworkReply::readyRead, [=]
                                                  {
                                                    if(!reply->error())
                                                    {
                                                        qint64 numBytes = reply->bytesAvailable();
                                                        QByteArray arr  = reply->read(numBytes);
                                                        timeList[url].writeToFile(arr);
                                                    }
                                                  });


        #ifndef QT_NO_SSL
            connect(reply, SIGNAL(sslErrors(QList<QSslError>)), SLOT(sslErrors(QList<QSslError>)));
        #endif

        activeDownloads.append(reply);
    }
    Q_INVOKABLE void download(const QStringList &list, QString path = "")
    {
        if(path.length() != 0 && (path[path.length () -1] != '/' || path[path.length () -1] != '\\') )
        {
            std::cout << path[path.length () - 1].toLatin1 ();
            path = path + "/";
        }

        for(int i = 0; i < list.count(); i++)
        {
            QUrl url(list[i]);
            download(url, path + QFileInfo(url.path()).fileName());
        }
    }
    Q_INVOKABLE void upload(QString fileName, const QString &url, QString key = "file"){
        QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

        if(fileName.indexOf("file:///") != -1)  fileName = fileName.replace ("file:///", "");
        if(fileName.indexOf("qrc:///") != -1)   fileName = fileName.replace ("qrc:///", "");


        QFile *file = new QFile(fileName);
        if(!file->exists() || !file->open (QIODevice::ReadOnly)){
            std::cout << "error opening file " << fileName.toStdString ().c_str ()<< std::endl;
            return;
        }

//        std::cout << "finished reading file" << std::endl;

        QString extension = "image/";   //TODO, make a map or something that determines whether to use image/jpeg or text/plain, etc etc
        QStringList arr;
        if(fileName.indexOf (".") != -1){
            arr = fileName.split (".");
            extension += arr[arr.length() -1];
        }
        else
            extension += "jpeg";

        //READ THE FILE INTO A BYTES ARRAY
        QByteArray lines;
        while(!file->atEnd ()){
            lines.append(file->readLine());
        }
        file->close();  //we don't need file anymore


//        saveFile (lines, fileName + "_tmp." + extension.replace("image/","")) ;


        arr = fileName.split (QDir::separator());
        QString _fileNameOnly = arr[arr.length () -1];
        key = "\"" +key + "\"";


        QHttpPart imagePart;
        imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=" + key + "; filename=" + "\"" + _fileNameOnly + "\"" ));  //ALL THESE ARE REQUIRED. HAHA EVEN FILENAME. DERP.
        imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(extension));
        imagePart.setBody(lines);


        multiPart->append(imagePart);

        QNetworkRequest request(url);
        QNetworkReply *reply = manager.post (request, multiPart);  //do post
        emit uploadStarted(fileName,url);

        //apparently this is a lambda expression, teehee
        connect(reply, &QNetworkReply::finished, [=]
                                                  {
                                                    if(!reply->error())
                                                    {
//                                                        std::cout << "great success " << QString( reply->readAll ()).toStdString ().c_str ()<< std::endl;
                                                        emit uploadFinished(fileName,url);
                                                    }
                                                    else {
                                                        std::cout << "ZFILEDOWNLADER : error happened: " << reply->errorString().toStdString().c_str() << std::endl;
                                                        emit uploadFailed(fileName,url);
                                                    }

                                                    reply->deleteLater();
                                                    multiPart->deleteLater();
                                                  });


        //CLEANUP
//        multiPart->deleteLater();   //we can delete this right after the post and close the file

    }

    void saveFile(QByteArray ba, QString fileName){
        QFile file(fileName);
        if(!file.fileName ().isEmpty ()){
            file.open(QFile::WriteOnly | QFile::Truncate);
            file.write (ba);
            file.close ();
        }
    }



//    Q_INVOKABLE void test(QUrl url){
//        QHttpMultiPart *multipart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

//        QHttpPart part;
//        part.setHeader (QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"bretters\""));
//        part.setBody ("or should I say butters");

//        multipart->append (part);

//        QNetworkRequest request(url);
//        QNetworkReply *reply = manager.post (request, multipart);
//        //apparently this is a lambda expression, teehee
//        connect(reply, &QNetworkReply::finished, [=]
//                                                  {
//                                                    if(!reply->error())
//                                                    {
//                                                        std::cout << "great success " << QString( reply->readAll ()).toStdString ().c_str ()<< std::endl;

//                                                    }
//                                                    else
//                                                        std::cout << "error happened: " << reply->errorString().toStdString().c_str() << std::endl;

////                                                    reply->deleteLater ();
//                                                  });
////        multipart->deleteLater ();
//    }


signals:
    void downloadFailed         (QUrl url, QString fileName);
    void downloadEnded          (QUrl url, QString fileName);
    void downloadSaved          (QUrl url, QString fileName);
    void downloadProgressChanged(QUrl url, qint64 bytesReceived, qint64 bytesTotal, qint64 elapsed, QString speed);
    void uploadStarted (QString file, QString url);
    void uploadFinished(QString file, QString url);
    void uploadFailed  (QString file, QString url);
    void allDownloadsFinished();
    void downloadPathChanged();

private slots:
    void sslErrors        (const QList<QSslError>  &sslErrors)
    {
        #ifndef QT_NO_SSL
            foreach (const QSslError &error, sslErrors)
                fprintf(stderr, "SSL error: %s\n", qPrintable(error.errorString()));
        #else
            Q_UNUSED(sslErrors);
        #endif
    }


public slots:
    void downloadFinished (QNetworkReply *reply) {
        QUrl url = reply->url();
        QString fileName = timeList[url].savePath == "" ? QFileInfo(url.path()).fileName() : timeList[url].savePath;
//        std::cout << fileName.toStdString ().c_str () << " finished";
        if (reply->error())
        {
            fprintf(stderr, "Download of %s failed: %s\n",  url.toEncoded().constData(), qPrintable(reply->errorString()));
            emit downloadFailed(url, fileName);
        }
        else
        {
            emit downloadEnded (url, fileName);

            if(timeList[url].closeFile())
                emit downloadSaved(url, fileName);

            timeList.remove(url);
        }

        activeDownloads.removeAll(reply);
        reply->deleteLater();

        if(activeDownloads.isEmpty())
            emit allDownloadsFinished();
    }



};



#endif // FILEDOWNLOADER

