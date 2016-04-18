import QtQuick 2.5
QtObject {
    property string url : "" //Qt.resolvedUrl("datasmall.txt")
    onUrlChanged : if(url !== "") {
                       console.time("fetchAndReady")
                       var res = logic.readJSONFile(url, function(msg) {
                           if(msg.data) {
                               model.append(msg.data);
                               console.timeEnd("fetchAndReady")
                           }
                           else {
                               console.timeEnd("fetchAndReady")
                               console.error("failed")
                           }
                           ready = true;
                       })
                   }

    property ListModel model   : ListModel {
        dynamicRoles : true
    }
    property bool ready : false //model.count > 0

	property QtObject __priv : QtObject {
		id : logic
//		property string url : "http://warehouse.imagishrimp.com:1338/tickets/list"

		
		function readFile(source, callback) {
			var xhr = new XMLHttpRequest;
			xhr.open("GET", source);
			xhr.onreadystatechange = function () {
				if (xhr.readyState === XMLHttpRequest.DONE && callback)
					callback(xhr.responseText)
			}
			xhr.send();
		}
		function readJSONFile(source, callback) {
			readFile(source, function(jsData) {
				try {
					var a = JSON.parse(jsData);
					if(callback)
						callback(a)
				}
				catch(e){
					console.log("readJSONFile error from", source, jsData)
				}
			})
		}
		

		
	
	
	}

}
