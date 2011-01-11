console.log 'client'

`
window.init = function() {
  window.fogExp2 = true;

  window.container = null;

  window.camera = null;
  window.scene = null;
  window.renderer = null;

  window.mesh = null;

  window.worldWidth = 128;
  window.worldDepth = 128;
  window.worldHalfWidth = worldWidth / 2;
  window.worldHalfDepth = worldDepth / 2;
  window.data = window.generateHeight(worldWidth, worldDepth);

  window.lat = 0;
  window.lon = 0;
  window.phy = 0;
  window.theta = 0;

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
}
`

$().ready ->
  setTimeout((->  
    do init
    setInterval tick, (1000 / 60)
  ), 1000)