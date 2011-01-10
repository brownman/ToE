doctype 5
html lang: 'en', ->
  head ->
    meta charset: 'utf-8'
    meta 'http-equiv': 'Content-Type', content: 'text/html; charset: utf-8'
    title 'Theory of Everything'
    
    # styles
    link type: 'text/css', rel: 'stylesheet/less', href: '/less/master.less'
    
    # deps
    script type: 'text/javascript', src: '/vendor/cloudhead/less.js/dist/less-1.0.40.js'
    script src: 'http://code.jquery.com/jquery-1.4.4.js', type: 'text/javascript'
    script src: '/dnode.js', type: 'text/javascript'
    script src: '/vendor/jashkenas/coffee-script/extras/coffee-script.js', type: 'text/javascript'
    
    # three.js
    script type: 'text/javascript', src: '/vendor/mrdoob/three.js/examples/js/Stats.js'
    script type: 'text/javascript', src: '/vendor/mrdoob/three.js/examples/js/ImprovedNoise.js'
    script type: 'text/javascript', src: '/vendor/mrdoob/three.js/build/Three.js'
    script type: 'text/javascript', src: '/vendor/mrdoob/three.js/src/extras/GeometryUtils.js'
    script type: 'text/javascript', src: '/vendor/mrdoob/three.js/src/extras/primitives/Cube.js'
    
    # client
    script src: '/require.coffee', type: 'text/coffeescript'
    
    script src: '/terrain.coffee', type: 'text/coffeescript'
    script src: '/input.coffee', type: 'text/coffeescript'
    script src: '/client.coffee', type: 'text/coffeescript'

  body ->
    div id: 'container', -> 'Generating world...'
    
    div id: 'info', ->
      button id: 'bt', -> 'texture'
      button id: 'bao', -> 'ao'
      button id: 'baot', -> 'texture + ao'