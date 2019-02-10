--------------------------------------------------------------------------------
-- The Map module representing Tiled map.
--
-- @module  Berry
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Jan-2018
--------------------------------------------------------------------------------
--                                 REQUIRED MODULES	                          --						
-- -------------------------------------------------------------------------- --

local json = require 'json' 
local lfs  = require 'lfs'  -- lfs stands for LuaFileSystem

-- -------------------------------------------------------------------------- --
--                                  MODULE                                    --												
-- -------------------------------------------------------------------------- --

local Map = {}

-- -------------------------------------------------------------------------- --
--                                  LOCALISED VARIABLES                       --	
-- -------------------------------------------------------------------------- --

local mFloor = math.floor
local mSin   = math.sin
local mCos   = math.cos
local mRad   = math.rad
local mHuge  = math.huge

local FLIPPED_HORIZONTAL_FLAG = 0x80000000
local FLIPPED_VERTICAL_FLAG   = 0x40000000
local FLIPPED_DIAGONAL_FLAG   = 0x20000000

-- -------------------------------------------------------------------------- --
--									LOCAL FUNCTIONS	                          --
-- -------------------------------------------------------------------------- --

local function hasBit( x, p ) return x % ( p + p ) >= p end
local function setBit( x, p ) return hasBit( x, p ) and x or x + p end
local function clearBit( x, p ) return hasBit( x, p ) and x - p or x end

--------------------------------------------------------------------------------
-- Assign given properties to object.
-- @param object The object which get new properties.
-- @param properties Properties to assign.
-- return The object.
--
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
local function inherit( object, properties )

	properties = properties or {}

	for key, value in pairs(properties) do object[key] = value end

	return object

end	

