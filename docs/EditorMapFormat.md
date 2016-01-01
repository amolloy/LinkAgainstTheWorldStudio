# Editor Map Format

The Link Against the World Studio editor map is represented on disk by an OS X bundle. The bundle contains a control file and one or more of the following:

- [Tile Sets](#tile-sets)
- [Brush Sets](#brunch-sets)
- [Terrain Sets](#terrain-sets)
- [Tile Layers](#tile-layers)
- Object Layers (TBD)
- Static Objects (TBD)
- Entity Spawners (TBD)

The expectation is that these files may be stored in a revision control system, and so text formats are preferred. Binary blobs, where necessary, exist within their own file.

## Tile Sets

A tile set is a bundle containing a single TIFF image file and a control file. The control file (Info.plist) is an XML plist with the following required properties:

Key | Value Description
----|-------------------
version | Currently always 1.0
image | Name of the TIFF file
tileCount | Number of tiles in the tile set
tileWidth | Width of the tiles, in points
tileHeight | Height of the tiles, in points
name | A string uniquely identifying this tile set within a map bundle

The TIFF contains images of each tile laid out in a grid. There must be no space between each tile. Multi-TIFF may be used to represent tiles as different point sizes (Retina support, for example). Any TIFF feature supported by OS X's built-in TIFF support are allowed.

Just as there is no space allowed between tiles in the tile set image, the image itself must not have any extra space around the grid of tiles. Therefore, the image's dimensions must be evenly divisible by the tile width / height. 

Tiles are referenced in the tile set by index. The index is computed row-first from the top left of the the tiles image.

Indexes into a tile set are expected to be permanent. If a tile is deleted, its image data is removed, but the slot it took in the image file will remain vacant.

The control file my optionally contain the following key:

Key | Value Description
----|-------------------
unused | Array of indices for deleted tiles. New tiles may safely be placed in an unused index.

## Brush Sets

## Terrain Sets

## Tile Layers