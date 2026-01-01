--------------------------------------------------------------------------------
-- License
--------------------------------------------------------------------------------

-- Copyright (c) 2025 Klaleus
--
-- This software is provided "as-is", without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose, including commercial applications,
-- and to alter it and redistribute it freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--        If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source distribution.

--------------------------------------------------------------------------------

-- GitHub: https://github.com/klaleus/merge-tileset

-- Usage: luajit merge_tileset.lua <source> <destination> <format>

--------------------------------------------------------------------------------

if arg[1]:sub(-1) ~= "/" then
    arg[1] = arg[1] .. "/"
end

-- Example: luajit merge_tileset.lua example/ tileset.png example/tileset.fmt
-- arg[1] -> "example/"
-- arg[2] -> "tileset.png"
-- arg[3] -> "example/tileset.fmt"

-- https://github.com/libvips/lua-vips
-- lua-vips seems to throw its own errors, so no need to assert against it.
local vips = require("vips")

-- Maximum tileset size is 4096 x 4096.
-- This could be added as a script parameter if flexibility is needed in the future.
local tileset = vips.Image.black(4096, 4096, { bands = 4 })

local format, err = io.open(arg[3], "r")
assert(format, err)

local lines = {}

for line in format:lines() do
    lines[#lines + 1] = line
end

format:close()

local tileset_width = 0
local tileset_height = 0

local tile_count = 0

local tile_scaling_factor = 8

local tile_x = 1
local tile_y = 1

local function merge(axis, cmd_args)
    local current_merge_length = 0

    local pixel_x_start = (tile_x - 1) * tile_scaling_factor
    local pixel_y_start = (tile_y - 1) * tile_scaling_factor

    for tile_name in cmd_args:gmatch("%S+") do
        local file_path = arg[1] .. tile_name .. ".png"
        local tile = vips.Image.new_from_file(file_path)

        local pixel_x = pixel_x_start + (axis == "x" and current_merge_length or 0)
        local pixel_y = pixel_y_start + (axis == "y" and current_merge_length or 0)
        local pixel_width = tile:width()
        local pixel_height = tile:height()

        if tileset_width < pixel_x + pixel_width then
            tileset_width = pixel_x + pixel_width
        end
        if tileset_height < pixel_y + pixel_height then
            tileset_height = pixel_y + pixel_height
        end

        print("Merging " .. tile_name .. " (x = " .. pixel_x .. ", y = " .. pixel_y .. ", width = " .. pixel_width .. ", height = " .. pixel_height .. ")...")
        tileset = tileset:insert(tile, pixel_x, pixel_y)

        current_merge_length = current_merge_length + (axis == "x" and pixel_width or pixel_height)
        tile_count = tile_count + 1
    end
end

for i = 1, #lines do
    local line = lines[i]
    local cmd, cmd_args = line:match("(%l+) (.+)")

    if cmd == "base" then
        tile_scaling_factor = tonumber(cmd_args:match("%d+"))

    elseif cmd == "select" then
        local tile_x_str, tile_y_str = cmd_args:match("(%d+) (%d+)")
        tile_x, tile_y = tonumber(tile_x_str), tonumber(tile_y_str)

    elseif cmd == "mergex" then
        merge("x", cmd_args)

    elseif cmd == "mergey" then
        merge("y", cmd_args)

    elseif cmd == "merge" then
        print("Command `merge` does not exist. Did you mean `mergex` or `mergey`?")
    end

    -- Lines that do not start with any of the above commands are ignored.
    -- This is useful for comments and whitespace.
end

local tileset = tileset:crop(0, 0, tileset_width, tileset_height)
tileset:write_to_file(arg[2])

print("Successfully merged " .. tile_count .. " tiles.")
