console.log 'client'

`
window.init = function() {
  window.fogExp2 = true;

  window.container = null;
  window.stats = null;

  window.camera = null;
  window.scene = null;
  window.renderer = null;

  window.mesh = null;

  window.worldWidth = 128;
  window.worldDepth = 128;
  window.worldHalfWidth = worldWidth / 2;
  window.worldHalfDepth = worldDepth / 2;
  window.data = window.generateHeight(worldWidth, worldDepth);

  window.mouseX = 0;
  window.mouseY = 0;
  window.lat = 0;
  window.lon = 0;
  window.phy = 0;
  window.theta = 0;

  window.direction = new THREE.Vector3();
  window.moveForward = false;
  window.moveBackward = false;
  window.moveLeft = false;
  window.moveRight = false;

  window.windowHalfX = window.innerWidth / 2;
  window.windowHalfY = window.innerHeight / 2;
  
  container = document.getElementById( 'container' );

  if( fogExp2 )
    camera = new THREE.Camera( 60, window.innerWidth / window.innerHeight, 1, 20000 );
  else
    camera = new THREE.Camera( 60, window.innerWidth / window.innerHeight, 1, 7500 );
    
  camera.target.position.z = - 100;

  camera.position.y = getY( worldHalfWidth, worldHalfDepth ) * 100 + 100;
  camera.target.position.y = camera.position.y;

  scene = new THREE.Scene();
  
  if( fogExp2 )
    scene.fog = new THREE.FogExp2( 0xffffff, 0.00025 );
  else
    scene.fog = new THREE.Fog( 0xffffff, - 1000, 7500 );

  var debug_texture = false,
    debug_numbers = false,
    debug_corner_colors = false,
    strength = 2,

    textures = { side:   '/vendor/mrdoob/three.js/examples/textures/minecraft/grass_dirt.png',
             top:    '/vendor/mrdoob/three.js/examples/textures/minecraft/grass.png',
             bottom: '/vendor/mrdoob/three.js/examples/textures/minecraft/dirt.png'
          },

    m_aot = generateMegamaterialAO( textures, strength, debug_texture, debug_numbers, debug_corner_colors ),
    m_ao  = generateMegamaterialAO( textures, strength, true, debug_numbers, debug_corner_colors ),

    m_t   = generateMegamaterialPlain( textures ),
    //m_d   = generateMegamaterialDebug(),

    mat   = generateMegamaterialAO( textures, strength, debug_texture, debug_numbers, debug_corner_colors ),

    materials = [ mat, mat, mat, mat, mat, mat ];

  var i, j, x, z, h, h2, uv,
    px, nx, pz, nz, sides,
    right, left, bottom, top,
    nright, nleft, nback, nfront,
    nleftup, nrightup, nbackup, nfrontup,
    nrb, nrf, nlb, nlf,
    nrbup, nrfup,
    face_px, face_nx, face_py, face_ny, face_pz, face_nz,
    ti, ri, li, bi, fi, ci, mi, mm, column, row,
    cube,

    unit = 1/16 * 0.95, padding = 1/16 * 0.025, p, s, t, hash, N = -1,

    // map of UV indices for faces of partially defined cubes

    uv_index_map = {
    0:  { px: N, nx: N, py: 0, ny: N, pz: N, nz: N },
    1:  { px: N, nx: N, py: 0, ny: N, pz: N, nz: 1 },
    2:  { px: N, nx: N, py: 0, ny: N, pz: 1, nz: N },
    3:  { px: N, nx: N, py: 0, ny: N, pz: 1, nz: 2 },
    4:  { px: N, nx: 0, py: 1, ny: N, pz: N, nz: N },
    5:  { px: N, nx: 0, py: 1, ny: N, pz: N, nz: 2 },
    6:  { px: N, nx: 0, py: 1, ny: N, pz: 2, nz: N },
    7:  { px: N, nx: 0, py: 1, ny: N, pz: 2, nz: 3 },
    8:  { px: 0, nx: N, py: 1, ny: N, pz: N, nz: N },
    9:  { px: 0, nx: N, py: 1, ny: N, pz: N, nz: 2 },
    10: { px: 0, nx: N, py: 1, ny: N, pz: 2, nz: N },
    11: { px: 0, nx: N, py: 1, ny: N, pz: 2, nz: 3 },
    12: { px: 0, nx: 1, py: 2, ny: N, pz: N, nz: N },
    13: { px: 0, nx: 1, py: 2, ny: N, pz: N, nz: 3 },
    14: { px: 0, nx: 1, py: 2, ny: N, pz: 3, nz: N },
    15: { px: 0, nx: 1, py: 2, ny: N, pz: 3, nz: 4 }
    },

    // all possible combinations of corners and sides
    // mapped to mixed tiles
    //  (including corners overlapping sides)
    //  (excluding corner alone and sides alone)

    // looks ugly, but allows to squeeze all
    // combinations for one texture into just 3 rows
    // instead of 16

    mixmap = {
    "1_1":  0,
    "1_3":  0,
    "1_9":  0,
    "1_11": 0,

    "1_4":  1,
    "1_6":  1,
    "1_12": 1,
    "1_14": 1,

    "2_2":  2,
    "2_3":  2,
    "2_6":  2,
    "2_7":  2,

    "2_8":  3,
    "2_9":  3,
    "2_12": 3,
    "2_13": 3,

    "4_1":  4,
    "4_5":  4,
    "4_9":  4,
    "4_13": 4,

    "4_2":  5,
    "4_6":  5,
    "4_10": 5,
    "4_14": 5,

    "8_4":  6,
    "8_5":  6,
    "8_6":  6,
    "8_7":  6,

    "8_8":  7,
    "8_9":  7,
    "8_10": 7,
    "8_11": 7,

    "1_5":  8,
    "1_7":  8,
    "1_13": 8,
    "1_15": 8,

    "2_10": 9,
    "2_11": 9,
    "2_14": 9,
    "2_15": 9,

    "4_3":  10,
    "4_7":  10,
    "4_11": 10,
    "4_15": 10,

    "8_12": 11,
    "8_13": 11,
    "8_14": 11,
    "8_15": 11,

    "5_1":  12,
    "5_3":  12,
    "5_7":  12,
    "5_9":  12,
    "5_11": 12,
    "5_13": 12,
    "5_15": 12,

    "6_2":  13,
    "6_3":  13,
    "6_6":  13,
    "6_7":  13,
    "6_10": 13,
    "6_11": 13,
    "6_14": 13,
    "6_15": 13,

    "9_4":  14,
    "9_5":  14,
    "9_6":  14,
    "9_7":  14,
    "9_12": 14,
    "9_13": 14,
    "9_14": 14,
    "9_15": 14,

    "10_8":  15,
    "10_9":  15,
    "10_10": 15,
    "10_11": 15,
    "10_12": 15,
    "10_13": 15,
    "10_14": 15,
    "10_15": 15
    },

    tilemap = {},

    top_row_corners = 0,
    top_row_mixed = 1,
    top_row_sides = 2,
    sides_row = 3,
    bottom_row = 4,

    geometry = new THREE.Geometry();


  // mapping from 256 possible corners + sides combinations
  // into 3 x 16 tiles

  for ( i = 0; i < 16; i++ ) {

    for ( j = 0; j < 16; j++ ) {

      mm = i + "_" + j;

      if ( i == 0 )
        row = top_row_corners;
      else if ( mixmap[ mm ] != undefined )
        row = top_row_mixed;
      else
        row = top_row_sides;

      tilemap[ mm ] = row;

    }

  }

  function setUVTile( face, s, t ) {

    var j, uv = cube.uvs[ face ];
    for ( j = 0; j < uv.length; j++ ) {

      uv[ j ].u += s * (unit+2*padding);
      uv[ j ].v += t * (unit+2*padding);

    }

  }

  for ( z = 0; z < worldDepth; z ++ ) {

    for ( x = 0; x < worldWidth; x ++ ) {

      h = getY( x, z );

      // direct neighbors

      h2 = getY( x - 1, z );
      nleft = h2 == h || h2 == h + 1;

      h2 = getY( x + 1, z );
      nright = h2 == h || h2 == h + 1;

      h2 = getY( x, z + 1 );
      nback = h2 == h || h2 == h + 1;

      h2 = getY( x, z - 1 );
      nfront = h2 == h || h2 == h + 1;

      // corner neighbors

      nrb = getY( x - 1, z + 1 ) == h && x > 0 && z < worldDepth - 1 ? 1 : 0;
      nrf = getY( x - 1, z - 1 ) == h && x > 0 && z > 0 ? 1 : 0;

      nlb = getY( x + 1, z + 1 ) == h && x < worldWidth - 1 && z < worldDepth - 1 ? 1 : 0;
      nlf = getY( x + 1, z - 1 ) == h && x < worldWidth - 1 && z > 0 ? 1 : 0;

      // up neighbors

      nleftup  = getY( x - 1, z ) > h && x > 0 ? 1 : 0;
      nrightup = getY( x + 1, z ) > h && x < worldWidth - 1 ? 1 : 0;

      nbackup  = getY( x, z + 1 ) > h && z < worldDepth - 1 ? 1 : 0;
      nfrontup = getY( x, z - 1 ) > h && z > 0 ? 1 : 0;

      // up corner neighbors

      nrbup = getY( x - 1, z + 1 ) > h && x > 0 && z < worldDepth - 1 ? 1 : 0;
      nrfup = getY( x - 1, z - 1 ) > h && x > 0 && z > 0 ? 1 : 0;

      nlbup = getY( x + 1, z + 1 ) > h && x < worldWidth - 1 && z < worldDepth - 1 ? 1 : 0;
      nlfup = getY( x + 1, z - 1 ) > h && x < worldWidth - 1 && z > 0 ? 1 : 0;

      // textures

      ti = nleftup * 8 + nrightup * 4 + nfrontup * 2 + nbackup * 1;

      ri = nrf * 8 + nrb * 4 + 1;
      li = nlb * 8 + nlf * 4 + 1;
      bi = nrb * 8 + nlb * 4 + 1;
      fi = nlf * 8 + nrf * 4 + 1;

      ci = nlbup * 8 + nlfup * 4 + nrbup * 2 + nrfup * 1;

      // cube sides

      px = nx = pz = nz = 0;

      px = !nleft  || x == 0 ? 1 : 0;
      nx = !nright || x == worldWidth - 1 ? 1 : 0;

      pz = !nback  || z == worldDepth - 1 ? 1 : 0;
      nz = !nfront || z == 0 ? 1 : 0;

      sides = { px: px, nx: nx, py: true, ny: false, pz: pz, nz: nz };

      cube = new Cube( 100, 100, 100, 1, 1, materials, false, sides );

      // set UV tiles

      for ( i = 0; i < cube.uvs.length; i++ ) {

        uv = cube.uvs[ i ];

        for ( j = 0; j < uv.length; j++ ) {

          p = uv[j].u == 0 ? padding : -padding;
          uv[j].u = uv[j].u * unit + p;

          p = uv[j].v == 0 ? padding : -padding;
          uv[j].v = uv[j].v * unit + p;

        }

      }


      hash = px * 8 + nx * 4 + pz * 2 + nz;

      face_px = uv_index_map[ hash ].px;
      face_nx = uv_index_map[ hash ].nx;

      face_py = uv_index_map[ hash ].py;
      face_ny = uv_index_map[ hash ].ny;

      face_pz = uv_index_map[ hash ].pz;
      face_nz = uv_index_map[ hash ].nz;


      if( face_px != N ) setUVTile( face_px, ri, sides_row );
      if( face_nx != N ) setUVTile( face_nx, li, sides_row );

      if( face_py != N ) {

        mm = ti + "_" + ci;

        switch ( tilemap[ mm ] ) {
        case top_row_sides:   column = ti; break;
        case top_row_corners: column = ci; break;
        case top_row_mixed:   column = mixmap[ mm ]; break;
        }
        setUVTile( face_py, column, tilemap[ mm ] );

      }
      if( face_ny != N ) setUVTile( face_ny, 0, bottom_row );

      if( face_pz != N ) setUVTile( face_pz, bi, sides_row );
      if( face_nz != N ) setUVTile( face_nz, fi, sides_row );


      mesh = new THREE.Mesh( cube );

      mesh.position.x = x * 100 - worldHalfWidth * 100;
      mesh.position.y = h * 100;
      mesh.position.z = z * 100 - worldHalfDepth * 100;

      GeometryUtils.merge( geometry, mesh );

    }

  }

  geometry.sortFacesByMaterial();

  mesh = new THREE.Mesh( geometry, new THREE.MeshFaceMaterial() );
  scene.addObject( mesh );

  var ambientLight = new THREE.AmbientLight( 0xcccccc );
  scene.addLight( ambientLight );

  var directionalLight = new THREE.DirectionalLight( 0xffffff, 1.5 );
  directionalLight.position.x = 1;
  directionalLight.position.y = 1;
  directionalLight.position.z = 0.5;
  directionalLight.position.normalize();
  scene.addLight( directionalLight );

  renderer = new THREE.WebGLRenderer();
  renderer.setSize( window.innerWidth, window.innerHeight );

  container.innerHTML = "";

  container.appendChild( renderer.domElement );

  stats = new Stats();
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.top = '0px';
  container.appendChild( stats.domElement );

  document.addEventListener( 'mousedown', onDocumentMouseDown, false );
  document.addEventListener( 'mouseup', onDocumentMouseUp, false );
  document.addEventListener( 'mousemove', onDocumentMouseMove, false );
  document.addEventListener( 'contextmenu', function ( event ) { event.preventDefault(); }, false );

  document.addEventListener( 'keydown', onDocumentKeyDown, false );
  document.addEventListener( 'keyup', onDocumentKeyUp, false );

  document.getElementById( "bao" ).addEventListener( "click",  function() { mat.map = m_ao.map; }, false );
  document.getElementById( "baot" ).addEventListener( "click", function() { mat.map = m_aot.map; }, false );
  document.getElementById( "bt" ).addEventListener( "click",   function() { mat.map = m_t.map; }, false );

}

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

$().ready ->
  setTimeout((->  
    do init
    setInterval tick, (1000 / 60)
  ), 1000)