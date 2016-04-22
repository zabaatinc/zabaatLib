#ifndef SUBMODEL_H
#define SUBMODEL_H

#include <QObject>
#include <QDebug>
//#include <QAbstractListModel>
#include <QJSValue>
#include <QJSValueList>
#include <vector>
#include <QList>
#include <QStringList>
#include "mstimer.h"
#include "nanotimer.h"
#include <QtQml/private/qqmllistmodel_p.h>    //dont think this helps since we dont actually want to copy

typedef QHash<int,QByteArray>         QRoles;
typedef QHashIterator<int,QByteArray> QRoleItr;

using namespace std;
class submodel : public QQmlListModel {
    Q_OBJECT
    Q_PROPERTY(QQmlListModel *sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)
    Q_PROPERTY(QList<int> indexList READ indexList WRITE setIndexList NOTIFY indexListChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool readOnly READ readOnly WRITE setReadOnly NOTIFY readOnlyChanged)


protected:
    QRoles roleNames() const {
        if(source == nullptr) {
            return QRoles();
        }

        return source->roleNames();
    }


public:
    submodel(QObject * parent = 0) : QQmlListModel(parent) {
        m_readOnly = true;
        source = NULL;
        nil = QJSValue::NullValue;
        clear() ;
     }

    //METHODS WE MUST PROVIDE!!
    QModelIndex index(int row, int column, const QModelIndex &parent) const
    {
        if(source == nullptr || row < 0 || row > indices.length())
            return QModelIndex();
        return source->index(indices[row],column,parent);
    }

    QVariant data(int index, int role) const {
        if(source == nullptr || index < 0 || index > indices.length())
            return nil.toVariant();

        int relativeIdx = indices[index];
        if(relativeIdx < 0 || relativeIdx > source->count())
            return nil.toVariant();

        return source->data(index,role);
    }
    QVariant data(const QModelIndex &index, int role) const {
        if(!index.isValid() || source == nullptr || index.row() < 0 || index.row() > indices.length())
            return nil.toVariant();


        int relativeIdx = indices[index.row()];
        if(relativeIdx < 0 || relativeIdx > source->count())
            return nil.toVariant();

        //have to constract a QModelIndex like a boss from our QList
        return source->data(relativeIdx,role);
    }
    int rowCount(const QModelIndex &parent = QModelIndex()) const {
        return source == nullptr ? 0 : indices.length() ;
    }

    bool readOnly(){ return m_readOnly; }
    void setReadOnly(bool val){
        if(val != m_readOnly){
            m_readOnly = val;
            Q_EMIT readOnlyChanged();
        }
    }


    QQmlListModel* sourceModel() { return source; }
    void setSourceModel(QObject *src){
        if(src != source) {
            disconnectSignals();

            beginResetModel();
            source = reinterpret_cast<QQmlListModel *>(src);
            if(source != nullptr) { //connect stuff
                connectSignals(source);
            }
            endResetModel();

            Q_EMIT sourceModelChanged();
        }
    }


