#ifndef ZPRINTER_H
#define ZPRINTER_H

#include <QObject>
#include <QPrinter>
#include <QPrinterInfo>
#include <QPageSize>
#include <QStringList>
#include <QDebug>
#include <QTextDocument>
#include <QDialog>

class zprinter : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString          activePrinter           READ activePrinter           WRITE setActivePrinter NOTIFY activePrinterChanged)

    Q_PROPERTY(QString          description             READ description             NOTIFY descriptionChanged)
    Q_PROPERTY(QString          makeAndModel            READ makeAndModel            NOTIFY makeAndModelChanged)
    Q_PROPERTY(QString          defaultDuplexMode       READ defaultDuplexMode       NOTIFY defaultDuplexModeChanged)
    Q_PROPERTY(QPageSize        defaultPageSize         READ defaultPageSize         NOTIFY defaultPageSizeChanged)
    Q_PROPERTY(bool             isDefault               READ isDefault               NOTIFY isDefaultChanged)
    Q_PROPERTY(bool             isNull                  READ isNull                  NOTIFY isNullChanged)
    Q_PROPERTY(bool             isRemote                READ isRemote                NOTIFY isRemoteChanged)
    Q_PROPERTY(QString          location                READ location                NOTIFY locationChanged)
    Q_PROPERTY(QPageSize        maximumPageSize         READ maximumPageSize         NOTIFY maximumPageSizeChanged)
    Q_PROPERTY(QPageSize        minimumPageSize         READ minimumPageSize         NOTIFY minimumPageSizeChanged)
    Q_PROPERTY(QString          state                   READ state                   NOTIFY stateChanged)
    Q_PROPERTY(QStringList      supportedDuplexModes    READ supportedDuplexModes    NOTIFY supportedDuplexModesChanged)
    Q_PROPERTY(QList<QPageSize> supportedPageSizes      READ supportedPageSizes      NOTIFY supportedPageSizesChanged)
    Q_PROPERTY(QList<int>       supportedResolutions    READ supportedResolutions    NOTIFY supportedResolutionsChanged)
    Q_PROPERTY(bool             supportsCustomPageSizes READ supportsCustomPageSizes NOTIFY supportsCustomPageSizesChanged)


public:
    zprinter(QObject * parent = 0) : QObject(parent){
        //qRegisterMetaType(QPageSize);
        pi = QPrinterInfo::defaultPrinter();
        emitAll();
    }
    ~zprinter(){}

    Q_INVOKABLE print(QString text){
        if(!isNull()){
            QTextDocument doc;
            doc.setHtml(text);

            QPrinter printer;
            printer.setPrinterName(activePrinter());

            doc.print(&printer);
        }
        else
            qDebug() << "C++::zprinter.h::printselected printer is Null:" << activePrinter();
    }

    Q_INVOKABLE QStringList availablePrinters(){
        return QPrinterInfo::availablePrinterNames();
    }


    void             setActivePrinter(QString name){
        if(activePrinter() != name){
            pi = QPrinterInfo::printerInfo(name);
            emitAll();
        }
    }
    QString          activePrinter           (){ return pi.printerName() ; }
    QString          makeAndModel            (){ return pi.makeAndModel() ; }
    QString          description             (){ return pi.description() ;  }
    QPageSize        defaultPageSize         (){ return pi.defaultPageSize() ; }
    bool             isDefault               (){ return pi.isDefault() ; }
    bool             isNull                  (){ return pi.isNull() ; }
    bool             isRemote                (){ return pi.isRemote() ; }
    QString          location                (){ return pi.location() ; }
    QPageSize        maximumPageSize         (){ return pi.maximumPhysicalPageSize() ; }
    QPageSize        minimumPageSize         (){ return pi.minimumPhysicalPageSize() ; }
    QList<QPageSize> supportedPageSizes      (){ return pi.supportedPageSizes() ; }
    QList<int>       supportedResolutions    (){ return pi.supportedResolutions() ; }
    bool             supportsCustomPageSizes (){ return pi.supportsCustomPageSizes() ; }
    QString          defaultDuplexMode       (){
        int d = pi.defaultDuplexMode();
        if(d == QPrinter::DuplexAuto)      return "DuplexAuto";
        if(d == QPrinter::DuplexLongSide)  return "DuplexLongSide";
        if(d == QPrinter::DuplexShortSide) return "DuplexShortSide";
        return "DuplexNone";
    }
    QString          state                   (){
        int s = pi.state();
        if(s == QPrinter::Active)   return "Active";
        if(s == QPrinter::Aborted)  return "Aborted";
        if(s == QPrinter::Error)    return "Error";
        return "Idle";
    }
    QStringList      supportedDuplexModes    (){
        QStringList li;
        QList<QPrinter::DuplexMode> ld = pi.supportedDuplexModes();
        for(int i = 0; i < ld.length(); ++i){
            int s = ld[i];

            if     (s == QPrinter::Active)   li.push_back("Active") ;
            else if(s == QPrinter::Aborted)  li.push_back("Aborted");
            else if(s == QPrinter::Error)    li.push_back("Error")  ;
            else                             li.push_back("Idle")   ;
        }

        return li;
    }





signals:
    void activePrinterChanged();
    void descriptionChanged();
    void makeAndModelChanged();
    void defaultDuplexModeChanged();
    void defaultPageSizeChanged();
    void isDefaultChanged();
    void isNullChanged();
    void isRemoteChanged();
    void locationChanged();
    void maximumPageSizeChanged();
    void minimumPageSizeChanged();
    void stateChanged();
    void supportedDuplexModesChanged();
    void supportedPageSizesChanged();
    void supportedResolutionsChanged();
    void supportsCustomPageSizesChanged();

public slots:

private:
    QPrinterInfo pi;

    void emitAll(){
        Q_EMIT activePrinterChanged();
        Q_EMIT makeAndModelChanged();
        Q_EMIT descriptionChanged();
        Q_EMIT defaultDuplexModeChanged();
        Q_EMIT defaultPageSizeChanged();
        Q_EMIT isDefaultChanged();
        Q_EMIT isNullChanged();
        Q_EMIT isRemoteChanged();
        Q_EMIT locationChanged();
        Q_EMIT maximumPageSizeChanged();
        Q_EMIT minimumPageSizeChanged();
        Q_EMIT stateChanged();
        Q_EMIT supportedDuplexModesChanged();
        Q_EMIT supportedPageSizesChanged();
        Q_EMIT supportedResolutionsChanged();
        Q_EMIT supportsCustomPageSizesChanged();
    }



};

#endif // ZPRINTER_H
