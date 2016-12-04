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
#include <QPainter>
//#include <QStandardPaths>


class zprinter : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString          activePrinter           READ activePrinter           WRITE setActivePrinter NOTIFY activePrinterChanged)

    Q_PROPERTY(QString          description             READ description             NOTIFY descriptionChanged)
    Q_PROPERTY(QString          makeAndModel            READ makeAndModel            NOTIFY makeAndModelChanged)
    Q_PROPERTY(QString          defaultDuplexMode       READ defaultDuplexMode       NOTIFY defaultDuplexModeChanged)
    Q_PROPERTY(QString          defaultPageSize         READ defaultPageSize         NOTIFY defaultPageSizeChanged)
    Q_PROPERTY(bool             isDefault               READ isDefault               NOTIFY isDefaultChanged)
    Q_PROPERTY(bool             isNull                  READ isNull                  NOTIFY isNullChanged)
    Q_PROPERTY(bool             isRemote                READ isRemote                NOTIFY isRemoteChanged)
    Q_PROPERTY(QString          location                READ location                NOTIFY locationChanged)
    Q_PROPERTY(QString          maximumPageSize         READ maximumPageSize         NOTIFY maximumPageSizeChanged)
    Q_PROPERTY(QString          minimumPageSize         READ minimumPageSize         NOTIFY minimumPageSizeChanged)
    Q_PROPERTY(QString          state                   READ state                   NOTIFY stateChanged)
    Q_PROPERTY(QStringList      supportedDuplexModes    READ supportedDuplexModes    NOTIFY supportedDuplexModesChanged)
    Q_PROPERTY(QStringList      supportedPageSizes      READ supportedPageSizes      NOTIFY supportedPageSizesChanged)
    Q_PROPERTY(QList<int>       supportedResolutions    READ supportedResolutions    NOTIFY supportedResolutionsChanged)
    Q_PROPERTY(bool             supportsCustomPageSizes READ supportsCustomPageSizes NOTIFY supportsCustomPageSizesChanged)


