window.onDocumentMouseDown = (event) ->
  event.preventDefault()
  event.stopPropagation()

  switch event.button
    when 0 then window.moveForward = true
    when 2 then window.moveBackward = true

window.onDocumentMouseUp = (event) ->
  event.preventDefault()
  event.stopPropagation()

  switch event.button
    when 0 then window.moveForward = false
    when 2 then window.moveBackward = false

window.onDocumentMouseMove = (event) ->
  window.mouseX = event.clientX - windowHalfX
  window.mouseY = event.clientY - windowHalfY

window.onDocumentKeyDown = (event) ->
  switch event.keyCode
    when 38, 87 then window.moveForward  = true
    when 37, 65 then window.moveLeft     = true
    when 40, 83 then window.moveBackward = true
    when 39, 68 then window.moveRight    = true

window.onDocumentKeyUp = (event) ->
  switch event.keyCode
    when 38, 87 then window.moveForward  = false
    when 37, 65 then window.moveLeft     = false
    when 40, 83 then window.moveBackward = false
    when 39, 68 then window.moveRight    = false