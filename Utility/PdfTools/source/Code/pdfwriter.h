#ifndef PDFWRITER
#define PDFWRITER

#include <QPdfWriter>
#include <QPainter>
#include <QQuickItem>
#include <QColor>
#include <QFontDatabase>
#include <iostream>
#include <QPageSize>
#include <QHash>
#include <QtQuick/QQuickPaintedItem>
#include <QList>
#include <qDebug>
#include <QImage>
#include <QQueue>
#include <QDebug>
#include <QDir>


using namespace std;

class pdfWriter : public QQuickPaintedItem
{

    enum PAINT_TYPE {  None, TextML, Arc, Chord, Ellipse, Line, Pie, Point, Rect, Cell, Image   };
    struct paintInfo
    {
        PAINT_TYPE type;
        QString text;
        QString font;
        QString fontStyle;
        int     fontSize;

        int x ,y, w, h, flags, lineWidth, startAngle, aLen;
        QColor color, fillColor;
        QImage img;

        paintInfo()
        {
            type = None;
            text = "";
            x = y = w = h = flags = lineWidth = startAngle = aLen = 0;
            color = fillColor = Qt::transparent;
            font = "MS Shell Dlg 2";
            fontStyle = "normal";
            fontSize = 12;
        }
        paintInfo(PAINT_TYPE pType, int X, int Y, int W, int H, int Flags = 0, int LW = 1, QColor clr = Qt::black, QColor fillClr = Qt::transparent, QString Text = "", int SA = 0, int AL = 0, QImage Img = QImage(), QString Font = "Ms Shell Dlg 2", QString FontStyle = "Normal", int FontSize = 12)
        {
            type = pType;
            x = X;
            y = Y;
            w = W;
            h = H;
            flags = Flags;
            lineWidth = LW;
            color = clr;
            fillColor = fillClr;
            text = Text;
            startAngle = SA;
            aLen = AL;
            img = Img;
            font = Font;
            fontStyle = FontStyle;
            fontSize = FontSize;

        }
        paintInfo(const paintInfo &rhs)
        {
            type = rhs.type;
            x = rhs.x;
            y = rhs.y;
            w = rhs.w;
            h = rhs.h;
            flags = rhs.flags;
            lineWidth = rhs.lineWidth;
            color = rhs.color;
            fillColor = rhs.fillColor;
            text = rhs.text;
            startAngle = rhs.startAngle;
            aLen = rhs.aLen;
            img = rhs.img;
            font = rhs.font;
            fontStyle = rhs.fontStyle;
            fontSize = rhs.fontSize;


        }
        paintInfo& operator=(const paintInfo &rhs)
        {
            type = rhs.type;
            x = rhs.x;
            y = rhs.y;
            w = rhs.w;
            h = rhs.h;
            flags = rhs.flags;
            lineWidth = rhs.lineWidth;
            color = rhs.color;
            fillColor = rhs.fillColor;
            text = rhs.text;
            startAngle = rhs.startAngle;
            aLen = rhs.aLen;
            img = rhs.img;
            font = rhs.font;
            fontStyle = rhs.fontStyle;
            fontSize = rhs.fontSize;
            return *this;
        }
    };
    struct section
    {
        QString name;
        QList<paintInfo> body;
        QList<paintInfo> header;
        QList<paintInfo> footer;
        QList<paintInfo> lefter;
        QList<paintInfo> righter;

        section() : name("untitled_section") {}
        section(QString name,
                QList<paintInfo> body    = QList<paintInfo>(),
                QList<paintInfo> header  = QList<paintInfo>(),
                QList<paintInfo> footer  = QList<paintInfo>(),
                QList<paintInfo> lefter  = QList<paintInfo>(),
                QList<paintInfo> righter = QList<paintInfo>())
        {
            this->name = name;
            this->body = body;
            this->header = header;
            this->footer = footer;
            this->lefter = lefter;
            this->righter = righter;
        }

        section(const section &rhs)
        {
            name = rhs.name;
            body = rhs.body;
            header = rhs.header;
            footer = rhs.footer;
            lefter = rhs.lefter;
            righter = rhs.righter;
        }
        section& operator=(const section &rhs)
        {
            name = rhs.name;
            body = rhs.body;
            header = rhs.header;
            footer = rhs.footer;
            lefter = rhs.lefter;
            righter = rhs.righter;
            return *this;
        }

    };



    Q_OBJECT
//    Q_DISABLE_COPY(pdfWriter)

    Q_PROPERTY (QString   title          READ getTitle         WRITE setTitle            NOTIFY titleChanged)
    //Q_PROPERTY (QString   font           READ getFontName      WRITE setFont             NOTIFY fontChanged    )
    //Q_PROPERTY (FontStyle fontStyle      READ getFontStyle     WRITE setFontStyle        NOTIFY fontChanged    )
    //Q_PROPERTY (int       fontSize       READ getFontPointSize WRITE setFontPointSize    NOTIFY fontChanged    )
    Q_PROPERTY (int       dpi            READ getDPI           WRITE setDPI              NOTIFY dpiChanged     )
    Q_PROPERTY (double    l_Margin       READ getLeftMargin    WRITE setLeftMargin       NOTIFY l_marginChanged)
    Q_PROPERTY (double    t_Margin       READ getTopMargin     WRITE setTopMargin        NOTIFY t_marginChanged)
    Q_PROPERTY (double    r_Margin       READ getRightMargin   WRITE setRightMargin      NOTIFY r_marginChanged)
    Q_PROPERTY (double    b_Margin       READ getBottomMargin  WRITE setBottomMargin     NOTIFY b_marginChanged)
    Q_PROPERTY (QString   pgOrientation  READ getPgOrientation WRITE setPgOrientation    NOTIFY pageOrientationChanged)
    Q_PROPERTY (QString   pageSize       READ getPgSize        WRITE setPageSize         NOTIFY pageSizeChanged)
    Q_PROPERTY (double    pageWidthInches READ  getPageWidthInches  NOTIFY pageWidthInchesChanged)
    Q_PROPERTY (double    pageHeightInches READ getPageHeightInches NOTIFY pageHeightInchesChanged)

