path = require 'path'

dnode = require 'dnode'

# {EventEmitter} = require 'events'
# emitter = new EventEmitter

clients = new Object

connect = require 'connect'
server = connect.createServer()
server.use connect.staticProvider(path.join(__dirname, '/public'))

###
CLIENT
###

handler = (client, con) ->
  @log = (data, cb) ->
    console.log data
  
  return null

node = dnode handler
node.listen server

server.listen 8080

console.log 'http://localhost:8080/'

###
PHYSICS
###

node = dnode (client, connection) ->  
  @log = (data, cb) ->
    console.log data
  @init = ->
    client.cube()

  return

node.listen 6060

console.log 'telnet://localhost:6060/'