    QList<int> indexList() {
        return indices;
    }
    void setIndexList(QList<int> intArr){
        safeList(intArr); //so everyuthing is kosher! i > 0  && i < rowCount of sourceModel

        //since we are going to overwrite this indexList, let's make sure we tell the view that we
        //don't need those delegated
        clear();

        indices = intArr;
        Q_EMIT indexListChanged();

        indexListSignals();
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
    Q_INVOKABLE QQmlV4Handle get(int row){
        if(row >= 0 && row < indices.length() && source != nullptr) {
            return sourceGet(indices[row]);
        }
        return QQmlListModel::get(row); //YAY, this will return undefined!!
    }
    Q_INVOKABLE QQmlV4Handle sourceGet(int row){
//        nanoTimer n;
//        if(source == nullptr || row < 0 || row > source->count())
//            return nil.toVariant();
        return source->get(row);

//        QVariantMap res;
//        QModelIndex idx = source->index(row, 0);

//        QRoleItr i(roleNames());
//        while(i.hasNext()) {
//            i.next();
//            QVariant data = idx.data(i.key());
//            res[i.value()] = data;
//        }


////        uint ns = n.stop();
////        qDebug() << "submodel::sourceGet(" << row << ").time\tns: " << ns << "\tms:" << ns / 1000000 ;

//        return res;
    }

    Q_INVOKABLE void set(int index, const QQmlV4Handle & h){
       if(m_readOnly)
            qWarning() << "submodel.h::set called w/o disabling readOnly";
       else if(index >= 0 && index < indices.length() && source != nullptr)
           source->set(indices[index] , h);

    }
    Q_INVOKABLE void insert(QQmlV4Function *args) {
        if(m_readOnly)
            qWarning() << "submodel.h::insert use insert on the sourceModel. not this";
        else if(source != nullptr){
            source->insert(args);
        }
    }
    Q_INVOKABLE void append(QQmlV4Function *args){
        if(m_readOnly)
            qWarning() << "submodel.h::append use append on the sourceModel. not this";
        else if(source != nullptr)
            source->append(args);
    }
    Q_INVOKABLE void remove(QQmlV4Function *args){
        if(m_readOnly)
            qWarning() << "submodel.h::remove use remove on the sourceModel. not this";
        else if(source != nullptr){
            source->remove(args);
        }
    }
    Q_INVOKABLE void setProperty(int index, const QString &property, const QVariant &value){
        if(m_readOnly)
            qWarning() << "submodel.h::setProperty use setProperty on the sourceModel. not this";
        else if(index >= 0 && index < indices.length() && source != nullptr) {
            source->setProperty(indices[index] , property , value);
        }
    }

    Q_INVOKABLE void addToIndexList(int idx) {
        if(source != nullptr && !indices.contains(idx) && idx >= 0 && idx < source->count()) {
            Q_EMIT beginInsertRows(QModelIndex(), indices.length(), indices.length());  //cause we will put it
            indices.append(idx);                                                         //at the end!
            Q_EMIT endInsertRows();
        }
    }
    Q_INVOKABLE void removeFromIndexList(int idx){
        int indexOf;
        if(-1 != (indexOf = indices.indexOf(idx))){
            Q_EMIT beginRemoveRows(QModelIndex(), indexOf, indexOf);
            indices.removeAt(indexOf);
            Q_EMIT endRemoveRows();
        }
    }
    Q_INVOKABLE void clear() {
        if(indices.length() > 0) {
            beginRemoveRows(QModelIndex(), 0, indices.length() - 1);
            endRemoveRows();
        }
        indices.clear();
        Q_EMIT countChanged(0);
        Q_EMIT indexListChanged();
    }


    Q_INVOKABLE void emitDataChanged(int start, int end, const QVector<int> &roles = QVector<int>()){
//        Q_EMIT dataChanged(index(start) ,index(end) , roles);
        Q_EMIT dataChanged(QQmlListModel::index(start,0,QModelIndex()), QQmlListModel::index(end,0,QModelIndex()), roles);
    }

//    Q_INVOKABLE uint getActualIndex(int idx) {
//        return indices.indexOf(idx);
//    }

    Q_INVOKABLE void move(uint from, uint to, uint n){
        if(n <= 0 || from==to)
            return;

        if(!moveIsLegal(from,to,n)){
            qWarning() << "submodel.h :: move out of range: " << n << " elements from " << from << " to " << to;
            return;
        }


        beginMoveRows(QModelIndex(), from, from + n - 1, QModelIndex(), to > from ? to + n : to);

        //do move operation!
//        qDebug() << "BEGIN MOVE OP[" << start << "-" << end << "] to " << to;
        int realFrom = from;
        int realTo = to;
        int realN = n;
//        qDebug() << "FIGURING OUT WHAT GON HAPPEN";
        if (from > to) {
            // Only move forwards - flip if backwards moving
            int tfrom = from;
            int tto = to;
            realFrom = tto;
            realTo = tto+n;
            realN = tfrom-tto;
        }

        QList<int> store;
//        qDebug () << "BEFORE " << indices;

//        qDebug() << "BEGIN LOOP 1";
        for(uint i = 0; i < (realTo-realFrom); ++i){
            store.append(indices[realFrom+realN+i]);
        }
//        qDebug() << "BEGIN LOOP 2";
        for(uint i = 0; i < realN; ++i){
            store.append(indices[realFrom+i]);
        }
//        qDebug() << "BEGIN LOOP 3";
        for(uint i = 0; i < store.length(); ++i){
            indices[realFrom+i] = store[i];
        }
//        qDebug() << "END " << indices;


        endMoveRows();
//        Q_EMIT endMoveRows();
    }

    Q_INVOKABLE int actualIdx(int idx){
        if(idx >= 0 && idx < indices.length()){
            return indices[idx];
        }
        return -1;
    }


signals :
    void sourceModelChanged();
    void countChanged(int);
    void indexListChanged();

    void source_rowsInserted(uint start, uint end, uint count);
    void source_dataChanged(uint idx, uint refIdx, QVector<int> roles);
    void source_rowsMoved();
    void source_rowsRemoved();

    void source_modelReset();
    void readOnlyChanged();


private:
    QQmlListModel *source;  //the sourceModel
    QList<int> indices;     //indices that determine the subset of source
    QJSValue   nil;         //for ease of use mang!!
    bool       m_readOnly;


    //These are the connections (signals) we listen to from the source model!
    QMetaObject::Connection conn_rowsInserted;
    QMetaObject::Connection conn_rowsMoved;
    QMetaObject::Connection conn_rowsRemoved;
    QMetaObject::Connection conn_dataChanged;
    QMetaObject::Connection conn_modelReset;






    bool moveIsLegal(uint from, uint to, uint n){
        return !(from+n > rowCount() || to+n > rowCount() || from < 0 || to < 0 || n < 0);
    }


    void connectSignals(QQmlListModel *src) {
        conn_rowsInserted = connect(src, &QQmlListModel::rowsInserted, this, &submodel::__rowsInserted);
        conn_rowsMoved    = connect(src, &QQmlListModel::rowsMoved   , this, &submodel::__rowsMoved   );
        conn_rowsRemoved  = connect(src, &QQmlListModel::rowsRemoved , this, &submodel::__rowsRemoved );
        conn_dataChanged  = connect(src, &QQmlListModel::dataChanged , this, &submodel::__dataChanged );
        conn_modelReset   = connect(src, &QQmlListModel::modelReset  , this, &submodel::__modelReset  );
    }
    void __rowsInserted(const QModelIndex &parent, int start, int end){
        //since we cant turn QVariant elems (from sourcemodel) into QJSValue here. We have to let JS handle this
        //and run its filter function.
        int count = end - start + 1;
        Q_EMIT source_rowsInserted(start,end,count);
    }
    void __rowsRemoved(const QModelIndex &parent , int start, int end) {
        int count = end - start + 1 ; //this is the amount of things that need it's indexes updated
        int r;
        for(int i = indices.length() -1; i >=0; --i){
            r = indices[i];
            if(r >= start && r <= end){
                Q_EMIT beginRemoveRows(QModelIndex(), i, i);
                indices.removeAt(i);
                Q_EMIT endRemoveRows();
            }
            else if(r > end){
                indices[i] -= count;
                //This has adjusted the indices to match? Shouldn't really have to trigger anything I think.
            }
        }


        Q_EMIT source_rowsRemoved();
    }
    void __dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>()) {
        //since we cant turn QVariant elems (from sourcemodel) into QJSValue here. We have to let JS handle this
        //and run its filter function.

//        qDebug() << topLeft.row() << "," << topLeft.column() << "::" << bottomRight.row() << "::" << bottomRight.column();
        int actualIdx = topLeft.row();
        int refIdx = -1;
        for(uint i = 0; i < indices.length(); ++i){
            if(indices[i] == actualIdx){
                refIdx = i;
                break;
            }
        }

        Q_EMIT source_dataChanged(actualIdx, refIdx, roles);
    }

//    void __dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>()) {
//        //since we cant turn QVariant elems (from sourcemodel) into QJSValue here. We have to let JS handle this
//        //and run its filter function.

////        qDebug() << topLeft.row() << "," << topLeft.column() << "::" << bottomRight.row() << "::" << bottomRight.column();
//        QVector<int> refList;
//        for(uint j = topLeft.row(); j <= bottomRight.row(); ++j){

//            int refIdx = -1;
//            for(uint i = 0; i < indices.length(); ++i){
//                if(indices[i] == j){
//                    refIdx = i;
//                    break;
//                }
//            }
//            refList.push_back(refIdx);
//        }

//        //TODO let's make sure that the refIndice is in descending order so they can be sorted???
////        qDebug() << topLeft.row() << " " << bottomRight.row() << " " << refList.length();
//        Q_EMIT source_dataChanged(topLeft.row(), bottomRight.row(), refList, roles);
//    }