    Q_PROPERTY (int       maxCanvasWidth  READ getMaxCanvasWidth  WRITE setMaxCanvasWidth   NOTIFY maxCanvasWidthChanged)
    Q_PROPERTY (int       maxCanvasHeight READ getMaxCanvasHeight WRITE setMaxCanvasHeight  NOTIFY maxCanvasHeightChanged)
    Q_PROPERTY (int       currentSection  READ getCurrentSection  WRITE setCurrentSection   NOTIFY currentSectionChanged)
    Q_PROPERTY (int       numSections     READ getNumSections                               NOTIFY numSectionsChanged)
    Q_PROPERTY (bool      noTransparencyInImages READ getNoTransparencyInImages WRITE setNoTransparencyInImages)
    Q_PROPERTY (bool      paintOnCanvas READ getDoPaint WRITE setDoPaint    NOTIFY paintOnCanvasChanged)
    Q_PROPERTY (bool      removeImagesAfterFinalize READ getRemoveImagesAfterFinalize WRITE setRemoveImagesAfterFinalize    NOTIFY removeImagesAfterFinalizeChanged)
    Q_PROPERTY (int       pageNumberOnFooter READ getPageNumberOnFooter WRITE setPageNumberOnFooter NOTIFY pageNumberOnFooterChanged)



    Q_ENUMS    (FontStyle)
//    Q_ENUMS    (QPageSize::PageSizeId)

    signals:
        //void fontChanged    (QString fontName, QString style, int pointSize);
        void dpiChanged     (int dpi);
        void marginsChanged (double leftMargin, double topMargin, double rightMargin, double bottomMargin);
        void pageOrientationChanged(QString mode);
        void pageSizeChanged(QString size);
        void titleChanged(QString title);
        void maxCanvasWidthChanged(int width);
        void maxCanvasHeightChanged(int height);
        void currentSectionChanged(int currentSection);
        void numSectionsChanged(int numSections);
        void pageWidthInchesChanged(double pgWidthInches);
        void pageHeightInchesChanged(double pgHeightInches);
        void pageNumberOnFooterChanged(int pageNumberOnFooter);
        void paintOnCanvasChanged();

        void l_marginChanged();
        void r_marginChanged();
        void t_marginChanged();
        void b_marginChanged();
        void finishedSaving(QString filePath);
        void removeImagesAfterFinalizeChanged();


    public:
        enum FontStyle       { Bold, Bold_Italic, Italic, Normal  };

        //ctor
        pdfWriter(QQuickItem *parent = 0) : QQuickPaintedItem(parent) { refreshSizeMaps();  reset();   setFlag(QQuickItem::ItemHasContents); }

        //Property functions
        int getPageNumberOnFooter() const {
            return _pageNumberOnFooter;
        }
        void setPageNumberOnFooter(const int &footerLocation) {
            if(footerLocation != _pageNumberOnFooter) {
                _pageNumberOnFooter = footerLocation;
                pageNumberOnFooterChanged(footerLocation);
            }
        }



        ////remove images after paint
        bool getRemoveImagesAfterFinalize() const { return _removeImagesAfterFinalize; }
        void setRemoveImagesAfterFinalize(const bool &newRemoveImagesAfterFinalize)
        {
            if(newRemoveImagesAfterFinalize != _removeImagesAfterFinalize)
            {
                _removeImagesAfterFinalize = newRemoveImagesAfterFinalize;
                emit removeImagesAfterFinalizeChanged();
            }
        }

        ////paint on canvas
        bool getDoPaint() const { return _doPaint; }
        void setDoPaint(const bool &paintOnCanvas)
        {
            if(paintOnCanvas != _doPaint)
            {
                _doPaint = paintOnCanvas;
                emit paintOnCanvasChanged();
            }
        }

        ////title
        QString getTitle() const { return _title; }
        void setTitle(const QString &newTitle)
        {
            if(newTitle != _title && newTitle != "")
            {
                _title = newTitle;
                emit titleChanged(_title);
            }
        }

        ////DPI
        int  getDPI() const  {  return _dpi;  }
        void setDPI(const int &newDpi)
        {
            if(_dpi != newDpi)
            {
                _dpi = newDpi;
                maintainAspectRatio();
                emit dpiChanged(newDpi);
            }
        }

        ////Margins
        double getLeftMargin()     const { return _margins.left();     }
        double getTopMargin()      const { return _margins.top();      }
        double getRightMargin()    const { return _margins.right();    }
        double getBottomMargin()   const { return _margins.bottom();   }

        void setLeftMargin(const double &left)
        {
            if(left != _margins.left())
            {
                setMargins(left, _margins.top(), _margins.right(), _margins.bottom());
                emit marginsChanged(_margins.left(), _margins.top(), _margins.right(), _margins.bottom());
                emit l_marginChanged();
            }
        }
        void setTopMargin(const double &top)
        {
            if(top != _margins.top())
            {
                setMargins(_margins.left(), top, _margins.right(), _margins.bottom());
                emit marginsChanged(_margins.left(), _margins.top(), _margins.right(), _margins.bottom());
                emit t_marginChanged();
            }
        }
        void setRightMargin(const double &right)
        {
            if(right != _margins.right())
            {
                setMargins(_margins.left(), _margins.top(), right, _margins.bottom());
                emit marginsChanged(_margins.left(), _margins.top(), _margins.right(), _margins.bottom());
                emit r_marginChanged();
            }
        }
        void setBottomMargin(const double &bottom)
        {
            if(bottom != _margins.bottom())
            {
                setMargins(_margins.left(), _margins.top(), _margins.right(), bottom);
                emit marginsChanged(_margins.left(), _margins.top(), _margins.right(), _margins.bottom());
                emit b_marginChanged();
            }
        }

        ////Page orientation
        QString getPgOrientation() const
        {
            if(_pageOrientation == QPageLayout::Landscape)  return "LandScape";
            else                                            return "Portrait";
        }
        void setPgOrientation(const QString &newPgOrientation)
        {
            QString val = newPgOrientation.toLower();
            if     (val == "landscape" && _pageOrientation != QPageLayout::Landscape)
            {
                QMarginsF tempMargins = _margins;       //for some reason the margins break the transition from landscape to portrait and vice versa if they are set to 0.1 or low numbers.
                setMargins(1,1,1,1);

                _pageOrientation = QPageLayout::Landscape;
                maintainAspectRatio();
                emit pageOrientationChanged("Landscape");

                _margins = tempMargins;
            }
            else if(val == "portrait" &&  _pageOrientation != QPageLayout::Portrait)
            {
                QMarginsF tempMargins = _margins;
                setMargins(1,1,1,1);

                _pageOrientation = QPageLayout::Portrait;
                maintainAspectRatio();
                emit pageOrientationChanged("Portrait");

                _margins = tempMargins;
            }
        }

