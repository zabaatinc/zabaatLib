import QtQuick 2.0
import Zabaat.Misc.FileDownloader 1.0
ListModel
{
    id : active
    signal downloadFinished(string url, string fileName);
    property var map : ({})
    property ZFileDownloader zfd : ZFileDownloader
    {
        onDownloadProgressChanged: {
            active.map[url].received = bytesReceived
            active.map[url].total    = bytesTotal
            active.map[url].elapsed  = elapsed
            active.map[url].speed    = speed
        }
        onDownloadFailed: {
            var oldElem = active.map[url]
            if(oldElem)
                oldElem.status = 'fail'
        }
        onDownloadSaved: {
            var oldElem = active.map[url]
            if(oldElem)
            {
                oldElem.status = 'success'
                active.downloadFinished(url,fileName)
            }
        }
    }


    function indexOf(url)
    {
        for(var i = 0; i < count; i++)
        {
            if(active.get(i).url && active.get(i).url == url)
                return i
        }
        return -1
    }

    function download(obj)
    {
        zfd.download(obj)
        if(typeof obj === 'string')
        {
            active.append({url: obj, received : 0, total : 0, elapsed : 0, speed : "", status : "downloading"})
            active.map[obj] = active.get(active.count - 1)
        }
        else if(obj.length > 0)
        {
            for(var o in obj)
            {
                active.append({url: obj[o], received : 0, total : 0, elapsed : 0, speed : "", status : "downloading"})
                active.map[obj[o]] = active.get(active.count - 1)
            }
        }
    }
}