--------------------------------------------------------------------------------
-- Convert two-dimensional table to one-dimensional table and apply 
-- traslation/rotation.
--
-- @param points The two-dimensional table with x and y properties.
-- @param delta_x The value added to x coordinate.
-- @param delta_y The value added to y coordinate.
-- @param angle The value of rotation in degrees.
-- @return The one-dimensional table.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
local function unpackPoints( points, delta_x, delta_y, angle )

	local xy_list = {}
	local x, y

	local function rotate( points, angle )

		angle  = angle or 0

		local COS = mCos( mRad( angle ) )
		local SIN = mSin( mRad( angle ) )

		for i=1, #points do

			x, y = points[i].x, points[i].y

			points[i].x = x * COS - y * SIN
			points[i].y = x * SIN + y * COS

		end	
			
	end	

	local function translate( points, delta_x, delta_y ) 

		delta_x = delta_x or 0	
		delta_y = delta_y or 0

		for i=1, #points do

			x, y = points[i].x, points[i].y

			points[i].x = x + delta_x
			points[i].y = y + delta_y 
			
		end	

	end	

	-- All transformations are made in place
	rotate( points, angle )
	translate( points, delta_x, delta_y )

	for i = 1, #points do

		xy_list[#xy_list + 1] = points[i].x
		xy_list[#xy_list + 1] = points[i].y

	end

	return xy_list

end

--------------------------------------------------------------------------------
-- Center display object anchor point.
-- @param object The object to center.
--
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
local function centerAnchor( object )

  if object.contentBounds then 

    local bounds = object.contentBounds
    local actual_center_x = ( bounds.xMin + bounds.xMax ) * 0.5
    local actual_center_y = ( bounds.yMin + bounds.yMax ) * 0.5

    object.anchorX, object.anchorY = 0.5, 0.5  
    object.x, object.y = object.parent:contentToLocal( actual_center_x, 
    												   actual_center_y)

  end

end

--------------------------------------------------------------------------------
-- Decoding color in hex format to ARGB.
--
-- @param hex The color to decode.
-- @return The color in ARGB format.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
local function decodeTiledColor( hex )

	hex = hex or '#FF888888'
	hex = hex:gsub( '#', '' )
	-- Change #RRGGBB to #AARRGGBB 
	hex = string.len( hex ) == 6 and 'FF' .. hex or hex

	local function hexToFloat( part ) 
		return tonumber( '0x'.. part or '00' ) / 255 
	end

	local a = hexToFloat( hex:sub( 1, 2 ) )
	local r = hexToFloat( hex:sub( 3, 4 ) )
	local g = hexToFloat( hex:sub( 5, 6 ) )
	local b = hexToFloat( hex:sub( 7, 8 ) )

	return r, g, b, a

end

--------------------------------------------------------------------------------
-- Creates an image sheet from a TexturePack/Tiled tileset and returns it
--
-- @param tileset The object which contains information about tileset.
-- @return The newly created image sheet.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------   
local function createImageSheet( tileset )

	local options, name

	if tileset.image then -- Tiled tileset

		local tsiw,   tsih    = tileset.image_width, tileset.image_height
		local margin, spacing = tileset.margin,     tileset.spacing
		local w,      h       = tileset.tilewidth,  tileset.tileheight

		name = tileset.image
		options = {
			frames             = {},
			sheetContentWidth  = tsiw,
			sheetContentHeight = tsih,
		}

		local frames = options.frames
		local tileset_height    = tileset.tilecount / tileset.columns 
		local tileset_width     = tileset.columns 

		for j=1, tileset_height do

		  for i=1, tileset_width do

		    local element = {
				x      = ( i - 1 ) * ( w + spacing ) + margin,
				y      = ( j - 1 ) *( h + spacing ) + margin,
				width  = w,
				height = h,
		    }

		    frames[#frames + 1] = element

		  end

		end

	elseif tileset.sheet then -- TexturePacker tileset

		name = tileset.name
		options = tileset:getSheet()

	end

	-- DELETE THIS LATER
    --"image":"..\/ss13\/floors.png",
    -- directory is: 'map/ss13'

	local directory = tileset.directory .. ( name or '' ) 
	return graphics.newImageSheet( directory, options )

end

--------------------------------------------------------------------------------
-- Returns an image sheet or nil
--
-- @param cache A table that stores GID, image_names, tileset_names for lookup 
-- @param id The GID or image_name to find the image sheet.
-- @return The image sheet or nil.
-- @return The frame_index for image in image sheet. (Texturepacker only)
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------   
local function getImageSheet( cache, id )

	local is_image_sheet = cache[id] and cache[id].sheet 
	local image_sheet = is_image_sheet and cache[id]

	if image_sheet then

		local sheet, frame = image_sheet.sheet, image_sheet.frame 
		return sheet, frame

	end

	return nil

end

--------------------------------------------------------------------------------
-- Returns tile values for display.newImageRect
--
-- @param cache A table that stores GID, image_names, tileset_names for lookup 
-- @param id The id of tile.
-- @return The image directory, image width, and image height
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------   
local function getImageInfo( cache, id )

	local is_image = cache[id] and cache[id].path
	local image =  is_image and cache[id]

	if image then

		return image.path, image.width, image.height

	end

	return nil

end

--------------------------------------------------------------------------------
--- Gets a Tile image from a GID.
--
-- @param cache A table that stores GID, image_names, tileset_names for lookup 
-- @param id The gid to use to find tileset.
-- @return The tileset at the gid location.
--------------------------------------------------------------------------------
local function getTileset( cache, id )
	
	local tileset = cache[id] and cache[id].tileset
	return tileset

end

--------------------------------------------------------------------------------
-- Find property by name.
--
-- @param properties The table with properties.
-- @param name The name of property to find.
-- @return The value of found property.
--------------------------------------------------------------------------------   
local function findProperty( properties, name )

	properties = properties or {}

	for i=1, #properties do

		property = properties[i]

		if property.name == name then

			return property.value

		end	

	end	

end	

--------------------------------------------------------------------------------
-- Collect all sequences data from a tileset.
--
-- @param tileset The tileset object.
-- @return The table.
--------------------------------------------------------------------------------  
local function buildSequences( tileset )

	local sequences       = {}
	local tiles 		  = tileset.tiles or {}
	local animation, frames, tile 

	for i=1, #tiles do

		tile       = tiles[i]
		animation  = tile.animation

		if animation then 

			frames = {}

			-- The property tileid starts from 0 (in JSON format) 
			-- but frames count from 1
			for i=1, #animation do 
				frames[#frames + 1] = animation[i].tileid + 1 
			end

			sequences[#sequences + 1] = {
				frames        = frames,
	            time          = findProperty( tile.properties, 'time' ),
	            name          = findProperty( tile.properties, 'sequenceName' ),
	            loopCount     = findProperty( tile.properties, 'loopCount' ),
	            loopDirection = findProperty( tile.properties, 'loopDirection' )
	        }
	        
	    end 

	end		

	return sequences

end	

--------------------------------------------------------------------------------
-- Retrieve shape data from a tileset based on id.
--
-- @param tile_id The id of tile.
-- @param tileset The object which contains information about tileset.
-- @return Multiple values.
--------------------------------------------------------------------------------  
local function retrieveShapeData( tile_id, tileset )

	local tiles = tileset.tiles or {}
	local object, tile

	-- We need find proper tile since it stores information about shape
	for i=1, #tiles do

		tile = tiles[i]

		if tile_id == tile.id then break end	

	end	



	if tile then

print('-----------------')
print('RETREIVESHAPEDATA')
for k,v in pairs(tileset) do print(k,v) end
print('More shape data')
print("tile is:", tile)

		local objectgroup = tile.objectgroup

		if objectgroup and objectgroup.objects and #objectgroup.objects > 0 then

			object = objectgroup.objects[1] 

			local other_shape = ( not object.ellipse and not object.polyline )
			if object.polygon or other_shape then
				
				local vertices = object.polygon or { 
					{ x=0,            y=0 },
					{ x=object.width, y=0 },
					{ x=object.width, y=object.height },
					{ x=0,            y=object.height }, 
				}

				return vertices, object.x, object.y, object.rotation 

			end

	    end

	end

end	

--------------------------------------------------------------------------------
-- Mapping from isometric coordinates to screen coordinates 
--
-- @param row Number of row. Can real number.
-- @param column Number of column. Can be real number.
-- @param tile_width Width of tile.
-- @param tile_height Height of tile.
-- @param offset_x
-- @param offset_y 
-- @return A two coodinates x and y.
-------------------------------------------------------------------------------- 
local function isoToScreen( row, column, tile_width, tile_height, 
							offset_x, offset_y )

	local x = (column - row) * tile_width * 0.5 + (offset_x or 0)
	local y = (column + row) * tile_height * 0.5 + (offset_y or 0)

	return x, y

end	

--------------------------------------------------------------------------------
-- Find center of polygon or polyline
--
-- @param points A table with x and y coordinates/
-- @return Two numbers.
-------------------------------------------------------------------------------- 
local function findCenter( points )

	local xMax, xMin, yMax, yMin = -mHuge, mHuge, -mHuge, mHuge 

	for i = 1, #points do

		if points[i].x < xMin then xMin = points[i].x end  
		if points[i].y < yMin then yMin = points[i].y end 
		if points[i].x > xMax then xMax = points[i].x end   
		if points[i].y > yMax then yMax = points[i].y end  

	end

	return (xMax + xMin) * 0.5, (yMax + yMin) * 0.5

end

--------------------------------------------------------------------------------
-- Creates and loads tilesets from directory
--
-- @param cache A table that stores GID, image_names, tileset_names for lookup 
-- @param tilesets The tileset data to load
-------------------------------------------------------------------------------- 
local function loadTilesets( cache, tilesets )

	for _, tileset in ipairs(tilesets) do

		local firstgid = tileset.firstgid
		local lastgid = tileset.firstgid + tileset.tilecount - 1

		if tileset.image then 

			local sheet = createImageSheet( tileset )

			cache[tileset.image] = {
				tileset = tileset,
				sheet = sheet,
				type = 'tiled',
			}

			for gid = firstgid, lastgid do

				assert( not cache[gid],
					"Duplicate gid for image sheet detected.  Check to " ..
					"make sure the same image sheet isn't being loaded twice "..
					"or if some of the images/tilesets have matching names"
				)

				cache[gid] = {
					tileset = tileset,
					sheet = sheet,
					type = 'tiled',
					frame = gid - firstgid + 1,
				}

			end

		elseif tileset.tiles then -- Has embedded images (no image sheets)

			for i, tile in ipairs(tileset.tiles) do

				local gid = firstgid + ( i - 1 )

				cache[gid] = {
					tileset = tileset,
					path = tileset.directory .. tile.image,
					width = tile.image_width,
					height = tile.image_height,
				}

			end

		end

	end

end

--------------------------------------------------------------------------------
-- Creates and loads Texturepacker tilesets from directory
--
-- @param cache A table that stores GID, image_names, tileset_names for lookup 
-- @param directory A directory to scan for texturepacker lua files
-------------------------------------------------------------------------------- 
local function loadTexturePacker( cache, directory )

    local path = system.pathForFile( directory, system.ResourceDirectory ) 

	for file in lfs.dir( path ) do

		-- This pattern captures the name and extension of a file string
		local file_name, extension = file:match("(.*)%.(.+)$")
		local is_lua_file = file ~= '.' and file ~= '..' and extension == 'lua'

		if is_lua_file then

		    local require_path = directory .. '.' .. file_name

		    -- Replace slashes with periods in require path else file won't load
			local lua_module = require_path:gsub("[/\]", ".")

			-- Using pcall to prevent any require() lua modules from crashing
			local tileset = pcall(require, lua_module)

			local is_texturepacker_data = tileset and 
										  type(tileset) == 'table' and
										  tileset.sheet 

			if is_texturepacker_data then

				-- these are used by the createImageSheet
				tileset.name = file_name
				tileset.directory = directory

				local sheet = createImageSheet( tileset )

--[[-- we may want to get rid of this?
	   This would attach the image_name/lua_file_name to cache
	   but I'm pretty sure we don't need it... only the sprite_name

				cache[file_name] = {
					sheet = sheet,
					type = 'texturepacker',
				}
--]]

				for sprite_name, i in pairs(tileset.frameIndex) do

					assert( not cache[sprite_name],
					"Duplicate names for image sheet detected.  Check to " ..
					"make sure the same image sheet isn't being loaded twice" ..
					" or if some of the images/tilesets have matching names"
					)

					cache[sprite_name] = {
					--  tileset = tileset,  (pretty sure we don't need this)
						sheet = sheet,
						type = 'texturepacker',
						frame = i,
					}

				end

			end

		end

	end

end

-- -------------------------------------------------------------------------- --
--                                  PUBLIC METHODS                            --	
-- -------------------------------------------------------------------------- --

--------------------------------------------------------------------------------
-- Create a new map object.
--
-- @param filename Name of map file.
-- @param tilesets_dir The path to tilesets.
-- @param texturepacker_dir The path to texturepacker tilesets.
-- @return The newly created map.
--------------------------------------------------------------------------------

function Map:new( filename, tilesets_dir, texturepacker_dir )

	-- Read map file
	local json_path = system.pathForFile( filename, system.ResourceDirectory ) 
    local data = json.decodeFile( json_path )

	local map = inherit( display.newGroup(), self )
	map.dim = { width=data.width, height=data.height }
	map.image_cache = {}

    -- Purpose of computation here is simplification of code
    for i, tileset in ipairs( data.tilesets ) do

    	tileset.sequence_data   = buildSequences( tileset )
    	tileset.directory 		= tilesets_dir and tilesets_dir .. '/' or ''

    end

    -- Apply properties from data
    map.tilesets      = data.tilesets
    map.orientation   = data.orientation			
    map.stagger_axis  = data.staggeraxis
    map.stagger_index = data.staggerindex
    map.tile_width    = data.tilewidth
    map.tile_height   = data.tileheight

	-- Add useful properties
    map.default_extensions = 'berry.plugins.'

    -- TexturePacker directory will default to tilesets_dir if arg not present
    texturepacker_dir = texturepacker_dir or tilesets_dir

    do  -- Create and cache all the image sheets
	    loadTilesets( map.image_cache, map.tilesets )
		loadTexturePacker( map.image_cache, texturepacker_dir )
	end
	
	for _, info in ipairs( data.layers ) do

		local layer = display.newGroup() 

		-- Apply properties from info
	    layer.name       = info.name
	    layer.type       = info.type
	    layer.alpha      = info.opacity
	    layer.isVisible  = info.visible
		layer.x          = info.offsetx or 0
		layer.y          = info.offsety or 0
		layer.properties = info.properties or {}
		
		if layer.type == 'objectgroup' then

			local objects = info.objects or {}

			for _, object in ipairs( objects ) do

				-- From here we start process Tiled object into display object
				map:createObject( object, layer )

			end

		elseif layer.type == 'tilelayer' then

			layer.size = info.width

			-- GID stands for global tile ID
			for position, gid in ipairs( info.data ) do

				if gid > 0 then map:createTile( position, gid, layer ) end

			end

		end

		map:insert( layer )

	end 
 
    -- Center map
    if map.orientation == 'isometric' then

    	map.designed_width  = (data.height + data.width) * 0.5 * data.tilewidth
    	map.designed_height = (data.height + data.width) * 0.5 * data.tileheight
    	map.x = display.contentCenterX - map.designed_width * 0.5
    	map.y = display.contentCenterY - map.designed_height * 0.5

    elseif map.orientation == 'orthogonal' then
    	
    	map.designed_width  = data.width  * data.tilewidth
    	map.designed_height = data.height * data.tileheight
    	map.x = display.contentCenterX - map.designed_width * 0.5
    	map.y = display.contentCenterY - map.designed_height * 0.5
    	
    end	

	-- Set the background color to the map background
	display.setDefault( 'background', decodeTiledColor( data.backgroundcolor ) )   
	return map
end

--------------------------------------------------------------------------------
--- Create and add tile to layer
--  
--------------------------------------------------------------------------------
function Map:createTile( position, gid, layer )

	-- Get the correct tileset using the GID
	local tileset = getTileset( self.image_cache, gid )

	if tileset then

		local image 
		local width, height  = tileset.tilewidth, tileset.tileheight 

		local image_sheet, frame = getImageSheet( self.image_cache, gid ) 

		if image_sheet then

			image = display.newImageRect( layer, image_sheet, 
										  frame, width, height )

		else 
          	
          	local path, image_w, image_h = getImageInfo( self.image_cache, gid )
          	image = display.newImageRect( layer, path, image_w, image_h )

		end	

		if image then

			-- The first element from layer.data start at (0, 0) and 
			-- goes from left to right and top to bottom			
			image.row    = mFloor( 
								   ( position + layer.size - 1 ) / layer.size 
								 ) - 1
			image.column = position - image.row * layer.size - 1

			if self.orientation == 'isometric' then

				image.anchorX, image.anchorY = 0.5, 0
				image.x, image.y = isoToScreen( 
					image.row, image.column, 
					self.tile_width, self.tile_height, 
					self.dim.height * self.tile_width * 0.5 
				)

			elseif self.orientation == 'staggered' then

		    	local staggered_offset_y = ( self.tile_height * 0.5 )
		    	local staggered_offset_x = ( self.tile_width * 0.5 )

		    	if self.stagger_axis == 'y' then

		    		if self.stagger_index == 'odd' then

		    			if image.row % 2 == 0 then

		    				image.x = ( image.column * self.tile_width ) + 
		    							staggered_offset_x

		    			else

		    				image.x = ( image.column * self.tile_width )

		    			end

		    		else

		    			if image.row % 2 == 0  then

		    				image.x = ( image.column * self.tile_width )

						else

		    				image.x = ( image.column * self.tile_width ) + 
		    							staggered_offset_x

						end

		    		end

		    		image.y = ( 
		    					image.row * 
		    				    ( self.tile_height - self.tile_height * 0.5 ) 
		    				  )

		    	else

		    		if self.stagger_index == 'odd' then

		    			if image.column % 2 == 0  then

		    				image.y = ( image.row * self.tile_height ) + 
		    							staggered_offset_y

		    			else

		    				image.y = ( image.row * self.tile_height )

		    			end

		    		else

		    			if image.column % 2 == 0  then

		    				image.y = ( image.row * self.tile_height )

						else

		    				image.y = ( image.row * self.tile_height ) + 
		    							staggered_offset_y

						end

		    		end

		    		image.x = ( 
		    					image.column * 
		    					( self.tile_width - self.tile_width * 0.5 ) 
		    				  )

		    	end

			elseif self.orientation == 'orthogonal' then

				image.anchorX, image.anchorY = 0, 1
				image.x = image.column * self.tile_width
				image.y = ( image.row + 1 ) * self.tile_height

			end

			-- If the map is already created these map_offsets will move your 
			-- object to be in synch with the map at the proper position
			local map_offset_x = self.x or 0
			local map_offset_y = self.y or 0

			image.x = image.x - map_offset_x
			image.y = image.y - map_offset_y

			centerAnchor( image )
			inherit( image, layer.properties )

		end	

	end	

end

--------------------------------------------------------------------------------
--- Create and add object to layer
--  
--------------------------------------------------------------------------------
function Map:createObject( object, layer )
    -- Store the flipped states
    local flip = {}
    local image

	-- Make sure we have a properties table
	object.properties = object.properties or {}

	-- Image/Sprite	
	-- GID stands for global tile ID
	if object.gid then

		-- Original code from https://github.com/ponywolf/ponytiled    
	    flip.x  = hasBit( object.gid, FLIPPED_HORIZONTAL_FLAG )
	    flip.y  = hasBit( object.gid, FLIPPED_VERTICAL_FLAG )          
	    flip.xy = hasBit( object.gid, FLIPPED_DIAGONAL_FLAG )

	    object.gid = clearBit( object.gid, FLIPPED_HORIZONTAL_FLAG )
	    object.gid = clearBit( object.gid, FLIPPED_VERTICAL_FLAG )
	    object.gid = clearBit( object.gid, FLIPPED_DIAGONAL_FLAG )

		-- Get the correct tileset using the GID
		tileset = getTileset( self.image_cache, object.gid )

		if tileset then

			local firstgid           = tileset.firstgid
			local tile_id 		     = object.gid - tileset.firstgid
			local width,      height = object.width, object.height
			local image_sheet, frame = getImageSheet( self.image_cache, object.gid ) 

			if image_sheet then

				if findProperty( layer.properties, 'isAnimated' ) or 
				   findProperty( object.properties, 'isAnimated' ) then

					image = display.newSprite( layer, 
											   image_sheet, 
											   tileset.sequence_data )

				else

					image = display.newImageRect( layer, image_sheet, 
												  frame, width, height )

				end
					
			else 

          		local path = getImageInfo( self.image_cache, object.gid )
				image = display.newImageRect( layer, path, width, height ) 

			end

			local points, x, y, rotation  = retrieveShapeData( tile_id, tileset )

			-- Add collsion shape
			if points then

				local delta_x = x - image.width * 0.5 
				local delta_y = y - image.height * 0.5 

				points = unpackPoints( points, delta_x, delta_y, rotation )

				-- Corona shape have limit of 8 vertex
				if #points > 8 then

					-- Add two new physics properties
					local property = { name = 'chain', value = points }
					object.properties[#object.properties + 1] = property
					property = { name = 'connectFirstAndLastChainVertex', 
								 value = true }
					object.properties[#object.properties + 1] = property

				else 

					-- Add new physics property
					local property = { name = 'shape', value = points }
					object.properties[#object.properties + 1] = property

				end	

			end	  

	    	if self.orientation == 'isometric' then

				image.x, image.y = isoToScreen( 
					object.y / self.tile_height, 
					object.x / self.tile_height, 
					self.tile_width, 
					self.tile_height, 
					self.dim.height * self.tile_width * 0.5 
					)
            	image.anchorX, image.anchorY = 0.5, 1   

			elseif self.orientation == 'orthogonal' then 

print('---------')
print(image_sheet)
print(object.gid)
print(tileset)


				image.anchorX, image.anchorY = 0, 1
				image.x, image.y             = object.x, object.y

			end			
				
			image.tile_id = tile_id
			image.gid    = object.gid

		end	

	elseif object.polygon or object.polyline then 
		local points = object.polygon or object.polyline

		if object.polygon then 

	    	if self.orientation == 'isometric' then
	    		
	    		for i=1, #points do
		    
	                points[i].x, points[i].y = isoToScreen( 
	                	points[i].y / self.tile_height, 
	                	points[i].x / self.tile_height, 
	                	self.tile_width, 
	                	self.tile_height 
	                )
	               
				end	

				local centerX, centerY = findCenter( points )
				image = display.newPolygon( 
					layer, 0, 0, unpackPoints( points ) 
				)	
				image.x, image.y = isoToScreen( 
					object.y / self.tile_height, 
					object.x / self.tile_height, 
					self.tile_width, 
					self.tile_height, 
					self.dim.height * self.tile_width * 0.5 
				)
                image:translate( centerX, centerY )

			elseif self.orientation == 'orthogonal' then

				local centerX, centerY = findCenter( points ) 
				image = display.newPolygon( 
					layer, 0, 0, unpackPoints( points ) 
				)	
				image.x, image.y = object.x, object.y
				image:translate( centerX, centerY )

			end				

	    else

	    	if self.orientation == 'isometric' then
	    		
	    		for i=1, #points do
		    	
			    	points[i].x, points[i].y = isoToScreen( 
			    		points[i].y / self.tile_height, 
			    		points[i].x / self.tile_height, 
			    		self.tile_width, 
			    		self.tile_height, 
			    		self.dim.height * self.tile_width * 0.5 
			    	)

				end	

				local centerX, centerY = findCenter( points ) 
				image = display.newLine( 
					layer, unpack( unpackPoints( points ) ) 
				)
				image.anchorSegments = true
				image.x, image.y = isoToScreen( 
					object.y / self.tile_height, 
					object.x / self.tile_height, 
					self.tile_width, 
					self.tile_height 
				)
				image:translate( centerX, centerY )

			elseif self.orientation == 'orthogonal' then 

				local centerX, centerY = findCenter( points ) 
				image = display.newLine( 
					layer, unpack( unpackPoints( points ) ) 
				)
				image.anchorSegments = true
				image.x, image.y     = object.x, object.y
				image:translate( centerX, centerY )

			end	

	    end

	elseif object.sprite then

		local tileset = { image = object.sprite }
		local image_sheet, frame_index = getImageSheet( self.image_cache, tileset )

		-- switch this to display.newImageRect later (see if it works?)
		image = display.newImage( layer, image_sheet, frame_index )  

		-- Apply base properties
	    image.anchorX, image.anchorY = 0,        0
	    image.x,       image.y       = object.x, object.y

	else

		image = display.newRect( layer, 0, 0, object.width, object.height )

		-- Apply base properties
	    image.anchorX, image.anchorY = 0,        0
	    image.x,       image.y       = object.x, object.y
	
	end

	if image then
		-- Name and type
		image.name = object.name
		image.type = object.type

		-- Apply base properties
		image.rotation  = object.rotation or 0
		image.isVisible = object.visible  or true

		-- If the map is already created these map_offsets will move your 
		-- object to be in synch with the map at the proper position
		local map_offset_x = self.x or 0
		local map_offset_y = self.y or 0

		image.x = image.x - map_offset_x
		image.y = image.y - map_offset_y

		centerAnchor( image )

		-- Flip it
		if flip.xy then

			print( 'Berry: Unsupported Tiled rotation x,y in ', image.name )

		else

			if flip.x then image.xScale = -1 end
			if flip.y then image.yScale = -1 end

		end

		if  findProperty( object.properties, 'hasBody' ) then 

			local params = inherit( {}, object.properties )
			physics.addBody( image, 'dynamic', params ) 

		end	

		inherit( image, layer.properties )
		inherit( image, object.properties )

	end	

end

--------------------------------------------------------------------------------
--- Sort objects on layers.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
function Map:sort()

	local function rightToLeft( a, b )

		return ( a.x or 0 ) + ( a.width or 0 ) * 0.5 > 
			   ( b.x or 0 ) + ( b.width or 0 ) * 0.5

	end

	local function upToDown( a, b )

		return ( a.y or 0 ) + ( a.height or 0 ) * 0.5 < 
			   ( b.y or 0 ) + ( b.height or 0 ) * 0.5 

	end

    for layer = 1, self.numChildren do

		local objects = {}    
		local layerToSort = self[layer] or {}

		if layerToSort.numChildren then 

			for i = 1, layerToSort.numChildren do

				objects[#objects + 1] = layerToSort[i]

			end

			table.sort( objects, rightToLeft )  
			table.sort( objects, upToDown )   

		end

		for i = #objects, 1, -1 do

			if objects[i].toBack then

			  objects[i]:toBack()

			end  

		end    

	end

end	

--------------------------------------------------------------------------------
--- Extend objects using modules with custom code.
--
-- @param table The list of types of objects to extend
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
function Map:extend( ... )
	
    local objectTypes = arg or {}

    for i = 1, #objectTypes do 

    	local extension = self.extensions or self.default_extensions

      -- Load each module based on type
		local plugin = require ( extension .. objectTypes[i] )

		-- Find each type of tiled object
		local images = self:getObjects( { type=objectTypes[i] } )

		if images then 

			-- Do we have at least one?
			for i = 1, #images do
				
				-- Extend the object with its own custom code
				images[i] = plugin.new( images[i] )

			end

		end  

    end

end 

--------------------------------------------------------------------------------
--- Add an object layer by name.
--
-- @param name The name of layer to add.
-- @return The added layer.
--------------------------------------------------------------------------------
function Map:addLayer( name ) 

	local layer = display.newGroup()

	layer.name = name

	-- These are the defaults
	layer.properties = {}
	layer.type = 'objectgroup'
	layer.alpha = 1
	layer.isVisible = true
	layer.offset_x = 0
	layer.offset_y = 0
	layer.objects = {}

	self:insert( layer )
	
	return layer

end  

--------------------------------------------------------------------------------
--- Find the layer by name.
--
-- @param name The name of layer.
-- @return The layer object if found.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
function Map:getLayer( name ) 

	local layer

	for i = 1, self.numChildren do

		layer = self[i]

		if layer.name == name then

			return layer

		end	

	end
		
end  

--------------------------------------------------------------------------------
--- Find the objects by name and type.
--
-- @param options The table which contains two fields name and type.
-- @return The table with found objects.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
function Map:getObjects( options ) 

	options = options or {}

	local name    = options.name
	local objType = options.type

	local objects, object, layer = {}

	for i = 1, self.numChildren do

		layer = self[i]

		for j = 1, layer.numChildren do

			object = layer[j]

			local has_name_match = ( name and object.name == name )
			local has_type_match = ( objType and object.type == objType)

			if name and objType then -- must match both

				if has_name_match and has_type_match then

					objects[#objects + 1] = object

				end

			else  -- must match one

				if has_name_match or has_type_match then

					objects[#objects + 1] = object

				end

			end	

		end	

	end

	return unpack( objects )

end  

return Map