        ////Set PageSize (accepts arguments seperated by commas)
        QString getPgSize() const
        {
            QSizeF  size = _pageSize.size(QPageSize::Inch);
            return  QString::number(size.width(),'g',2) + " in. x " + QString::number(size.height(),'g',2) + " in.";
        }
        void setPageSize(const QString &pageSize)
        {
            //If we got a string like this  '12.3,20.2'
            QStringList numbers = pageSize.split(",");
            if(numbers.length() > 1)
            {
                bool widthOK, heightOK;
                double width  = numbers[0].toDouble(&widthOK );
                double height = numbers[1].toDouble(&heightOK);

                if(widthOK && heightOK)
                {
                    _pageSize = QPageSize(QSizeF(width,height),QPageSize::Inch);
                    maintainAspectRatio();
                    emit pageSizeChanged("Custom:"   + QString::number(width,'g',2)  +
                                         + " in. x " + QString::number(height,'f',2) + " in. ");
                    emit pageWidthInchesChanged(getPageWidthInches());
                    emit pageHeightInchesChanged(getPageHeightInches());

//                    if(writer != NULL)  writer->setPageSize(_pageSize);
                }
            }
            else    //we got a string for a QPageSize::PageSizeId (a4, letter, etc)
            {
                QString pgSizeLowerCase = pageSize.toLower();
                if(_sizeMap.contains(pgSizeLowerCase))
                {
                    _pageSize = QPageSize(_sizeMap[pgSizeLowerCase]);

                    double width  = _pageSize.size(QPageSize::Inch).width ();
                    double height = _pageSize.size(QPageSize::Inch).height();
                    maintainAspectRatio();
                    emit pageSizeChanged(pgSizeLowerCase + ":" + width + " in. x " + height + " in.");
                    emit pageWidthInchesChanged(getPageWidthInches());
                    emit pageHeightInchesChanged(getPageHeightInches());
//                    if(writer != NULL)  writer->setPageSize(_pageSize);
                }
            }
        }

        ////Canvas width
        int getMaxCanvasWidth() const  { return _maxW; }
        void setMaxCanvasWidth(const int &w)
        {
            if(w != _maxW)
            {
                _maxW = w;
                maintainAspectRatio();
                emit maxCanvasWidthChanged(_maxW);
            }
        }

        ////Canvas height
        int getMaxCanvasHeight() const { return _maxH; }
        void setMaxCanvasHeight(const int &h)
        {
            if(h != _maxH)
            {
                _maxH = h;
                maintainAspectRatio();
                emit maxCanvasWidthChanged(_maxH);
            }
        }

        ////CurrentSection
        int getCurrentSection() { return _currentSection; }
        void setCurrentSection(const int &s)
        {
            if(s != _currentSection && s >= 0 && s < _sections.length())
            {
                _currentSection = s;
                currentSectionChanged(_currentSection);
                update();
            }
        }

        ////Num Sections
        int getNumSections() const { return _sections.length(); }

        ////pagewidth inches , pagehegiht inches
        double getPageWidthInches () const     {    return _pageSize.size(QPageSize::Inch).width();       }
        double getPageHeightInches() const     {    return _pageSize.size(QPageSize::Inch).height();      }


        ////Invert Pixels in pdf
        bool getNoTransparencyInImages() const { return _noTransparencyInImages ; }
        void setNoTransparencyInImages(const bool & b)
        {
            if(b != _noTransparencyInImages)
                _noTransparencyInImages = b;
        }


        //Funcions
        Q_INVOKABLE  void addSection(QString name)
        {
            section sec;
            sec.name = name;
            _sections.append(sec);

            numSectionsChanged(_sections.length());
            setCurrentSection(_sections.length() - 1);
        }
        Q_INVOKABLE  bool deleteSection(QString name)
        {
            if(_sections.length() > 1)
            {
                for(int i = 0; i < _sections.length(); i++)
                {
                    if(_sections[i].name == name)
                    {
                        _sections.removeAt(i);
                        numSectionsChanged(_sections.length());
                        setCurrentSection(0);
                    }
                }
            }
            return false;
        }
        Q_INVOKABLE void changeSectionName(QString name, int sectionNum)
        {
            if(sectionNum > - 1 && sectionNum <= _sections.length() && _sections[sectionNum].name != name)
                _sections[sectionNum].name = name;
        }
        Q_INVOKABLE QString getSectionName(int sectionNum)
        {
            if(sectionNum > - 1 && sectionNum <= _sections.length())
                return _sections[sectionNum].name;
            return "Bad section index";
        }
        Q_INVOKABLE int getSectionIndex(QString name)
        {
            ////qDebug() << "C++ getSectionIndex(" << name << ")";
            for(int i = 0; i < _sections.length(); i++)
            {
                if(_sections[i].name == name)
                    return i;
            }
            return -1;
        }


        Q_INVOKABLE  void finalize(QString name = "", bool newPagePerSection = true)     //Saves the contents of the painter into the pdf!! Calls paint section on every section!
        {
            if(name == "")
                name = QDir::currentPath() + "/untitled.pdf";
            else
            {
                if(name.toLower().contains("qrc:///")) {
                    name = name.remove(0, 7);
                    name = "file:///" + QDir::currentPath() + "/" + name;
                }

                QUrl url(name);
                name = url.toLocalFile();
            }

            QPdfWriter writer(name);
            writer.setPageSize(_pageSize);
            writer.setPageOrientation(_pageOrientation);
            writer.setPageMargins(QMarginsF(0,0,0,0), QPageLayout::Inch);
            writer.setResolution(_dpi);
            writer.setTitle(_title);

            QQueue<paintInfo> emptyBuffer;  //just need this to draw pageNumber
            QPainter painter(&writer);

            setFont(_fontName, _fontStyle, _fontPointSize, painter);

            //lets add first page number :D
            drawFooterPageNumber(painter, emptyBuffer);

            //lets add the title to the header!
            for(int s = 0; s < _sections.length(); s++)
                drawMultiLineText(_sections[s].name,20,20,600,200,0,1,Qt::black, Qt::red, "header", s);

            for(int s = 0 ; s < _sections.length(); s++)
            {
               paintSection(painter,writer, s);

               if(s < _sections.length() - 1 && newPagePerSection) {
                    writer.newPage();
                    drawFooterPageNumber(painter, emptyBuffer);
               }
//               paintSiders(painter, s);
            }

            //qDebug() <<"Finalizing paint. Polishing!";
            if(painter.end())   //confirm that we saved by check that the painter is no longer active!!
                emit finishedSaving(name);
        }


