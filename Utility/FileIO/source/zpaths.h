#ifndef ZPATHS
#define ZPATHS

#include <QStandardPaths>
#include <QQuickItem>
#include <QString>
#include <QDebug>
#include <QDir>
#include <QList>

using namespace std;
struct pathItem {
    QString dispName;
    QString path;

    pathItem(QString d, QString p) : dispName(d) , path(p) {}
};


class ZPaths : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString desktop               READ desktop             NOTIFY pathsChanged)
    Q_PROPERTY(QString documents             READ documents           NOTIFY pathsChanged)
    Q_PROPERTY(QString fonts                 READ fonts               NOTIFY pathsChanged)
    Q_PROPERTY(QString applications          READ applications        NOTIFY pathsChanged)
    Q_PROPERTY(QString music                 READ music               NOTIFY pathsChanged)
    Q_PROPERTY(QString movies                READ movies              NOTIFY pathsChanged)
    Q_PROPERTY(QString pictures              READ pictures            NOTIFY pathsChanged)
    Q_PROPERTY(QString temp                  READ temp                NOTIFY pathsChanged)
    Q_PROPERTY(QString home                  READ home                NOTIFY pathsChanged)
    Q_PROPERTY(QString data                  READ data                NOTIFY pathsChanged)
    Q_PROPERTY(QString cache                 READ cache               NOTIFY pathsChanged)
    Q_PROPERTY(QString generic_cache         READ generic_cache       NOTIFY pathsChanged)
    Q_PROPERTY(QString generic_data          READ generic_data        NOTIFY pathsChanged)
    Q_PROPERTY(QString runtime               READ runtime             NOTIFY pathsChanged)
    Q_PROPERTY(QString config                READ config              NOTIFY pathsChanged)
    Q_PROPERTY(QString download              READ download            NOTIFY pathsChanged)
    Q_PROPERTY(QString generic_config        READ generic_config      NOTIFY pathsChanged)
    Q_PROPERTY(QString appData               READ appData             NOTIFY pathsChanged)
    Q_PROPERTY(QString appLocalData          READ appLocalData        NOTIFY pathsChanged)
    Q_PROPERTY(QString app_config   		 READ app_config   		  NOTIFY pathsChanged)
    Q_PROPERTY(QString currentPath   		 READ currentPath 		  NOTIFY pathsChanged)


public:
    ZPaths(QObject *parent = 0) : QObject(parent) {
        _desktop             = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
        _documents           = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        _fonts               = QStandardPaths::writableLocation(QStandardPaths::FontsLocation);
        _applications        = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
        _music               = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
        _movies              = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
        _pictures            = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
        _temp                = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
        _home                = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
        _data                = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        _cache               = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
        _generic_cache       = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation);
        _generic_data        = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
        _runtime             = QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation);
        _config              = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        _download            = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        _generic_config      = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation);

        #if QT_VERSION > QT_VERSION_CHECK(5, 5, 0)
            _appData             = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
            _appLocalData        = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
            _app_config   		 = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        #endif
        _currentPath         = QDir::currentPath();

//        printPaths();
        emit pathsChanged();
    }
    ~ZPaths(){}

    QString desktop          () { return _desktop          ;  }
    QString documents        () { return _documents        ;  }
    QString fonts            () { return _fonts            ;  }
    QString applications     () { return _applications     ;  }
    QString music            () { return _music            ;  }
    QString movies           () { return _movies           ;  }
    QString pictures         () { return _pictures         ;  }
    QString temp             () { return _temp             ;  }
    QString home             () { return _home             ;  }
    QString data             () { return _data             ;  }
    QString cache            () { return _cache            ;  }
    QString generic_cache    () { return _generic_cache    ;  }
    QString generic_data     () { return _generic_data     ;  }
    QString runtime          () { return _runtime          ;  }
    QString config           () { return _config           ;  }
    QString download         () { return _download         ;  }
    QString generic_config   () { return _generic_config   ;  }
    QString appData          () { return _appData          ;  }
    QString appLocalData     () { return _appLocalData     ;  }
    QString app_config   	 () { return _app_config   	   ;  }
    QString currentPath    	 () { return _currentPath 	   ;  }


    Q_INVOKABLE void printPaths(){
        qDebug() << "desktop       " <<   _desktop         ;
        qDebug() << "documents     " <<   _documents       ;
        qDebug() << "fonts         " <<   _fonts           ;
        qDebug() << "applications  " <<   _applications    ;
        qDebug() << "music         " <<   _music           ;
        qDebug() << "movies        " <<   _movies          ;
        qDebug() << "pictures      " <<   _pictures        ;
        qDebug() << "temp          " <<   _temp            ;
        qDebug() << "home          " <<   _home            ;
        qDebug() << "data          " <<   _data            ;
        qDebug() << "cache         " <<   _cache           ;
        qDebug() << "generic_cache " <<   _generic_cache   ;
        qDebug() << "generic_data  " <<   _generic_data    ;
        qDebug() << "runtime       " <<   _runtime         ;
        qDebug() << "config        " <<   _config          ;
        qDebug() << "download      " <<   _download        ;
        qDebug() << "generic_config" <<   _generic_config  ;
        qDebug() << "appData       " <<   _appData         ;
        qDebug() << "appLocalData  " <<   _appLocalData    ;
        qDebug() << "app_config    " <<	  _app_config      ;
        qDebug() << "currentPath   " <<	  _currentPath     ;
    }

    QList<pathItem> pathList() {
        QList<pathItem> list;

        list.append(pathItem("desktop"       , _desktop        ));
        list.append(pathItem("documents"     , _documents      ));
        list.append(pathItem("fonts"         , _fonts          ));
        list.append(pathItem("applications"  , _applications   ));
        list.append(pathItem("music"         , _music          ));
        list.append(pathItem("movies"        , _movies         ));
        list.append(pathItem("pictures"      , _pictures       ));
        list.append(pathItem("temp"          , _temp           ));
        list.append(pathItem("home"          , _home           ));
        list.append(pathItem("data"          , _data           ));
        list.append(pathItem("cache"         , _cache          ));
        list.append(pathItem("generic_cache" , _generic_cache  ));
        list.append(pathItem("generic_data"  , _generic_data   ));
        list.append(pathItem("runtime"       , _runtime        ));
        list.append(pathItem("config"        , _config         ));
        list.append(pathItem("download"      , _download       ));
        list.append(pathItem("generic_config", _generic_config ));
        list.append(pathItem("appData"       , _appData        ));
        list.append(pathItem("appLocalData"  , _appLocalData   ));
        list.append(pathItem("app_config"    , _app_config     ));
        list.append(pathItem("currentPath"   , _currentPath    ));
        return list;
    }


signals:
    void pathsChanged();

private:
    QString _desktop;
    QString _documents;
    QString _fonts;
    QString _applications;
    QString _music;
    QString _movies;
    QString _pictures;
    QString _temp;
    QString _home;
    QString _data;
    QString _cache;
    QString _generic_cache;
    QString _generic_data;
    QString _runtime;
    QString _config;
    QString _download;
    QString _generic_config;
    QString _appData;
    QString _appLocalData;
    QString _app_config;
    QString _currentPath;


};



#endif // ZPATHS

