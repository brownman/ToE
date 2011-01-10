Bullet = require 'bullet'

dnode = require 'dnode'

bullet = new Bullet.Bullet
console.log 'bullet', bullet

defaultCollisionConfiguration = new Bullet.DefaultCollisionConfiguration
console.log 'defaultCollisionConfiguration', defaultCollisionConfiguration

collisionDispatcher = new Bullet.CollisionDispatcher defaultCollisionConfiguration
console.log 'collisionDispatcher', collisionDispatcher

dbvtBroadphase = new Bullet.DbvtBroadphase
console.log 'dbvtBroadphase', dbvtBroadphase

sequentialImpulseConstraintSolver = new Bullet.SequentialImpulseConstraintSolver
console.log 'sequentialImpulseConstraintSolver', sequentialImpulseConstraintSolver

discreteDynamicsWorld = new Bullet.DiscreteDynamicsWorld collisionDispatcher, dbvtBroadphase, sequentialImpulseConstraintSolver, defaultCollisionConfiguration
console.log 'discreteDynamicsWorld', discreteDynamicsWorld

discreteDynamicsWorld.setGravity()

# # boxShape = new Bullet.BoxShape
# # console.log 'boxShape', boxShape

# # transform = new Bullet.Transform
# # console.log 'transform', transform

handler =
  cube: ->
    rigidBody = new Bullet.RigidBody
    console.log 'rigidBody', rigidBody
    discreteDynamicsWorld.addRigidBody rigidBody
  
console.log 'starting dnode'

node = dnode handler
node.connect 6060, (remote) ->
  console.log 'connected'
  remote.init()

# fps = 0
# 
# tick = ->
#   fps++
#   discreteDynamicsWorld.stepSimulation()
#   process.nextTick tick
# 
# process.nextTick ->
#   tick()
# 
# setInterval(->
#   console.log fps
#   # fps = 0
# , 1000)