        void drawFooterPageNumber(QPainter &painter, QQueue<paintInfo> &buffer) {
            if(_pageNumberOnFooter > 0) {
                //1 will be left

                QString pageNum = QString::number(_pageNum + 1);
                _pageNum++;

                //qDebug() << "NOT LONG ENOUGH!!" << text;
                //qDebug() << "drawing FooterPageNumber" << _pageNum << " " << pageNum;

                int width  = pageNum.length() * _fontPointSize + _fontPointSize;
                int height = _fontPointSize + 2;

                int x = 2;
                int y = this->height() -  height - 4;

                if     (_pageNumberOnFooter == 1)                x = 2;
                else if(_pageNumberOnFooter == 2)                x = (this->width())/2 - width/2;
                else                                             x = (this->width())   - width - _fontPointSize;

                paintInfo p(TextML, x,y, width,height);
                p = convertToPdfRatio(p);

                drawMultiLineText(pageNum, p.x, p.y, p.w, p.h, 0, 1, Qt::black, Qt::transparent, "footer", -1, _fontName, "Normal", _fontPointSize,  &painter, &buffer, true);
            }
        }
        void paintSection(QPainter &painter, QPdfWriter &writer, int sectionNum)
        {
            section &s = _sections[sectionNum];
            QQueue<paintInfo> buffer;            //this will store stuff that goes past one page for this section

            for(int i = s.body.length() - 1; i >= 0; i--)
                buffer.push_back(convertToPdfRatio(s.body[i]));

            paintSiders(painter, sectionNum);                      //paint the headers and footers and siders
            paintBody  (buffer, painter, writer,sectionNum);       //this will handle making new pages if necessary

            //we remove images cause they will be handed to us again each time from qml!
            if(_removeImagesAfterFinalize)
            {
                removeImages(s.header);
                removeImages(s.body);
                removeImages(s.footer);
                removeImages(s.lefter);
                removeImages(s.righter);
            }
        }
        void removeImages(QList<paintInfo> &p)
        {
            for(int i = p.length() -1 ; i >= 0; i--)
            {
                if(p[i].type == Image)
                    p.removeAt(i);
            }
        }
        void paintBody(QQueue<paintInfo>  &buffer, QPainter &painter, QPdfWriter &writer, int sectionNum)
        {
            QQueue<paintInfo> buffer2;
            while(!buffer.isEmpty())
            {
                paintInfo &p =  buffer.first();
                switch(p.type)
                {
                    case None   : break;
                    case TextML : drawMultiLineText(p.text, p.x, p.y, p.w, p.h, p.flags,              p.lineWidth, p.color, p.fillColor, "body", -1, p.font, p.fontStyle, p.fontSize,  &painter, &buffer2); break;
                    case Arc    : drawArc          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Chord  : drawChord        (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Ellipse: drawEllipse      (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Line   : drawLine         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Pie    : drawPie          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Point  : drawPoint        (        p.x, p.y,                                 p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Rect   : drawRect         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Cell   : drawCell         (p.text, p.x, p.y, p.w, p.h, p.flags,              p.color, p.fillColor, p.lineWidth, &painter, "body", -1,  &buffer2); break;
                    case Image  : drawImage        (        p.x, p.y ,                                                   p.img, "body", -1,  &painter, &buffer2); break;
                }

                buffer.removeFirst();
            }

            if(!buffer2.isEmpty())
            {
                writer.newPage();
                drawFooterPageNumber(painter, buffer2);
                paintSiders(painter, sectionNum);
                paintBody(buffer2,painter,writer, sectionNum);        //call self so we keep making new pages as necessary!
            }
        }
        void paintSiders(QPainter &painter, int sectionNum)
        {
            paintList(painter,_sections[sectionNum].header , "header");
            paintList(painter,_sections[sectionNum].footer , "footer");
            paintList(painter,_sections[sectionNum].lefter , "lefter");
            paintList(painter,_sections[sectionNum].righter, "righter");
        }
        void paintList(QPainter &painter, QList<paintInfo> &list, const QString &part)
        {
            QQueue<paintInfo> buffer;
            for(int i = 0; i < list.length(); i++)
            {
                buffer.push_back(convertToPdfRatio(list[i]));
            }

            while(!buffer.isEmpty())
            {
                paintInfo &p =  buffer.first();
                switch(p.type)
                {
                    case None   : break;
                    case TextML : drawMultiLineText(p.text, p.x, p.y, p.w, p.h, p.flags,              p.lineWidth, p.color, p.fillColor, part, -1, p.font, p.fontStyle, p.fontSize,  &painter); break;
                    case Arc    : drawArc          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Chord  : drawChord        (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Ellipse: drawEllipse      (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Line   : drawLine         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Pie    : drawPie          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Point  : drawPoint        (        p.x, p.y,                                 p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Rect   : drawRect         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Cell   : drawCell         (p.text, p.x, p.y, p.w, p.h, p.flags,              p.color, p.fillColor, p.lineWidth, &painter, part); break;
                    case Image  : drawImage        (        p.x, p.y ,                                                            p.img, part, -1, &painter,NULL,false); break;
                }

                buffer.removeFirst();
            }

        }


        //Base drawing methods (we'll likely never use them but let's have em anyway)
        //The base drawing things expect we will never give them things longer than the actual page. U HATH BEEN WARNED! It will auto ptu them on the next page if they are going to get clipped at the end.
        Q_INVOKABLE  void drawMultiLineText(const QString &text,
                                            int x, int y, int w, int h,
                                            int flags, int lineWidth = 1,
                                            QColor color = Qt::black, QColor fillColor = Qt::transparent,
                                            QString part = "body",
                                            int sectionNum = -1,
                                            QString Font = "", QString FontStyle = "Normal", int FontSize = 12,
                                            QPainter *painter = NULL, QQueue<paintInfo> *pageBuffer = NULL, bool overrideBotMargin = false)
        {
            QFont f(Font, FontSize);
            QString f_style = FontStyle.toLower();
            if     (f_style == "bold italic"){   f.setBold(true)  ;  f.setItalic(true);  }
            else if(f_style == "italic")         f.setItalic(true);
            else if(f_style == "bold")           f.setBold(true)  ;

            QStringList list = text.split("\n");
            int spacing      = Font != "" ? QFontMetrics(f).lineSpacing() :  QFontMetrics(QFont(_fontName, _fontPointSize)).lineSpacing();


            //TODO , EITHER THIS THING DOESNT WORK OR THE SCALING IT UP DFOESNMT. FIX PLZ!
            if(painter == NULL)
                h = list.length() * (spacing);


            if(painter != NULL)
            {
                if(Font != "")
                {
                    painter->save();
                    painter->setFont(f);
                    spacing = painter->fontMetrics().lineSpacing();
                    painter->restore();
                }
                else
                    spacing  = painter->fontMetrics().lineSpacing();

                if(!overrideBotMargin) {
                    if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    {
                        int extraPixels = y + h - pixelSize().y() + botMarginPx();                 //These are the pixels outside of this page!
                        int inPgPixels  = h - extraPixels;                                         //The pixels in this page!
                        int linesToPrintNow = (inPgPixels / spacing) ;                             //this gives us the highest index of what lines we can print

                        QString printNow   = "";
                        QString printLater = "";
                        for(int i = 0; i < list.length(); i++)
                        {
                            if(i < linesToPrintNow)     printNow   += list[i] + "\n";
                            else                        printLater += list[i] + "\n";
                        }


                        //print now!
                        painter->save();
                        QBrush myBrush(fillColor);
                        QPen   myPen  (QBrush(color), lineWidth);
                        painter->setPen(myPen);
                        painter->setBrush(myBrush);

                        if(Font != "")
                            painter->setFont(f);

                        painter->drawText(QRect(x,y,w,inPgPixels), flags,printNow);

                        painter->restore();


                        if(!printLater.trimmed().isEmpty())
                        {
                            pageBuffer->push_back(paintInfo(TextML,x,topMarginPx() + 1,w,extraPixels,flags,lineWidth,color, fillColor, printLater, 0, 0,QImage(),Font,FontStyle,FontSize));  //keeping same x but makign new Y :D :D :D :D
                        }

                        //have to split the text somehow and determine where it gets split off!!
                    }
                    else
                    {
                        //qDebug() << "NOT LONG ENOUGH!!" << text;
                        painter->save();

                        QBrush myBrush(fillColor);
                        QPen   myPen  (QBrush(color), lineWidth);
                        painter->setPen(myPen);
                        painter->setBrush(myBrush);


                        if(Font != "")
                        {
                            QFont f(Font, FontSize);
                            QString f_style = FontStyle.toLower();

                            if     (f_style == "bold italic"){   f.setBold(true)  ;  f.setItalic(true);  }
                            else if(f_style == "italic")         f.setItalic(true);
                            else if(f_style == "bold")           f.setBold(true)  ;

                            painter->setFont(f);
                        }


                        painter->drawText(QRect(x,y,w,h), flags,text);
                        painter->restore();
                    }
                }
                else {
                    //qDebug() << "NOT LONG ENOUGH!!" << text;
                    painter->save();

                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);


                    if(Font != "")
                    {
                        QFont f(Font, FontSize);
                        QString f_style = FontStyle.toLower();

                        if     (f_style == "bold italic"){   f.setBold(true)  ;  f.setItalic(true);  }
                        else if(f_style == "italic")         f.setItalic(true);
                        else if(f_style == "bold")           f.setBold(true)  ;

                        painter->setFont(f);
                    }


                    painter->drawText(QRect(x,y,w,h), flags,text);
                    painter->restore();
                }

            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                //qDebug() << "Saving for later" << text << "FONT = " << Font << " " << FontStyle << " " << FontSize ;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(TextML,x,y,w,h,flags,lineWidth,color,fillColor,text,0,0,QImage(),Font,FontStyle,FontSize));
                update();   //should call paint!!!(NULL);
            }
        }
        Q_INVOKABLE  void drawArc    (int x, int y , int w, int h, int startAngle, int arcLen, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Arc,x,topMarginPx() + 1,w,h,0,lineWidth,color, fillColor, "", startAngle, arcLen));  //keeping same x but makign new Y :D :D :D :D
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawArc(x,y,w,h,startAngle,arcLen);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Arc,x,y,w,h,0,lineWidth,color,fillColor,"",startAngle,arcLen));
                update();   //should call paint!!!(NULL);
            }
        }
        Q_INVOKABLE  void drawChord  (int x, int y, int w, int h, int startAngle, int arcLen, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Chord,x,topMarginPx() + 1,w,h,0,lineWidth,color,fillColor,"",startAngle,arcLen));
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawChord(x,y,w,h,startAngle,arcLen);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Chord,x,y,w,h,0,lineWidth,color,fillColor,"",startAngle,arcLen));
                update();   //should call paint!!!(NULL);
            }
        }
        Q_INVOKABLE  void drawEllipse(int x, int y, int w, int h, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Ellipse,x,topMarginPx() + 1,w,h,0,lineWidth,color,fillColor,"",0,0));
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawEllipse(x,y,w,h);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Ellipse,x,y,w,h,0,lineWidth,color,fillColor,"",0,0));
                update();   //should call paint!!!
            }
        }

        Q_INVOKABLE  void drawLineOverloaded (int x1, int y1, int x2, int y2, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QString part = "body",  int sectionNum = -1) {
            drawLine(x1,y1,x2,y2,color,fillColor,lineWidth,NULL,part,sectionNum,NULL);
        }
        Q_INVOKABLE  void drawLine   (int x1, int y1, int x2, int y2, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
//                qDebug() << "ZHEY ZHEY DrawLine CALLED on pg : " << _pageNum << " on " << part ;

                if(pageBuffer != NULL && y1 > pixelSize().y() - botMarginPx() ) {
                    int diff = y2 - y1;
                    y1 = topMarginPx() + 1;
                    y2 = y1 + diff;

                    pageBuffer->push_back(paintInfo(Line,x1,y1,x2,y2,0,lineWidth,color,fillColor,"",0,0));
                }
                else
                {
                    painter->save();

                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);

                    painter->drawLine(x1,y1,x2,y2);

                    painter->restore();
                }
            }
            else
            {
//                qDebug() << "HEY HEY DrawLine CALLED on pg : " << _pageNum << " on " << part ;
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Line,x1,y1,x2,y2,0,lineWidth,color,fillColor,"",0,0));
                update();   //should call paint!!!
            }
        }

        Q_INVOKABLE  void drawPie    (int x, int y, int w, int h, int startAngle, int spanAngle, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Pie,x,topMarginPx() + 1,w,h,0,lineWidth,color,fillColor,"",startAngle,spanAngle));
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawPie(x,y,w,h,startAngle,spanAngle);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Pie,x,y,w,h,0,lineWidth,color,fillColor,"",startAngle,spanAngle));
                update();   //should call paint!!!
            }
        }
        Q_INVOKABLE  void drawPoint  (int x, int y, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y  > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Point,x,topMarginPx() + 1,0,0,0,lineWidth,color,fillColor,"",0,0));
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawPoint(x,y);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Point,x,y,0,0,0,lineWidth,color,fillColor,"",0,0));
                update();   //should call paint!!!
            }
        }
        Q_INVOKABLE  void drawRect   (int x, int y , int w , int h, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL)
        {
            if(painter != NULL)
            {
                if(pageBuffer != NULL && y + h > pixelSize().y() - botMarginPx())
                    pageBuffer->push_back(paintInfo(Rect,x,topMarginPx() + 1,w,h,0,lineWidth,color,fillColor,"",0,0));
                else
                {
                    painter->save();
                    QBrush myBrush(fillColor);
                    QPen   myPen  (QBrush(color), lineWidth);
                    painter->setPen(myPen);
                    painter->setBrush(myBrush);
                    painter->drawRect(x,y,w,h);
                    painter->restore();
                }
            }
            else
            {
                if(sectionNum == -1)
                    sectionNum = _currentSection;

                getSectionPart(_sections[sectionNum], part).append(paintInfo(Rect,x,y,w,h,0,lineWidth,color,fillColor,"",0,0));
                update();   //should call paint!!!
            }
        }

        //Draw cell
        Q_INVOKABLE void drawCell(const QString &text, int x, int y, int w, int h, int flags, QColor color = Qt::black, QColor fillColor = Qt::transparent, int lineWidth = 1, QPainter *painter = NULL, QString part = "body",  int sectionNum = -1, QQueue<paintInfo> *pageBuffer = NULL, QString fontName = "", QString fontStyle = "normal", int fontSize = 12)
        {
            drawRect(x,y,w,h,color,fillColor,lineWidth,painter,part,  sectionNum, pageBuffer);
            drawMultiLineText(text,x,y,w,h,flags,lineWidth,color,fillColor,part,sectionNum,fontName,fontStyle,fontSize,painter,pageBuffer);
        }

        //TODO remove iteration if you feel like its slowing you down
        Q_INVOKABLE void maintainAspectRatio()
        {
            //always try to get as close to maxW and maxH
            if(_maxW > 0 && _maxH > 0)
            {
                QPoint p = pixelSize();
                int w = p.x();
                int h = p.y();

                int Rx = w / gcd(w,h);
                int Ry = h / gcd(w,h);

                //FOR TUNA overlord, if you wish, you can remove iteration from here!
                while(w > _maxW || h > _maxH)
                {
                    w -= Rx;
                    h -= Ry;
                }
//                //qDebug() << QString("maintain aspect ratio called %1:%2 . new w: %3 \t new h: %4 \t\tmaxW:%5\tmaxH:%6").arg(Rx).arg(Ry).arg(w).arg(h).arg(_maxW).arg(_maxH);

                //we update all our paints cause we so cool!
//                if(this->width() > 0 && this->height() > 0)
//                {
//                    double xMulti = w / this->width();
//                    double yMulti = h / this->height();
//                    for(int s = 0; s < _sections.length(); s++)
//                    {
//                        for(int i = 0; i < _sections[s].body.length(); i++)
//                        {
//                           _sections[s].body[i].x *= xMulti;
//                           _sections[s].body[i].y *= yMulti;
//                           _sections[s].body[i].w *= xMulti;
//                           _sections[s].body[i].h *= yMulti;
//                        }

//                        for(int i = 0; i < _sections[s].header.length(); i++)
//                        {
//                           _sections[s].header[i].x *= xMulti;
//                           _sections[s].header[i].y *= yMulti;
//                           _sections[s].header[i].w *= xMulti;
//                           _sections[s].header[i].h *= yMulti;
//                        }
//                    }
//                }

                this->setWidth(w);
                this->setHeight(h);
    //            update();
            }
        }        
        Q_INVOKABLE void drawImage(int x, int y, QImage img = QImage(), QString part = "well derp",  int sectionNum = -1, QPainter *painter = NULL, QQueue<paintInfo> *pageBuffer = NULL, bool clip = true)
        {
            if(painter != NULL && img != QImage())
            {
                painter->save();
                QPoint dimensions = pixelSize();

                if(clip && y + img.height() > dimensions.y() - botMarginPx()) //the height of the qquickitem!!
                {
                    //we have to break the image into two, and give the second half to the buffer
                    int extraPixels = y + img.height() - dimensions.y() + botMarginPx();

                    QImage croppedImg1 = img.copy(0,0                          ,img.width()   , img.height() - extraPixels);
                    QImage croppedImg2 = img.copy(0,img.height() - extraPixels ,img.width()   , extraPixels);

                     painter->drawImage(x ,y,croppedImg1);
                     pageBuffer->push_back(paintInfo(Image,x,topMarginPx() + 1,croppedImg2.width(),croppedImg2.height(),0,1,Qt::black, Qt::black, "", 0, 0, croppedImg2));  //keeping same x but makign new Y :D :D :D :D
                }
                else
                {
                    painter->drawImage(x,y,img);
                }

                painter->restore();
                //qDebug() << "drawImage ended";
            }
            else
            {
                //qDebug() << "Storing Image paint Event for later painting!";
                if(_noTransparencyInImages)
                    img = img.convertToFormat(QImage::Format_RGB32);

                if(sectionNum == -1)
                    sectionNum = _currentSection;

               getSectionPart(_sections[sectionNum], part).append(paintInfo(Image,x,y,img.width()/2,img.height()/2,0,1,Qt::black, Qt::black, "", 0, 0, img));
               update();   //should call paint!!!(NULL);
            }
        }
        QList<paintInfo>& getSectionPart(section &curSection, QString name)
        {
            name = name.toLower();
            if     (name == "body"  )  {  return curSection.body;         }
            else if(name == "header")  {  return curSection.header;       }
            else if(name == "footer")  {  return curSection.footer;       }
            else if(name == "lefter")  {  return curSection.lefter;       }
            else if(name == "righter") {  return curSection.righter;      }
            else                       {  return curSection.body;         }
        }


    protected :
        void paint(QPainter *painter)
        {
            if(_doPaint)
            {
                for(int i = 0; i <  _sections[_currentSection].body.length(); i++)
                {
                    paintInfo p = _sections[_currentSection].body[i];
                    switch(p.type)
                    {
                        case None   : break;
                        case TextML : drawMultiLineText(p.text, p.x, p.y, p.w, p.h, p.flags,              p.lineWidth, p.color, p.fillColor, "", -1, p.font, p.fontStyle, p.fontSize,  painter); break;
                        case Arc    : drawArc          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Chord  : drawChord        (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Ellipse: drawEllipse      (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Line   : drawLine         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Pie    : drawPie          (        p.x, p.y, p.w, p.h, p.startAngle, p.aLen, p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Point  : drawPoint        (        p.x, p.y,                                 p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Rect   : drawRect         (        p.x, p.y, p.w, p.h,                       p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Cell   : drawCell         (p.text, p.x, p.y, p.w, p.h, p.flags,              p.color, p.fillColor, p.lineWidth, painter, "", -1); break;
                        case Image  : drawImage        (        p.x, p.y ,                                p.img, "", -1,  painter); break;
                    }
                }
            }
        }

        Q_INVOKABLE void reset()
        {
            setRemoveImagesAfterFinalize(true);
            setDoPaint(false);
            _fontName        = "MS Shell Dlg 2";
            _fontStyle       = Normal;
            _fontPointSize   = 12;
            _sections.clear();
            _sections.append(section());
            setCurrentSection(0);
            setPgOrientation("Portrait");

            _maxW            = _maxH = 0;
            _noTransparencyInImages    = true;
            numSectionsChanged(0);
            setPageSize("AnsiA");
            setDPI(300);
            setTitle("untitled_section");
            setMargins(1,1,1,1);
            maintainAspectRatio();
            _pageNumberOnFooter = 0;
            _pageNum = 0;
        }



    private:
        bool                     _removeImagesAfterFinalize;
        bool                     _doPaint;
        bool                     _noTransparencyInImages;
        int                      _currentSection;
        int                      _fontPointSize, _dpi,  _maxW, _maxH;       //The originals! these should only change if the user explicitly wants these to change!!
        int                      _pageNumberOnFooter;
        int                      _pageNum;


        QString                  _title, _fontName;
        FontStyle                _fontStyle;    //our own happy little fontStyle
        QPageLayout::Orientation _pageOrientation;
        QMarginsF                _margins;
        QPageSize                _pageSize;

        QList<section>   _sections;
        QHash<QString,QPageSize::PageSizeId> _sizeMap;   //will make our lookups way faster!!

        bool setMargins(double left, double top, double right, double bottom)
        {
            _margins.setLeft(left);
            _margins.setTop(top);
            _margins.setRight(right);
            _margins.setBottom(bottom);
            return true;
        }
        bool setFont(const QString &newFontName, FontStyle style, const int &fontPointSize, QPainter &painter)
        {
            QFontDatabase fontDb;
            foreach(const QString &family, fontDb.families())
            {
                if(family == newFontName)       //if family is found
                {
                    bool match = false;
                    foreach(const QString &availableStyle, fontDb.styles(family))
                    {
                        if(availableStyle == fontStrFromEnum(style))
                        {
                            match = true;
                            break;
                        }
                    }

                    if(!match)
                        style = Normal;

                    _fontName      = newFontName;
                    _fontStyle     = style;
                    _fontPointSize = fontPointSize;

                    painter.setFont(fontDb.font(_fontName, fontStrFromEnum(_fontStyle), _fontPointSize));
                    return true;
                }
            }
            return false;
        }


        //This is to tell the painter how large it is by using _dpi and _pageSize (returns size based on landscape or portrait)
        QPoint pixelSize()
        {
            if(_pageOrientation == QPageLayout::Portrait)
                return QPoint(_pageSize.sizePixels(_dpi).width(), _pageSize.sizePixels(_dpi).height());
            return QPoint(_pageSize.sizePixels(_dpi).height(), _pageSize.sizePixels(_dpi).width());
        }       


        qreal topMarginPx()   { return _margins.top()    * _dpi;   }
        qreal botMarginPx()   { return _margins.bottom() * _dpi;   }
        qreal leftMarginPx()  { return _margins.left()   * _dpi;   }
        qreal rightMarginPx() { return _margins.right()  * _dpi;   }

        paintInfo convertToPdfRatio(paintInfo pi)
        {
            QPoint p = pixelSize();

            //we have width and height of this qquickitem, we have to use that to find the actual size
            double xMulti = p.x() / this->width();
            double yMulti = p.y() / this->height();

            pi.x *= xMulti ;
            pi.y *= yMulti ;
            pi.w *= xMulti;
            pi.h *= yMulti;


            if(pi.img != QImage() ) //if its not a null img!
            {
                pi.img = pi.img.scaledToWidth (pi.w);
                pi.img = pi.img.scaledToHeight(pi.h);
            }

            return pi;
        }

        void refreshSizeMaps()
        {
            _sizeMap["a0"]                     = QPageSize::A0               ;
            _sizeMap["cicero"]                 = QPageSize::A0               ;
            _sizeMap["a1"]                     = QPageSize::A1               ;
            _sizeMap["a2"]                     = QPageSize::A2               ;
            _sizeMap["a3"]                     = QPageSize::A3               ;
            _sizeMap["a3extra"]                = QPageSize::A3Extra          ;
            _sizeMap["a4"]                     = QPageSize::A4               ;
            _sizeMap["a4extra"]                = QPageSize::A4Extra          ;
            _sizeMap["a4plus"]                 = QPageSize::A4Plus           ;
            _sizeMap["a4small"]                = QPageSize::A4Small          ;
            _sizeMap["a5"]                     = QPageSize::A5               ;
            _sizeMap["a5extra"]                = QPageSize::A5Extra          ;
            _sizeMap["a6"]                     = QPageSize::A6               ;
            _sizeMap["a7"]                     = QPageSize::A7               ;
            _sizeMap["a8"]                     = QPageSize::A8               ;
            _sizeMap["a9"]                     = QPageSize::A9               ;

            _sizeMap["ansia"]                  = QPageSize::AnsiA            ;
            _sizeMap["letter"]                 = QPageSize::AnsiA            ;
            _sizeMap["ansib"]                  = QPageSize::AnsiB            ;
            _sizeMap["ledger"]                 = QPageSize::AnsiB            ;
            _sizeMap["ansic"]                  = QPageSize::AnsiC            ;
            _sizeMap["ansid"]                  = QPageSize::AnsiD            ;
            _sizeMap["ansie"]                  = QPageSize::AnsiE            ;

            _sizeMap["archa"]                  = QPageSize::ArchA            ;
            _sizeMap["archb"]                  = QPageSize::ArchB            ;
            _sizeMap["archc"]                  = QPageSize::ArchC            ;
            _sizeMap["archd"]                  = QPageSize::ArchD            ;
            _sizeMap["arche"]                  = QPageSize::ArchE            ;

            _sizeMap["b0"]                     = QPageSize::B0               ;
            _sizeMap["b1"]                     = QPageSize::B1               ;
            _sizeMap["b2"]                     = QPageSize::B2               ;
            _sizeMap["b3"]                     = QPageSize::B3               ;
            _sizeMap["b4"]                     = QPageSize::B4               ;
            _sizeMap["b5"]                     = QPageSize::B5               ;
            _sizeMap["b5extra"]                = QPageSize::B5Extra          ;
            _sizeMap["b6"]                     = QPageSize::B6               ;
            _sizeMap["b7"]                     = QPageSize::B7               ;
            _sizeMap["b8"]                     = QPageSize::B8               ;
            _sizeMap["b9"]                     = QPageSize::B9               ;
            _sizeMap["b10"]                    = QPageSize::B10              ;

            _sizeMap["doublepostcard"]         = QPageSize::DoublePostcard   ;

            _sizeMap["envelope9"]              = QPageSize::Envelope9        ;
            _sizeMap["envelope10"]             = QPageSize::Envelope10       ;
            _sizeMap["comm10e"]                = QPageSize::Comm10E         ;

            _sizeMap["envelope11"]             = QPageSize::Envelope11       ;
            _sizeMap["envelope12"]             = QPageSize::Envelope12       ;
            _sizeMap["envelope14"]             = QPageSize::Envelope14       ;
            _sizeMap["envelopeb4"]             = QPageSize::EnvelopeB4       ;
            _sizeMap["envelopeb5"]             = QPageSize::EnvelopeB5       ;
            _sizeMap["envelopeb6"]             = QPageSize::EnvelopeB6       ;
            _sizeMap["envelopec0"]             = QPageSize::EnvelopeC0       ;
            _sizeMap["envelopec1"]             = QPageSize::EnvelopeC1       ;
            _sizeMap["envelopec2"]             = QPageSize::EnvelopeC2       ;
            _sizeMap["envelopec3"]             = QPageSize::EnvelopeC3       ;
            _sizeMap["envelopec4"]             = QPageSize::EnvelopeC4       ;

            _sizeMap["envelopec5"]             = QPageSize::EnvelopeC5       ;
            _sizeMap["c5e"]                    = QPageSize::C5E            ;

            _sizeMap["envelopec6"]             = QPageSize::EnvelopeC6       ;
            _sizeMap["envelopec7"]             = QPageSize::EnvelopeC7       ;
            _sizeMap["envelopec65"]            = QPageSize::EnvelopeC65      ;
            _sizeMap["envelopechou3"]          = QPageSize::EnvelopeChou3    ;
            _sizeMap["envelopechou4"]          = QPageSize::EnvelopeChou4    ;

            _sizeMap["envelopedl"]             = QPageSize::EnvelopeDL       ;
            _sizeMap["dle"]                    = QPageSize::DLE            ;

            _sizeMap["envelopeinvite"]         = QPageSize::EnvelopeInvite   ;
            _sizeMap["envelopeitalian"]        = QPageSize::EnvelopeItalian  ;
            _sizeMap["envelopekaku2"]          = QPageSize::EnvelopeKaku2    ;
            _sizeMap["envelopekaku3"]          = QPageSize::EnvelopeKaku3    ;
            _sizeMap["envelopemonarch"]        = QPageSize::EnvelopeMonarch  ;
            _sizeMap["envelopepersonal"]       = QPageSize::EnvelopePersonal ;
            _sizeMap["envelopeprc1"]           = QPageSize::EnvelopePrc1     ;
            _sizeMap["envelopeprc2"]           = QPageSize::EnvelopePrc2     ;
            _sizeMap["envelopeprc3"]           = QPageSize::EnvelopePrc3     ;
            _sizeMap["envelopeprc4"]           = QPageSize::EnvelopePrc4     ;
            _sizeMap["envelopeprc5"]           = QPageSize::EnvelopePrc5     ;
            _sizeMap["envelopeprc6"]           = QPageSize::EnvelopePrc6     ;
            _sizeMap["envelopeprc7"]           = QPageSize::EnvelopePrc7     ;
            _sizeMap["envelopeprc8"]           = QPageSize::EnvelopePrc8     ;
            _sizeMap["envelopeprc9"]           = QPageSize::EnvelopePrc9     ;
            _sizeMap["envelopeprc10"]          = QPageSize::EnvelopePrc10    ;
            _sizeMap["envelopeyou4"]           = QPageSize::EnvelopeYou4     ;

            _sizeMap["executive"]              = QPageSize::Executive        ;
            _sizeMap["executivestandard"]      = QPageSize::ExecutiveStandard;

            _sizeMap["fanfoldgerman"]          = QPageSize::FanFoldGerman    ;
            _sizeMap["fanfoldgermanlegal"]     = QPageSize::FanFoldGermanLegal;
            _sizeMap["fanfoldus"]              = QPageSize::FanFoldUS        ;
            _sizeMap["folio"]                  = QPageSize::Folio            ;

            _sizeMap["imperial7x9"]            = QPageSize::Imperial7x9      ;
            _sizeMap["imperial8x10"]           = QPageSize::Imperial8x10     ;
            _sizeMap["imperial9x11"]           = QPageSize::Imperial9x11     ;
            _sizeMap["imperial9x12"]           = QPageSize::Imperial9x12     ;
            _sizeMap["imperial10x11"]          = QPageSize::Imperial10x11    ;
            _sizeMap["imperial10x13"]          = QPageSize::Imperial10x13    ;
            _sizeMap["imperial10x14"]          = QPageSize::Imperial10x14    ;
            _sizeMap["imperial12x11"]          = QPageSize::Imperial12x11    ;
            _sizeMap["imperial15x11"]          = QPageSize::Imperial15x11    ;

            _sizeMap["jisb0"]                  = QPageSize::JisB0            ;
            _sizeMap["jisb1"]                  = QPageSize::JisB1            ;
            _sizeMap["jisb2"]                  = QPageSize::JisB2            ;
            _sizeMap["jisb3"]                  = QPageSize::JisB3            ;
            _sizeMap["jisb4"]                  = QPageSize::JisB4            ;
            _sizeMap["jisb5"]                  = QPageSize::JisB5            ;
            _sizeMap["jisb6"]                  = QPageSize::JisB6            ;
            _sizeMap["jisb7"]                  = QPageSize::JisB7            ;
            _sizeMap["jisb8"]                  = QPageSize::JisB8            ;
            _sizeMap["jisb9"]                  = QPageSize::JisB9            ;
            _sizeMap["jisb10"]                 = QPageSize::JisB10           ;

            _sizeMap["ledger / ansib"]         = QPageSize::Ledger           ;
            _sizeMap["legal"]                  = QPageSize::Legal            ;
            _sizeMap["legalextra"]             = QPageSize::LegalExtra       ;

            _sizeMap["letterextra"]            = QPageSize::LetterExtra      ;
            _sizeMap["letterplus"]             = QPageSize::LetterPlus       ;
            _sizeMap["lettersmall"]            = QPageSize::LetterSmall      ;

            _sizeMap["note"]                   = QPageSize::Note             ;

            _sizeMap["postcard"]               = QPageSize::Postcard         ;
            _sizeMap["prc16k"]                 = QPageSize::Prc16K           ;
            _sizeMap["prc32k"]                 = QPageSize::Prc32K           ;
            _sizeMap["prc32kbig"]              = QPageSize::Prc32KBig        ;

            _sizeMap["quarto"]                 = QPageSize::Quarto           ;

            _sizeMap["statement"]              = QPageSize::Statement        ;
            _sizeMap["supera"]                 = QPageSize::SuperA           ;
            _sizeMap["superb"]                 = QPageSize::SuperB           ;

            _sizeMap["tabloid"]                = QPageSize::Tabloid          ;
            _sizeMap["tabloidextra"]           = QPageSize::TabloidExtra     ;
        }        


        QString fontStrFromEnum(FontStyle style)
        {
            switch(style)
            {
                case Bold           : return "Bold";
                case Bold_Italic    : return "Bold_Italic";
                case Italic         : return "Italic";
                default             : return "Normal";      //handles the normal case!!
            }
        }


        int gcd (int a, int b )
        {
          int c;
          while ( a != 0 )
          {
             c = a;
             a = b%a;
             b = c;
          }
          return b;
        }




};


#endif // PDFWRITER

