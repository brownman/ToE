console.log 'terrain'
`
window.generateMegamaterialAO = function( textures, strength, debug_texture, debug_numbers, debug_corner_colors  ) {

  var count = 0,
    tex_side   = loadTexture( textures.side,   function() { count++; generateTexture() } ),
    tex_top    = loadTexture( textures.top,    function() { count++; generateTexture() } ),
    tex_bottom = loadTexture( textures.bottom, function() { count++; generateTexture() } ),

    canvas = document.createElement( 'canvas' ),
    ctx = canvas.getContext( '2d' ),
    size = 256, tile = 16;

  canvas.width = canvas.height = size;

  function generateTexture() {

    if( count == 3 ) {

      for( var i = 0; i < 16; i++ ) {

        drawAOCorners( ctx, tex_top,  0, i, i, tile, strength, debug_texture, debug_numbers, debug_corner_colors );
        drawAOMixed  ( ctx, tex_top,    1, i, i, tile, strength, debug_texture, debug_numbers, debug_corner_colors );
        drawAOSides  ( ctx, tex_top,    2, i, i, tile, strength, debug_texture, debug_numbers );
        drawAOSides  ( ctx, tex_side,   3, i, i, tile, strength, debug_texture, debug_numbers );
        drawAOSides  ( ctx, tex_bottom, 4, i, i, tile, strength, debug_texture, debug_numbers );

      }

      canvas.loaded = true;

    }

  }

  return new THREE.MeshLambertMaterial( { map: new THREE.Texture( canvas, new THREE.UVMapping(), THREE.ClampToEdgeWrapping, THREE.ClampToEdgeWrapping, THREE.NearestFilter, THREE.LinearMipMapLinearFilter ) } );

}

window.generateMegamaterialPlain = function( textures ) {

  var count = 0,
    tex_side   = loadTexture( textures.side,   function() { count++; generateTexture() } ),
    tex_top    = loadTexture( textures.top,    function() { count++; generateTexture() } ),
    tex_bottom = loadTexture( textures.bottom, function() { count++; generateTexture() } ),

    canvas = document.createElement( 'canvas' ),
    ctx = canvas.getContext( '2d' ),
    size = 256, tile = 16;

  canvas.width = canvas.height = size;

  function generateTexture() {

    if( count == 3 ) {

      var i, sx;

      for( i = 0; i < 16; i++ ) {

        sx = i * tile;

        drawBase( ctx, tex_top,    sx, 0 * tile, tile, false );
        drawBase( ctx, tex_top,    sx, 1 * tile, tile, false );
        drawBase( ctx, tex_top,    sx, 2 * tile, tile, false );
        drawBase( ctx, tex_side,   sx, 3 * tile, tile, false );
        drawBase( ctx, tex_bottom, sx, 4 * tile, tile, false );

      }

      canvas.loaded = true;

    }

  }

  return new THREE.MeshLambertMaterial( { map: new THREE.Texture( canvas, new THREE.UVMapping(), THREE.ClampToEdgeWrapping, THREE.ClampToEdgeWrapping, THREE.NearestFilter, THREE.LinearMipMapLinearFilter ) } );

}
window.generateMegamaterialDebug = function() {

  var canvas = document.createElement( 'canvas' ),
    ctx = canvas.getContext( "2d" ),
    size = 256, tile = 16,
    i, j, h, s;

  canvas.width = size;
  canvas.height = size;

  ctx.textBaseline = "top";
  ctx.font = "8pt arial";

  for ( i = 0; i < tile; i++ ) {

    for ( j = 0; j < tile; j++ ) {

      h = i * tile + j;
      ctx.fillStyle = "hsl(" + h + ",90%, 50%)";
      ctx.fillRect( i * tile, j * tile, tile, tile );

      drawHex( ctx, h, i * tile + 2, j * tile + 2 );

    }

  }

  canvas.loaded = true;

  return new THREE.MeshLambertMaterial( { map: new THREE.Texture( canvas, new THREE.UVMapping(), THREE.ClampToEdgeWrapping, THREE.ClampToEdgeWrapping, THREE.NearestFilter, THREE.LinearMipMapLinearFilter ) } );

}

window.drawHex = function( ctx, n, x, y ) {

  ctx.fillStyle = "black";
  ctx.font = "8pt arial";
  ctx.textBaseline = "top";

  var s = n.toString( 16 );
  s = n < 16 ? "0" + s : s;
  ctx.fillText( s, x, y );

}

window.drawBase = function( ctx, image, sx, sy, tile, debug_texture ) {

  if ( debug_texture ) {

    ctx.fillStyle = "#888";
    ctx.fillRect( sx, sy, tile, tile );

  } else {

    ctx.drawImage( image, sx, sy, tile, tile );

  }

}

window.drawCorner = function( ctx, sx, sy, sa, ea, color, step, n ) {

  for( var i = 0; i < n; i++ ) {

    ctx.strokeStyle = color + step * ( n - i ) + ")";
    ctx.beginPath();
    ctx.arc( sx, sy, i, sa, ea, 0 ) ;
    ctx.stroke();

  }

}

window.drawSide = function( ctx, sx, sy, a, b, n, width, height, color, step ) {

  for( var i = 0; i < n; i++ ) {

    ctx.fillStyle = color + step * ( n - i ) + ")";
    ctx.fillRect( sx + a * i, sy + b * i, width, height );

  }
}

window.drawAOSides = function( ctx, image, row, column, sides, tile, strength, debug_texture, debug_numbers ) {

  var sx = column * tile, sy = row * tile;

  drawBase( ctx, image, sx, sy, tile, debug_texture );
  drawAOSidesImp( ctx, image, row, column, sides, tile, strength );

  if ( debug_numbers ) drawHex( ctx, row * tile + sides, sx + 2, sy + 2 );

}

window.drawAOCorners = function( ctx, image, row, column, corners, tile, strength, debug_texture, debug_numbers, debug_corner_colors ) {

  var sx = column * tile, sy = row * tile;

  drawBase( ctx, image, sx, sy, tile, debug_texture );
  drawAOCornersImp( ctx, image, row, column, corners, tile, strength, debug_corner_colors );

  if ( debug_numbers ) drawHex( ctx, row * tile + corners, sx + 2, sy + 2 );

}

window.drawAOMixed = function( ctx, image, row, column, elements, tile, strength, debug_texture, debug_numbers, debug_corner_colors ) {

  var sx = column * tile, sy = row * tile,

    mmap = {
    0:  [ 1, 1 ],
    1:  [ 1, 4 ],
    2:  [ 2, 2 ],
    3:  [ 2, 8 ],
    4:  [ 4, 1 ],
    5:  [ 4, 2 ],
    6:  [ 8, 4 ],
    7:  [ 8, 8 ],
    8:  [ 1, 5 ],
    9:  [ 2, 10 ],
    10: [ 4, 3 ],
    11: [ 8, 12 ],
    12: [ 5, 1 ],
    13: [ 6, 2 ],
    14: [ 9, 4 ],
    15: [ 10, 8 ]
    };

  drawBase( ctx, image, sx, sy, tile, debug_texture );
  drawAOCornersImp( ctx, image, row, column, mmap[ elements ][1], tile, strength, debug_corner_colors );
  drawAOSidesImp( ctx, image, row, column, mmap[ elements ][0], tile, strength );

  if ( debug_numbers ) drawHex( ctx, row * tile + elements, sx + 2, sy + 2 );

}

window.drawAOSidesImp = function( ctx, image, row, column, sides, tile, strength ) {

  var sx = column * tile, sy = row * tile,
    full = tile, step = 1 / full, half = full / 2 + strength,

    color = "rgba(0, 0, 0, ",

    left   = (sides & 8) == 8,
    right  = (sides & 4) == 4,
    bottom = (sides & 2) == 2,
    top    = (sides & 1) == 1;

  if ( bottom ) drawSide( ctx, sx, sy, 0, 1, half, tile, 1, color, step );
  if ( top )    drawSide( ctx, sx, sy + full - 1, 0, -1, half, tile, 1, color, step );
  if ( left )   drawSide( ctx, sx, sy, 1, 0, half, 1, tile, color, step );
  if ( right )  drawSide( ctx, sx + full - 1, sy, -1, 0, half, 1, tile, color, step );

}

window.drawAOCornersImp = function( ctx, image, row, column, corners, tile, strength, debug_corner_colors ) {

  var sx = column * tile, sy = row * tile,

    full = tile, step = 1 / full, half = full / 2 + strength,

    color = "rgba(0, 0, 0, ",

    bottomright = (corners & 8) == 8,
    topright    = (corners & 4) == 4,
    bottomleft  = (corners & 2) == 2,
    topleft     = (corners & 1) == 1;

  if ( topleft ) {

    if ( debug_corner_colors ) color = "rgba(200, 0, 0, ";
    drawCorner( ctx, sx, sy, 0, 1.57, color, step, half );

  }

  if ( bottomleft ) {

    if ( debug_corner_colors ) color = "rgba(0, 200, 0, ";
    drawCorner( ctx, sx, sy + full, 4.71, 6.28, color, step, half );

  }

  if ( bottomright ) {

    if ( debug_corner_colors ) color = "rgba(0, 0, 200, ";
    drawCorner( ctx, sx + full, sy + full, 3.14, 4.71, color, step, half );

  }

  if ( topright ) {

    if ( debug_corner_colors ) color = "rgba(200, 0, 200, ";
    drawCorner( ctx, sx + full, sy, 1.57, 3.14, color, step, half );

  }

}

window.loadTexture = function( path, callback ) {

  var image = new Image();

  image.onload = function () { this.loaded = true; callback(); };
  image.src = path;

  return image;

}

window.generateHeight = function( width, height ) {

  var data = [], perlin = new ImprovedNoise(),
  size = width * height, quality = 2, z = Math.random() * 100;

  for ( var j = 0; j < 4; j ++ ) {

    if ( j == 0 ) for ( var i = 0; i < size; i ++ ) data[ i ] = 0;

    for ( var i = 0; i < size; i ++ ) {

      var x = i % width, y = ~~ ( i / width );
      data[ i ] += perlin.noise( x / quality, y / quality, z ) * quality;

    }

    quality *= 4

  }

  return data;

}

window.getY = function( x, z ) {

  return ~~( data[ x + z * worldWidth ] * 0.2 );

}
`