    void __modelReset() {
        Q_EMIT source_modelReset();
    }

    void __rowsMoved(const QModelIndex &parent, int fromStart, int fromEnd, const QModelIndex &destination, int row) {
        int count = fromEnd - fromStart +1;
        int toStart, toEnd;
        if(row < fromStart){
            toStart = row;
        }
        else if(row > fromEnd){
            toStart = row - count;
        }
        toEnd  = toStart + count - 1;

        int i, r, dist;
        if(fromStart > toStart){    //original elements moved up!
            dist = fromStart - toStart;
            for(i = 0; i < indices.length(); ++i){
                r   = indices[i];
                if(r >= toStart && r <= fromEnd){   //only these things will be affected!!
                    if(r >= fromStart && r <= fromEnd){ //if its the stuff moving up
                        indices[i] = r - dist;
                    }
                    else {  //its the stuff moving down
                        indices[i] = r + count;
                    }
                }
            }
            //EMIT stuff?
        }
        else if(fromStart < toStart) {  //original elements were moved down!
            dist              = toStart - fromStart;
            int elemsInMiddle = toStart - fromEnd - 1;
            for(i = 0; i < indices.length(); ++i){
                r   = indices[i];
                if(r >= fromStart && r <= toEnd){
                    if(r >= fromStart && r <= fromEnd){ //is in from
                        indices[i] = r + dist;
                    }
                    else if(r >= toStart && r <= toEnd){ //is in the to SEction
                        indices[i] = r - dist + elemsInMiddle;
                    }
                    else {  //is in the middle
                        indices[i] = r - count;
                    }
                }
            }
            //EMIT stuff?  probably no.
        }

        Q_EMIT source_rowsMoved();

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

        for(int i = indices.length() - 1 ; i >= 0; --i) {
            int row = indices[i];
            if(row < 0 || row > source->count())
                indices.removeAt(i);
        }
    }

    void indexListSignals(){
        if(source == nullptr)
            return;

        for(int i = 0; i < indices.length(); ++i) {
            int row = indices[i];
            if(row > -1 && row < source->count()){
                beginInsertRows(QModelIndex(), i, i);
                endInsertRows();
            }
        }
        Q_EMIT countChanged(rowCount());
    }







};


#endif // SUBMODEL_H
