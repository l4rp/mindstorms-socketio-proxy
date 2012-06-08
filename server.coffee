http = require 'http'
fs = require 'fs'

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
server.listen 8080

io.sockets.on 'connection', (socket) ->
  socket.emit 'welcome'
