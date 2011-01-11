$(document).ready ->
  window.stats = stats = new Stats
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.top = '0px'
  document.body.appendChild stats.domElement