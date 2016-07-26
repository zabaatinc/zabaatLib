#ifndef MSTIMER
#define MSTIMER

#include <chrono>
#include <QString>
#include <QDebug>

struct msTimer{
    typedef std::chrono::milliseconds ms;
    typedef std::chrono::system_clock sysClock;
    typedef std::chrono::time_point<sysClock,ms>  timeT;

    timeT _start;

    msTimer() { start(); }
    void start(QString message = ""){
        if(message != "")
            qDebug() << message;
        _start = std::chrono::time_point_cast<ms> (sysClock::now());
    }
    int stop(/*QString message = ""*/) {
        timeT stop = std::chrono::time_point_cast<ms> (sysClock::now());
        int d_actual = std::chrono::duration_cast<ms>(stop - _start).count();
//        qDebug() << message << d_actual << " ms";
        return d_actual;
   }
};


#endif // MSTIMER

