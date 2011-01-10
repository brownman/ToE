`
window.onDocumentMouseDown = function( event ) {
  event.preventDefault();
  event.stopPropagation();

  switch ( event.button ) {

    case 0: moveForward = true; break;
    case 2: moveBackward = true; break;

  }
}

window.onDocumentMouseUp = function( event ) {
  event.preventDefault();
  event.stopPropagation();

  switch ( event.button ) {
    case 0: moveForward = false; break;
    case 2: moveBackward = false; break;
  }
}

window.onDocumentMouseMove = function(event) {
  mouseX = event.clientX - windowHalfX;
  mouseY = event.clientY - windowHalfY;
}

window.onDocumentKeyDown = function( event ) {
  switch( event.keyCode ) {
    case 38: /*up*/
    case 87: /*W*/ moveForward = true; break;

    case 37: /*left*/
    case 65: /*A*/ moveLeft = true; break;

    case 40: /*down*/
    case 83: /*S*/ moveBackward = true; break;

    case 39: /*right*/
    case 68: /*D*/ moveRight = true; break;
  }
}

window.onDocumentKeyUp = function( event ) {
  switch( event.keyCode ) {
    case 38: /*up*/
    case 87: /*W*/ moveForward = false; break;

    case 37: /*left*/
    case 65: /*A*/ moveLeft = false; break;

    case 40: /*down*/
    case 83: /*S*/ moveBackward = false; break;

    case 39: /*right*/
    case 68: /*D*/ moveRight = false; break;
  }
}
`