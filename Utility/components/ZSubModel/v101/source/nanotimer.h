#ifndef NANOTIMER
#define NANOTIMER

#include <chrono>
#include <QString>
#include <QDebug>

struct nanoTimer{
    typedef std::chrono::nanoseconds ns;
    typedef std::chrono::high_resolution_clock sysClock;
    typedef std::chrono::time_point<sysClock,ns>  timeT;

    timeT _start;
    nanoTimer() { start(); }
    void start(QString message = ""){
        if(message != "")
            qDebug() << message;
        _start = std::chrono::time_point_cast<ns> (sysClock::now());
    }
    int stop(/*QString message = ""*/) {
        timeT stop = std::chrono::time_point_cast<ns> (sysClock::now());
        int d_actual = std::chrono::duration_cast<ns>(stop - _start).count();
//        qDebug() << message << d_actual << " ms";
        return d_actual;
   }
};

#endif