public:
    zprinter(QObject * parent = 0) : QObject(parent){
        //qRegisterMetaType(QPageSize);
        pi = QPrinterInfo::defaultPrinter();
        emitAll();
    }
    ~zprinter(){}

    Q_INVOKABLE bool print(QString text, QString pageSize = ""){
        QPageSize p =  pageSize == "" ? pi.defaultPageSize() : stringToPageSize(pageSize);
        QSizeF size = p.size(QPageSize::Inch);
        return print(text, size.width(), size.height());
    }
    Q_INVOKABLE bool print(QString text, float inchesX, float inchesY){
        if(!isNull()){
            QSizeF size(inchesX,inchesY);

            QTextDocument doc;
            doc.setPageSize(size);  //default for QTextDocument
            doc.setHtml(text);

            QPrinter printer;
            printer.setPaperSize(size, QPrinter::Inch);
            printer.setPrinterName(activePrinter());

            doc.print(&printer);
            return true;
        }
        else {
            qDebug() << "C++::zprinter.h::printselected printer is Null:" << activePrinter();
            return false;
        }
    }



    Q_INVOKABLE bool printImage(QString filename, QString pageSize = "") {
        QPageSize p =  pageSize == "" ? pi.defaultPageSize() : stringToPageSize(pageSize);
        QSizeF size = p.size(QPageSize::Inch);
        return printImage(filename, size.width(), size.height());
    }
    Q_INVOKABLE bool printImage(QString filename, float inchesX, float inchesY) {
        if(isNull()) {
            qDebug() << "C++::zprinter.h::printselected printer is Null:" << activePrinter();
            return false;
        }

        filename = filename.replace("file:///","");
        filename = filename.replace("qrc:///",":/");

        QImage img;
        if(!img.load(filename)) {
            qDebug() << "C++::zprinter.h::Could not open file to print : " << filename;
            return false;
        }

        QPrinter printer;
        printer.setPaperSize(QSizeF(inchesX,inchesY), QPrinter::Inch);
        printer.setPrinterName(activePrinter());

        QPainter painter(&printer);
        painter.drawImage(QPoint(0,0), img);
        return painter.end();
    }

    Q_INVOKABLE bool printImageData(QString svgData, QString imageType_opt = "", QString pageSize = "") {
        QPageSize p =  pageSize == "" ? pi.defaultPageSize() : stringToPageSize(pageSize);
        QSizeF size = p.size(QPageSize::Inch);
        return printImageData(svgData, size.width(), size.height(), imageType_opt);
    }
    Q_INVOKABLE bool printImageData(QString svgData, float inchesX, float inchesY, QString imageType_opt = "") {
        if(isNull()){
            qDebug() << "C++::zprinter.h::printselected printer is Null:" << activePrinter();
            return false;
        }

        QByteArray ba = svgData.toUtf8();
        QImage img;
        if(imageType_opt != "") {
            if(!img.loadFromData(ba,imageType_opt.toStdString().c_str())) {
                qDebug() << "C++::zprinter.h::Could not load data as image";
                return false;
            }
        }
        else {
            if(!img.loadFromData(ba)) {
                qDebug() << "C++::zprinter.h::Could not load data as image";
                return false;
            }
        }


        if(inchesX == 0)
            inchesX = pi.defaultPageSize().size(QPageSize::Inch).width();
        if(inchesY == 0)
            inchesY = pi.defaultPageSize().size(QPageSize::Inch).height();


        QPrinter printer;
        printer.setPaperSize(QSizeF(inchesX,inchesY), QPrinter::Inch);
        printer.setPrinterName(activePrinter());

        QPainter painter(&printer);
        painter.drawImage(QPoint(0,0), img);
        return painter.end();
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
    QString          defaultPageSize         (){ return pageSizeToString(pi.defaultPageSize()) ; }
    bool             isDefault               (){ return pi.isDefault() ; }
    bool             isNull                  (){ return pi.isNull() ; }
    bool             isRemote                (){ return pi.isRemote() ; }
    QString          location                (){ return pi.location() ; }
    QString          maximumPageSize         (){ return pageSizeToString(pi.maximumPhysicalPageSize()) ; }
    QString          minimumPageSize         (){ return pageSizeToString(pi.minimumPhysicalPageSize()) ; }

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
    QStringList      supportedPageSizes      (){

        QStringList li;
        QList<QPageSize> ld = pi.supportedPageSizes() ; ;
        for(int i = 0; i < ld.length(); ++i){
            li.push_back(pageSizeToString(ld[i]));
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

    QPageSize stringToPageSize(QString s) {
        s = s.toLower();
        if(s == "a0")                     return QPageSize(QPageSize::A0               );
        if(s == "cicero")                 return QPageSize(QPageSize::A0               );
        if(s == "a1")                     return QPageSize(QPageSize::A1               );
        if(s == "a2")                     return QPageSize(QPageSize::A2               );
        if(s == "a3")                     return QPageSize(QPageSize::A3               );
        if(s == "a3extra")                return QPageSize(QPageSize::A3Extra          );
        if(s == "a4")                     return QPageSize(QPageSize::A4               );
        if(s == "a4extra")                return QPageSize(QPageSize::A4Extra          );
        if(s == "a4plus")                 return QPageSize(QPageSize::A4Plus           );
        if(s == "a4small")                return QPageSize(QPageSize::A4Small          );
        if(s == "a5")                     return QPageSize(QPageSize::A5               );
        if(s == "a5extra")                return QPageSize(QPageSize::A5Extra          );
        if(s == "a6")                     return QPageSize(QPageSize::A6               );
        if(s == "a7")                     return QPageSize(QPageSize::A7               );
        if(s == "a8")                     return QPageSize(QPageSize::A8               );
        if(s == "a9")                     return QPageSize(QPageSize::A9               );
        if(s == "ansia")                  return QPageSize(QPageSize::AnsiA            );
        if(s == "letter")                 return QPageSize(QPageSize::AnsiA            );
        if(s == "ansib")                  return QPageSize(QPageSize::AnsiB            );
        if(s == "ledger")                 return QPageSize(QPageSize::AnsiB            );
        if(s == "ansic")                  return QPageSize(QPageSize::AnsiC            );
        if(s == "ansid")                  return QPageSize(QPageSize::AnsiD            );
        if(s == "ansie")                  return QPageSize(QPageSize::AnsiE            );
        if(s == "archa")                  return QPageSize(QPageSize::ArchA            );
        if(s == "archb")                  return QPageSize(QPageSize::ArchB            );
        if(s == "archc")                  return QPageSize(QPageSize::ArchC            );
        if(s == "archd")                  return QPageSize(QPageSize::ArchD            );
        if(s == "arche")                  return QPageSize(QPageSize::ArchE            );
        if(s == "b0")                     return QPageSize(QPageSize::B0               );
        if(s == "b1")                     return QPageSize(QPageSize::B1               );
        if(s == "b2")                     return QPageSize(QPageSize::B2               );
        if(s == "b3")                     return QPageSize(QPageSize::B3               );
        if(s == "b4")                     return QPageSize(QPageSize::B4               );
        if(s == "b5")                     return QPageSize(QPageSize::B5               );
        if(s == "b5extra")                return QPageSize(QPageSize::B5Extra          );
        if(s == "b6")                     return QPageSize(QPageSize::B6               );
        if(s == "b7")                     return QPageSize(QPageSize::B7               );
        if(s == "b8")                     return QPageSize(QPageSize::B8               );
        if(s == "b9")                     return QPageSize(QPageSize::B9               );
        if(s == "b10")                    return QPageSize(QPageSize::B10              );
        if(s == "doublepostcard")         return QPageSize(QPageSize::DoublePostcard   );
        if(s == "envelope9")              return QPageSize(QPageSize::Envelope9        );
        if(s == "envelope10")             return QPageSize(QPageSize::Envelope10       );
        if(s == "comm10e")                return QPageSize(QPageSize::Comm10E          );
        if(s == "envelope11")             return QPageSize(QPageSize::Envelope11       );
        if(s == "envelope12")             return QPageSize(QPageSize::Envelope12       );
        if(s == "envelope14")             return QPageSize(QPageSize::Envelope14       );
        if(s == "envelopeb4")             return QPageSize(QPageSize::EnvelopeB4       );
        if(s == "envelopeb5")             return QPageSize(QPageSize::EnvelopeB5       );
        if(s == "envelopeb6")             return QPageSize(QPageSize::EnvelopeB6       );
        if(s == "envelopec0")             return QPageSize(QPageSize::EnvelopeC0       );
        if(s == "envelopec1")             return QPageSize(QPageSize::EnvelopeC1       );
        if(s == "envelopec2")             return QPageSize(QPageSize::EnvelopeC2       );
        if(s == "envelopec3")             return QPageSize(QPageSize::EnvelopeC3       );
        if(s == "envelopec4")             return QPageSize(QPageSize::EnvelopeC4       );
        if(s == "envelopec5")             return QPageSize(QPageSize::EnvelopeC5       );
        if(s == "c5e")                    return QPageSize(QPageSize::C5E              );
        if(s == "envelopec6")             return QPageSize(QPageSize::EnvelopeC6       );
        if(s == "envelopec7")             return QPageSize(QPageSize::EnvelopeC7       );
        if(s == "envelopec65")            return QPageSize(QPageSize::EnvelopeC65      );
        if(s == "envelopechou3")          return QPageSize(QPageSize::EnvelopeChou3     ) ;
        if(s == "envelopechou4")          return QPageSize(QPageSize::EnvelopeChou4     ) ;
        if(s == "envelopedl")             return QPageSize(QPageSize::EnvelopeDL        ) ;
        if(s == "dle")                    return QPageSize(QPageSize::DLE               ) ;
        if(s == "envelopeinvite")         return QPageSize(QPageSize::EnvelopeInvite    ) ;
        if(s == "envelopeitalian")        return QPageSize(QPageSize::EnvelopeItalian   ) ;
        if(s == "envelopekaku2")          return QPageSize(QPageSize::EnvelopeKaku2     ) ;
        if(s == "envelopekaku3")          return QPageSize(QPageSize::EnvelopeKaku3     ) ;
        if(s == "envelopemonarch")        return QPageSize(QPageSize::EnvelopeMonarch   ) ;
        if(s == "envelopepersonal")       return QPageSize(QPageSize::EnvelopePersonal  ) ;
        if(s == "envelopeprc1")           return QPageSize(QPageSize::EnvelopePrc1      ) ;
        if(s == "envelopeprc2")           return QPageSize(QPageSize::EnvelopePrc2      ) ;
        if(s == "envelopeprc3")           return QPageSize(QPageSize::EnvelopePrc3      ) ;
        if(s == "envelopeprc4")           return QPageSize(QPageSize::EnvelopePrc4      ) ;
        if(s == "envelopeprc5")           return QPageSize(QPageSize::EnvelopePrc5      ) ;
        if(s == "envelopeprc6")           return QPageSize(QPageSize::EnvelopePrc6      ) ;
        if(s == "envelopeprc7")           return QPageSize(QPageSize::EnvelopePrc7      ) ;
        if(s == "envelopeprc8")           return QPageSize(QPageSize::EnvelopePrc8      ) ;
        if(s == "envelopeprc9")           return QPageSize(QPageSize::EnvelopePrc9      ) ;
        if(s == "envelopeprc10")          return QPageSize(QPageSize::EnvelopePrc10     ) ;
        if(s == "envelopeyou4")           return QPageSize(QPageSize::EnvelopeYou4      ) ;
        if(s == "executive")              return QPageSize(QPageSize::Executive         ) ;
        if(s == "executivestandard")      return QPageSize(QPageSize::ExecutiveStandard ) ;
        if(s == "fanfoldgerman")          return QPageSize(QPageSize::FanFoldGerman     ) ;
        if(s == "fanfoldgermanlegal")     return QPageSize(QPageSize::FanFoldGermanLegal) ;
        if(s == "fanfoldus")              return QPageSize(QPageSize::FanFoldUS     )   ;
        if(s == "folio")                  return QPageSize(QPageSize::Folio         )   ;
        if(s == "imperial7x9")            return QPageSize(QPageSize::Imperial7x9   )   ;
        if(s == "imperial8x10")           return QPageSize(QPageSize::Imperial8x10  )   ;
        if(s == "imperial9x11")           return QPageSize(QPageSize::Imperial9x11  )   ;
        if(s == "imperial9x12")           return QPageSize(QPageSize::Imperial9x12  )   ;
        if(s == "imperial10x11")          return QPageSize(QPageSize::Imperial10x11 )   ;
        if(s == "imperial10x13")          return QPageSize(QPageSize::Imperial10x13 )   ;
        if(s == "imperial10x14")          return QPageSize(QPageSize::Imperial10x14 )   ;
        if(s == "imperial12x11")          return QPageSize(QPageSize::Imperial12x11 )   ;
        if(s == "imperial15x11")          return QPageSize(QPageSize::Imperial15x11 )   ;
        if(s == "jisb0")                  return QPageSize(QPageSize::JisB0         )   ;
        if(s == "jisb1")                  return QPageSize(QPageSize::JisB1         )   ;
        if(s == "jisb2")                  return QPageSize(QPageSize::JisB2         )   ;
        if(s == "jisb3")                  return QPageSize(QPageSize::JisB3         )   ;
        if(s == "jisb4")                  return QPageSize(QPageSize::JisB4         )   ;
        if(s == "jisb5")                  return QPageSize(QPageSize::JisB5         )   ;
        if(s == "jisb6")                  return QPageSize(QPageSize::JisB6         )   ;
        if(s == "jisb7")                  return QPageSize(QPageSize::JisB7         )   ;
        if(s == "jisb8")                  return QPageSize(QPageSize::JisB8         )   ;
        if(s == "jisb9")                  return QPageSize(QPageSize::JisB9         )   ;
        if(s == "jisb10")                 return QPageSize(QPageSize::JisB10        )   ;
        if(s == "ledger / ansib")         return QPageSize(QPageSize::Ledger        )   ;
        if(s == "legal")                  return QPageSize(QPageSize::Legal         )   ;
        if(s == "legalextra")             return QPageSize(QPageSize::LegalExtra    )   ;
        if(s == "letterextra")            return QPageSize(QPageSize::LetterExtra   )   ;
        if(s == "letterplus")             return QPageSize(QPageSize::LetterPlus    )   ;
        if(s == "lettersmall")            return QPageSize(QPageSize::LetterSmall   )   ;
        if(s == "note")                   return QPageSize(QPageSize::Note          )   ;
        if(s == "postcard")               return QPageSize(QPageSize::Postcard      )   ;
        if(s == "prc16k")                 return QPageSize(QPageSize::Prc16K        )   ;
        if(s == "prc32k")                 return QPageSize(QPageSize::Prc32K        )   ;
        if(s == "prc32kbig")              return QPageSize(QPageSize::Prc32KBig     )   ;
        if(s == "quarto")                 return QPageSize(QPageSize::Quarto        )   ;
        if(s == "statement")              return QPageSize(QPageSize::Statement     )   ;
        if(s == "supera")                 return QPageSize(QPageSize::SuperA        )   ;
        if(s == "superb")                 return QPageSize(QPageSize::SuperB        )   ;
        if(s == "tabloid")                return QPageSize(QPageSize::Tabloid       )   ;
        if(s == "tabloidextra")           return QPageSize(QPageSize::TabloidExtra  )   ;

        //we got something weird,
        QStringList arr = s.split("x");
        if(arr.length() == 2){
//            QString W = arr[0];
//            QString H = arr[1];

            qreal w = arr[0].toDouble();
            qreal h = arr[1].toDouble();
//            if(success && success2) //conversion was successful
                return QPageSize(QSizeF(w,h), QPageSize::Inch);
        }


        //4, 2.38


        return QPageSize(QPageSize::A4);               ;
    }
    QString pageSizeToString(QPageSize P){
        int p = P.id();

        if(p ==  QPageSize::A0                  ) return "A0";
        if(p ==  QPageSize::A0                  ) return "A0";
        if(p ==  QPageSize::A1                  ) return "A1";
        if(p ==  QPageSize::A2                  ) return "A2";
        if(p ==  QPageSize::A3                  ) return "A3";
        if(p ==  QPageSize::A3Extra             ) return "A3Extra";
        if(p ==  QPageSize::A4                  ) return "A4";
        if(p ==  QPageSize::A4Extra             ) return "A4Extra";
        if(p ==  QPageSize::A4Plus              ) return "A4Plus";
        if(p ==  QPageSize::A4Small             ) return "A4Small";
        if(p ==  QPageSize::A5                  ) return "A5";
        if(p ==  QPageSize::A5Extra             ) return "A5Extra";
        if(p ==  QPageSize::A6                  ) return "A6";
        if(p ==  QPageSize::A7                  ) return "A7";
        if(p ==  QPageSize::A8                  ) return "A8";
        if(p ==  QPageSize::A9                  ) return "A9";
        if(p ==  QPageSize::AnsiA               ) return "AnsiA";
        if(p ==  QPageSize::AnsiA               ) return "AnsiA";
        if(p ==  QPageSize::AnsiB               ) return "AnsiB";
        if(p ==  QPageSize::AnsiB               ) return "AnsiB";
        if(p ==  QPageSize::AnsiC               ) return "AnsiC";
        if(p ==  QPageSize::AnsiD               ) return "AnsiD";
        if(p ==  QPageSize::AnsiE               ) return "AnsiE";
        if(p ==  QPageSize::ArchA               ) return "ArchA";
        if(p ==  QPageSize::ArchB               ) return "ArchB";
        if(p ==  QPageSize::ArchC               ) return "ArchC";
        if(p ==  QPageSize::ArchD               ) return "ArchD";
        if(p ==  QPageSize::ArchE               ) return "ArchE";
        if(p ==  QPageSize::B0                  ) return "B0";
        if(p ==  QPageSize::B1                  ) return "B1";
        if(p ==  QPageSize::B2                  ) return "B2";
        if(p ==  QPageSize::B3                  ) return "B3";
        if(p ==  QPageSize::B4                  ) return "B4";
        if(p ==  QPageSize::B5                  ) return "B5";
        if(p ==  QPageSize::B5Extra             ) return "B5Extra";
        if(p ==  QPageSize::B6                  ) return "B6";
        if(p ==  QPageSize::B7                  ) return "B7";
        if(p ==  QPageSize::B8                  ) return "B8";
        if(p ==  QPageSize::B9                  ) return "B9";
        if(p ==  QPageSize::B10                 ) return "B10";
        if(p ==  QPageSize::DoublePostcard      ) return "DoublePostcard";
        if(p ==  QPageSize::Envelope9           ) return "Envelope9";
        if(p ==  QPageSize::Envelope10          ) return "Envelope10";
        if(p ==  QPageSize::Comm10E             ) return "Comm10E";
        if(p ==  QPageSize::Envelope11          ) return "Envelope11";
        if(p ==  QPageSize::Envelope12          ) return "Envelope12";
        if(p ==  QPageSize::Envelope14          ) return "Envelope14";
        if(p ==  QPageSize::EnvelopeB4          ) return "EnvelopeB4";
        if(p ==  QPageSize::EnvelopeB5          ) return "EnvelopeB5";
        if(p ==  QPageSize::EnvelopeB6          ) return "EnvelopeB6";
        if(p ==  QPageSize::EnvelopeC0          ) return "EnvelopeC0";
        if(p ==  QPageSize::EnvelopeC1          ) return "EnvelopeC1";
        if(p ==  QPageSize::EnvelopeC2          ) return "EnvelopeC2";
        if(p ==  QPageSize::EnvelopeC3          ) return "EnvelopeC3";
        if(p ==  QPageSize::EnvelopeC4          ) return "EnvelopeC4";
        if(p ==  QPageSize::EnvelopeC5          ) return "EnvelopeC5";
        if(p ==  QPageSize::C5E                 ) return "C5E";
        if(p ==  QPageSize::EnvelopeC6          ) return "EnvelopeC6";
        if(p ==  QPageSize::EnvelopeC7          ) return "EnvelopeC7";
        if(p ==  QPageSize::EnvelopeC65         ) return "EnvelopeC65";
        if(p ==  QPageSize::EnvelopeChou3       ) return "EnvelopeChou3";
        if(p ==  QPageSize::EnvelopeChou4       ) return "EnvelopeChou4";
        if(p ==  QPageSize::EnvelopeDL          ) return "EnvelopeDL";
        if(p ==  QPageSize::DLE                 ) return "DLE";
        if(p ==  QPageSize::EnvelopeInvite      ) return "EnvelopeInvite";
        if(p ==  QPageSize::EnvelopeItalian     ) return "EnvelopeItalian";
        if(p ==  QPageSize::EnvelopeKaku2       ) return "EnvelopeKaku2";
        if(p ==  QPageSize::EnvelopeKaku3       ) return "EnvelopeKaku3";
        if(p ==  QPageSize::EnvelopeMonarch     ) return "EnvelopeMonarch";
        if(p ==  QPageSize::EnvelopePersonal    ) return "EnvelopePersonal";
        if(p ==  QPageSize::EnvelopePrc1        ) return "EnvelopePrc1";
        if(p ==  QPageSize::EnvelopePrc2        ) return "EnvelopePrc2";
        if(p ==  QPageSize::EnvelopePrc3        ) return "EnvelopePrc3";
        if(p ==  QPageSize::EnvelopePrc4        ) return "EnvelopePrc4";
        if(p ==  QPageSize::EnvelopePrc5        ) return "EnvelopePrc5";
        if(p ==  QPageSize::EnvelopePrc6        ) return "EnvelopePrc6";
        if(p ==  QPageSize::EnvelopePrc7        ) return "EnvelopePrc7";
        if(p ==  QPageSize::EnvelopePrc8        ) return "EnvelopePrc8";
        if(p ==  QPageSize::EnvelopePrc9        ) return "EnvelopePrc9";
        if(p ==  QPageSize::EnvelopePrc10       ) return "EnvelopePrc10";
        if(p ==  QPageSize::EnvelopeYou4        ) return "EnvelopeYou4";
        if(p ==  QPageSize::Executive           ) return "Executive";
        if(p ==  QPageSize::ExecutiveStandard   ) return "ExecutiveStandar";
        if(p ==  QPageSize::FanFoldGerman       ) return "FanFoldGerman";
        if(p ==  QPageSize::FanFoldGermanLegal  ) return "FanFoldGermanLeg";
        if(p ==  QPageSize::FanFoldUS           ) return "FanFoldUS";
        if(p ==  QPageSize::Folio               ) return "Folio";
        if(p ==  QPageSize::Imperial7x9         ) return "Imperial7x9";
        if(p ==  QPageSize::Imperial8x10        ) return "Imperial8x10";
        if(p ==  QPageSize::Imperial9x11        ) return "Imperial9x11";
        if(p ==  QPageSize::Imperial9x12        ) return "Imperial9x12";
        if(p ==  QPageSize::Imperial10x11       ) return "Imperial10x11";
        if(p ==  QPageSize::Imperial10x13       ) return "Imperial10x13";
        if(p ==  QPageSize::Imperial10x14       ) return "Imperial10x14";
        if(p ==  QPageSize::Imperial12x11       ) return "Imperial12x11";
        if(p ==  QPageSize::Imperial15x11       ) return "Imperial15x11";
        if(p ==  QPageSize::JisB0               ) return "JisB0";
        if(p ==  QPageSize::JisB1               ) return "JisB1";
        if(p ==  QPageSize::JisB2               ) return "JisB2";
        if(p ==  QPageSize::JisB3               ) return "JisB3";
        if(p ==  QPageSize::JisB4               ) return "JisB4";
        if(p ==  QPageSize::JisB5               ) return "JisB5";
        if(p ==  QPageSize::JisB6               ) return "JisB6";
        if(p ==  QPageSize::JisB7               ) return "JisB7";
        if(p ==  QPageSize::JisB8               ) return "JisB8";
        if(p ==  QPageSize::JisB9               ) return "JisB9";
        if(p ==  QPageSize::JisB10              ) return "JisB10";
        if(p ==  QPageSize::Ledger              ) return "Ledger";
        if(p ==  QPageSize::Legal               ) return "Legal";
        if(p ==  QPageSize::LegalExtra          ) return "LegalExtra";
        if(p ==  QPageSize::LetterExtra         ) return "LetterExtra";
        if(p ==  QPageSize::LetterPlus          ) return "LetterPlus";
        if(p ==  QPageSize::LetterSmall         ) return "LetterSmall";
        if(p ==  QPageSize::Note                ) return "Note";
        if(p ==  QPageSize::Postcard            ) return "Postcard";
        if(p ==  QPageSize::Prc16K              ) return "Prc16K";
        if(p ==  QPageSize::Prc32K              ) return "Prc32K";
        if(p ==  QPageSize::Prc32KBig           ) return "Prc32KBig";
        if(p ==  QPageSize::Quarto              ) return "Quarto";
        if(p ==  QPageSize::Statement           ) return "Statement";
        if(p ==  QPageSize::SuperA              ) return "SuperA";
        if(p ==  QPageSize::SuperB              ) return "SuperB";
        if(p ==  QPageSize::Tabloid             ) return "Tabloid";
        if(p ==  QPageSize::TabloidExtra        ) return "TabloidExtra";

        QSizeF size = P.size(QPageSize::Inch);
        QString w = QString::number ( size.width() , 'g', 6 );
        QString h = QString::number ( size.height(), 'g', 6 );

        return w + "x" + h ;
    }





};

#endif // ZPRINTER_H
