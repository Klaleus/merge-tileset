# merge_tileset.lua

Lua script that merges individual tiles into a tileset.

Please click the ☆ button on GitHub if this repository is useful. Thank you!

## Installation

Install libvips, a C library that performs image-related operations:  
https://github.com/libvips/libvips

Install lua-vips, a Lua binding to libvips:  
https://github.com/libvips/lua-vips

Finally, download or clone this repository.

## Usage

```
$ luajit merge_tileset.lua <source> <destination> <format>
```

1. `source` Relative path to the source directory where the tiles are located.
2. `destination` Relative path to the resulting tileset.
3. `format` Relative path to the format file, which defines how to merge each tile.

Only PNG images are supported.

## Example

The example project can be tested with the following command:

```
$ luajit crop_tileset.lua example/ tileset.png example/tileset.fmt
```

* The source tiles are read from the `example/` directory.
* The resulting tileset will be created as `tileset.png`.

<img width="240" height="160" alt="tileset.png" src="https://github.com/user-attachments/assets/545097a9-36ad-4c00-806e-3be993ba7b15" />

```
base 8

select 1 1
mergex tree_large_red tree_large_green tree_large_blue

select 1 3
mergex tree_tall_red tree_tall_green tree_tall_blue

select 4 3
mergey flower_small_red flower_small_blue

select 5 3
mergex sign
```

Format files are kept as simple as possible with minimal commands:

* `base <size>` Defines the width and height of subsequent `select` operations. Default is `base 8`.
* `select <x> <y>` Selects the starting tileset position of the next merge operation. Arguments are relative to the `base` tile size. Coordinates `x = 1` and `y = 1` correspond to the top-left of the tileset.
* `mergex <tile_name> ...` Merges sequential tiles horizontally. The amount of merges is determined by how many `tile_name` arguments are passed, where each name corresponds to an image in the source directory `example/`.
* `mergey <tile_name> ...` Merges sequential tiles vertically. The amount of merges is determined by how many `tile_name` arguments are passed, where each name corresponds to an image in the source directory `example/`.

Faulty arguments to these commands are not protected against and will result in undefined behavior. Lines that do not start with one of the above commands are ignored.

Executing the above example would result in the following output:

```
luajit merge_tileset.lua example/ tileset.png example/tileset.fmt

Merging tree_large_red (x = 0, y = 0, width = 16, height = 16)...
Merging tree_large_green (x = 16, y = 0, width = 16, height = 16)...
Merging tree_large_blue (x = 32, y = 0, width = 16, height = 16)...
Merging tree_tall_red (x = 0, y = 16, width = 8, height = 16)...
Merging tree_tall_green (x = 8, y = 16, width = 8, height = 16)...
Merging tree_tall_blue (x = 16, y = 16, width = 8, height = 16)...
Merging flower_small_red (x = 24, y = 16, width = 8, height = 8)...
Merging flower_small_blue (x = 24, y = 24, width = 8, height = 8)...
Merging sign (x = 32, y = 16, width = 8, height = 8)...

Successfully merged 9 tiles.
```

```
$ ls *.png

./tileset.png
```
