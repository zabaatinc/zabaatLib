var port = 1337;

var fs = require("fs")
var warPeace = fs.readFileSync("./jawa.jpg")
var io = require('socket.io').listen(port);
console.log("Listening on port " + port);

/* Socket.IO events */
io.on("connection", function(socket){
    console.log("new connection", warPeace.length);
	
	var derpObj = JSON.stringify({name :"derp", likes : "herps"});
	
	var buf = new Buffer(warPeace);
	socket.emit("message",buf);
	
	
    socket.on('test_text',function()
    {
        console.log("test text event received.");
    });

    socket.on('test_binary',function()
    {
       var args =Array.prototype.slice.call(arguments);
      if(args[0] instanceof Buffer)
      {
        console.log("test binary event received,binary length:"+ args[0].length);
      }
    });

    socket.on('test ack',function()
    {
       var args =Array.prototype.slice.call(arguments);
      if('object' == typeof args[0])
      {
        console.log("test combo received,object:");
        console.log(JSON.stringify(args[0]));
      }
      if(args.length>1 && 'function' == typeof args[args.length - 1])
      {
        console.log('need ack for test combo');
        var fn = args[args.length - 1];
        fn('Got bin length:' + args[0].bin.length);//invoke ack callback function.
      }
    });
	
	
	

  });