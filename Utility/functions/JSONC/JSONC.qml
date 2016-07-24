import "JSONC.js" as J
import QtQuick 2.5

pragma Singleton
QtObject {
    function compress(object)         { return J.compress(object);        }
    function pack(object)             { return J.pack(object);            }
    function decompress(object)       { return J.decompress(object)       }
    function unpack(obj)              { return J.unpack(obj);             }
    function packAndCompress(object)  { return J.pack(object,true);       }
    function unpackAndDecompress(obj) { return J.unpack(obj,true);        }



}
