$(document).ready ->
  window.direction = new THREE.Vector3
  
  window.moveForward = false
  window.moveBackward = false
  window.moveLeft = false
  window.moveRight = false
  
  window.mouseX = 0
  window.mouseY = 0
  
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

  document.addEventListener 'mousedown', onDocumentMouseDown, false
  document.addEventListener 'mouseup',   onDocumentMouseUp,   false
  document.addEventListener 'mousemove', onDocumentMouseMove, false

  document.addEventListener 'contextmenu', ((event) -> event.preventDefault()), false

  document.addEventListener 'keydown', onDocumentKeyDown, false
  document.addEventListener 'keyup',   onDocumentKeyUp,   false

  document.getElementById('bao').addEventListener  'click', (-> mat.map = m_ao.map),  false
  document.getElementById('baot').addEventListener 'click', (-> mat.map = m_aot.map), false
  document.getElementById('bt').addEventListener   'click', (-> mat.map = m_t.map),   false