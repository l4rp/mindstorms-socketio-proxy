http = require 'http'
fs = require 'fs'

Nxt = require("mindstorms_bluetooth").Nxt;

nxt = new Nxt("/dev/tty.NXT-DevB")
nxt.play_tone(440, 1000)

BASE = "#{process.env['HOME']}/Dropbox/L4RP/"
requestHandler = (req, res) ->
  res.writeHead 200
  path = decodeURI req.url
  if /\.\./.test path
    console.log "ATTEMPT: #{path} (#{req.connection.remoteAddress})"
    res.writeHead 404
    res.end("Nice try.")
  filename = "#{BASE}#{path}"
  fs.realpath filename, (err, path) ->
    if err or path.substr(0,BASE.length) isnt BASE
      res.writeHead 404
      res.end "File Not Found!"
    else
      fs.readFile filename, (err, data) ->
        if err
          res.writeHead 500
          res.end "ERROR OCCURRED!"
        else
          res.writeHead 200
          res.end data
  #fs.readFile filename
  #res.end "HELLO! #{filename}"

server = http.createServer requestHandler
io = require('socket.io').listen(server)
io.set 'log level', 1
server.listen 8080

functions = (key for key of nxt when typeof nxt[key] is 'function' and key.match /^[a-z_]+$/)
console.log "Exporting functions: #{functions.join(", ")}"

io.sockets.on 'connection', (socket) ->
  socket.emit 'welcome'

  for func in functions
    do (func) ->
      socket.on func, (args...) ->
        console.log func, args.join(",")
        nxt[func].apply(nxt, args)
