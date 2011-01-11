`
window.tick = function() {
  if ( moveForward )  camera.translateZ( - 15 );
  if ( moveBackward ) camera.translateZ( 15 );
  if ( moveLeft )     camera.translateX( - 15 );
  if ( moveRight )    camera.translateX( 15 );

  lon += mouseX * 0.005;
  lat -= mouseY * 0.005;

  lat = Math.max( - 85, Math.min( 85, lat ) );
  phi = ( 90 - lat ) * Math.PI / 180;
  theta = lon * Math.PI / 180;

  camera.target.position.x = 100 * Math.sin( phi ) * Math.cos( theta ) + camera.position.x;
  camera.target.position.y = 100 * Math.cos( phi ) + camera.position.y;
  camera.target.position.z = 100 * Math.sin( phi ) * Math.sin( theta ) + camera.position.z;

  renderer.render(scene, camera);
  stats.update();
}
`