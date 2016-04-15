#ifndef SUBMODEL_H
#define SUBMODEL_H

#include <QObject>
#include <QDebug>
#include <QAbstractListModel>
#include <QJSValue>
#include <QJSValueList>
#include <vector>
#include <QList>
#include <QStringList>
#include "mstimer.h"
#include "nanotimer.h"

#include <QQmlListProperty>

typedef QHash<int,QByteArray>         QRoles;
typedef QHashIterator<int,QByteArray> QRoleItr;

using namespace std;
class submodel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel *sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)
    Q_PROPERTY(QList<int> indexList READ indexList WRITE setIndexList NOTIFY indexListChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)


protected:
    QRoles roleNames() const {
        if(source == nullptr) {
            return QRoles();
        }
        return source->roleNames();
    }


public:
    submodel(QObject * parent = 0) : QAbstractListModel(parent) {
        source = NULL;
        nil = QJSValue::NullValue;
        clear() ;
     }


    Q_INVOKABLE QStringList getRoleNames() {
        QStringList r;
        QRoleItr i(roleNames());
        while(i.hasNext()) {
            i.next();
            r.append(QString(i.value()));
        }
        return r;
    }


    QVariant data(const QModelIndex &index, int role) const {
        if(!index.isValid() || source == nullptr || index.row() < 0 || index.row() > indices.length())
            return nil.toVariant();


        int relativeIdx = indices[index.row()];
        if(relativeIdx < 0 || relativeIdx > source->rowCount())
            return nil.toVariant();

        //have to constract a QModelIndex like a boss from our QList
        return source->data(source->index(relativeIdx),role);
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const {
        return source == nullptr ? 0 : indices.length() ;
    }

    Q_INVOKABLE QVariant get(int row){
        return (row < 0 || row > indices.length()) ? nil.toVariant() : sourceGet(indices[row]);
    }
    Q_INVOKABLE QVariant sourceGet(int row){
        nanoTimer n;

        if(source == nullptr || row < 0 || row > source->rowCount())
            return nil.toVariant();

        QVariantMap res;
        QModelIndex idx = source->index(row, 0);

        QRoleItr i(roleNames());
        while(i.hasNext()) {
            i.next();
            QVariant data = idx.data(i.key());
            res[i.value()] = data;
        }


        uint ns = n.stop();
        qDebug() << "submodel::sourceGet(" << row << ").time\tns: " << ns << "\tms:" << ns / 1000000 ;

        return res;
    }

    QAbstractListModel* sourceModel() { return source; }
    void setSourceModel(QObject *src){
        if(src != source) {
            disconnectSignals();

            source = reinterpret_cast<QAbstractListModel *>(src);
            if(source != nullptr) { //connect stuff
                connectSignals(source);
            }

            Q_EMIT sourceModelChanged();
        }
    }


    QList<int> indexList() {
        return indices;
    }
    void setIndexList(QList<int> intArr){
        safeList(intArr); //so everyuthing is kosher! i > 0  && i < rowCount of sourceModel
        indices = intArr;
        Q_EMIT indexListChanged();
        indexListSignals();
    }

    Q_INVOKABLE void clear() {
        indices.clear();
        emitClearSignals();
    }


signals :
    void sourceModelChanged();
    void countChanged(int);
    void indexListChanged();

    void source_rowsInserted(uint start, uint end, uint count);
    void source_rowsMoved(uint start, uint end, uint startEnd, uint destinationEnd);    //could be done here perhaps
    void source_rowsRemoved(uint start, uint end, uint count);
    void source_dataChanged(uint idx);
    void source_modelReset();



private:
    QAbstractListModel *source;     //the sourceModel
    QList<int> indices;             //indices that determine the subset of source
    QJSValue nil;                   //for ease of use mang!!


    //These are the connections (signals) we listen to from the source model!
    QMetaObject::Connection conn_rowsInserted;
    QMetaObject::Connection conn_rowsMoved;
    QMetaObject::Connection conn_rowsRemoved;
    QMetaObject::Connection conn_dataChanged;
    QMetaObject::Connection conn_modelReset;


    void connectSignals(QAbstractListModel *src) {
        conn_rowsInserted = connect(src, &QAbstractListModel::rowsInserted, this, &submodel::__rowsInserted);
        conn_rowsMoved    = connect(src, &QAbstractListModel::rowsMoved   , this, &submodel::__rowsMoved   );
        conn_rowsRemoved  = connect(src, &QAbstractListModel::rowsRemoved , this, &submodel::__rowsRemoved );
        conn_dataChanged  = connect(src, &QAbstractListModel::dataChanged , this, &submodel::__dataChanged );
        conn_modelReset   = connect(src, &QAbstractListModel::modelReset  , this, &submodel::__modelReset  );
    }

    void __rowsInserted(const QModelIndex &parent, int first, int last){
        qDebug() << parent.row() << " " << first << " " << last;
    }
    void __rowsMoved(const QModelIndex &parent, int start, int end, const QModelIndex &destination, int row) {

    }
    void __rowsRemoved(const QModelIndex &parent , int first, int last) {

    }
    void __dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>()) {

    }
    void __modelReset() {

    }



    void disconnectSignals() {
        disconnect(conn_rowsInserted);
        disconnect(conn_rowsMoved);
        disconnect(conn_rowsRemoved);
        disconnect(conn_dataChanged);
        disconnect(conn_modelReset);
    }
    void emitCountChanged(int count){
        if(rowCount() != count)
            emit countChanged(count);
    }
    void safeList(QList<int> &indices){
        if(source == nullptr){
            indices.clear();
        }

        for(int i = indices.length() ; i >= 0; --i) {
            int row = indices[i];
            if(row < 0 || row > source->rowCount())
                indices.removeAt(i);
        }
    }
    void emitClearSignals() {
        Q_EMIT beginResetModel();
        emitCountChanged(rowCount());
        Q_EMIT endResetModel();
    }
    void indexListSignals(){
        emitClearSignals();
        if(source == nullptr)
            return;

        for(int i = 0; i < indices.length(); ++i) {
            int row = indices[i];
            if(row > -1 && row < source->rowCount()){
                beginInsertRows(QModelIndex(), i, i);
                endInsertRows();
            }
        }
        emitCountChanged(rowCount());
//        Q_EMIT dataChanged(source->index(0), source->index(1)  );
    }







};


#endif // SUBMODEL_H
