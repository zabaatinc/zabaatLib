#ifndef PROGRESS
#define PROGRESS

#include <QObject>
#include <QUrl>
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <iostream>

class progress : public QObject
{
    Q_OBJECT
    public:
        QUrl        url;
        qint64      received;
        qint64      total;
        QDateTime   startTime;
        QFile       *filePtr;
        QString     savePath;


        ~progress()
        {
            if(filePtr != NULL && filePtr->isOpen())
                filePtr->close();

            delete filePtr;
        }

        progress(QUrl Url = QUrl(), QString saveTo = "", qint64 receivedBytes = 0, qint64 totalBytes = 0, QDateTime StartTime = QDateTime::currentDateTime()) : QObject(),
                                                                                                                                               url(Url),
                                                                                                                                               savePath(saveTo),
                                                                                                                                               received(receivedBytes),
                                                                                                                                               total(totalBytes),
                                                                                                                                               startTime(StartTime),
                                                                                                                                               filePtr(NULL) {}

        progress(const progress &rhs) : QObject(), url(rhs.url), savePath(rhs.savePath), received(rhs.received), total(rhs.total), startTime(rhs.startTime), filePtr(NULL) {}
        progress& operator=(const progress &rhs)
        {
            url = rhs.url;
            savePath = rhs.savePath;
            received = rhs.received;
            total = rhs.total;
            startTime = rhs.startTime;
            filePtr = NULL;

            return *this;
        }

        bool openFile(QString name = "")
        {
            if(name == "")
                name = savePath != "" ?  savePath : QFileInfo(url.path()).fileName();

            if(name.indexOf("file:///") != -1){
               name = name.replace ("file:///", "");
            }

            if(name.indexOf("qrc:///") != -1){
                name = name.replace ("qrc:///", "");
            }


//            std::cout << "opened file " << name.toStdString ().c_str () << " for writing" << std::endl;

            filePtr = new QFile(name);

            return filePtr->open(QFile::WriteOnly | QFile::Truncate);
        }



        bool closeFile()
        {
            if(filePtr != NULL && filePtr->isOpen())
            {
                filePtr->close();
                return true;
            }
            return false;
        }




    signals:
        void progressChanged(QUrl url, qint64 received, qint64 total, qint64 elapsed, QString speed);


    public slots:
        void change(qint64 r, qint64 t)
        {
            double elapsed =  startTime.time().msecsTo(QDateTime::currentDateTime().time());
            if(elapsed <= 0)
                elapsed = 1;
            else
                elapsed /= 1000;    //convert mSec to sec

            //qint64 elapsed = (QDateTime::currentDateTime() - startTime)/1000;
            received = r;
            total = total;

            double speed = r  / elapsed;
            QString unit;
            if (speed < 1024) {
                unit = "bytes/sec";
            } else if (speed < 1024*1024) {
                speed /= 1024;
                unit = "kB/s";
            } else {
                speed /= 1024*1024;
                unit = "MB/s";
            }

            unit = QString::number(speed,'f',1) + " " + unit;
            emit progressChanged(url, r, t, elapsed, unit);
        }

        bool writeToFile(const QByteArray &array)
        {
            if(filePtr == NULL || !filePtr->isOpen())
                openFile();

            if(filePtr != NULL && filePtr->isOpen())
            {
                filePtr->write(array);
                return true;
            }
            return false;
        }




};

#endif // PROGRESS

