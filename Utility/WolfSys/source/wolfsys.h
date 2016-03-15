#ifndef WOLFSYS_H
#define WOLFSYS_H

#include <QObject>
#include "zSystem.h"
#include <QStringList>
#include <vector>

using namespace std;
class WolfSys : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(WolfSys)

    zSystem sys;

private:
    QStringList getQStringList(const vector<string> &vec)
    {
        QStringList list;
        for(int i = 0; i < vec.size(); ++i)
        {
            QString line = line.fromStdString(vec[i]);
            list.append(line);
        }
        return list;
    }

    QList<int> getQIntList(const vector<int> &vec)
    {
        QList<int> list;
        for(int i = 0; i < vec.size(); ++i)
            list.append(vec[i]);
        return list;
    }


public:
    WolfSys(QObject *parent = 0) : QObject(parent)
    {
        // By default, QQuickItem does not draw anything. If you subclass
        // QQuickItem to create a visual item, you will need to uncomment the
        // following line and re-implement updatePaintNode()

        // setFlag(ItemHasContents, true);

    }
    ~WolfSys() {}



public slots:
    void writeFile(QString fileName, QString text)  {  sys.writeFile(fileName.toStdString(), text.toStdString());  }

    QStringList readFile(QString fileName)                         { return getQStringList(sys.readFile(fileName.toStdString()));                                         }
    QStringList filesInFolder(QString path , QString extension)    { return  getQStringList(sys.getFilesInFolder(path.toStdString(),1,extension.toStdString().c_str()));  }
    QStringList getfolders(QString path)                           { return getQStringList(sys.getFoldersInDirectory(path.toStdString()));                                }

    bool     folderExists(QString path)           {  return sys.folderExists(path.toStdString());          }
    void     createFolder(QString dir)            {  sys.createFolder(dir.toStdString());                  }
    void     copyFile(QString dest, QString src)  {  sys.copyfile(dest.toStdString(),src.toStdString());   }
    void     shellCmd(QString cmd)                {  sys.systemCmd(cmd.toStdString());                     }
    void     runBinary(QString path)              {  sys.runBinary(path.toStdString());                    }
    string     deleteFile(QString filePath)       {  return sys.del(filePath.toStdString());               }
    QList<int>     getAvailableComPorts()         {  return getQIntList(sys.getAvailableComPorts());       }
    bool     isProcessRunning(QString procName)   {  return sys.isProcessRunning(procName.toStdString());  }
    void     killProcess(QString procName)        {  sys.killProcess(procName.toStdString());              }
    bool     isWindowOpen(QString winName)        {  return sys.isWindowOpen(winName.toStdString());       }

    void     shutDown() { sys.shutDown();}
    void     restart()  { sys.restart(); }
    void     logOff()   { sys.logOff();  }
};

#endif // WOLFSYS_H

