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

local FlippedHorizontallyFlag = 0x80000000
local FlippedVerticallyFlag   = 0x40000000
local FlippedDiagonallyFlag   = 0x20000000

-- -------------------------------------------------------------------------- --
--                                  LOCAL VARIABLES                           --	
-- -------------------------------------------------------------------------- --

local imageSheets = {}

-- -------------------------------------------------------------------------- --
--									LOCAL FUNCTIONS	                          --
-- -------------------------------------------------------------------------- --

local function hasbit( x, p ) return x % ( p + p ) >= p end
local function setbit( x, p ) return hasbit( x, p ) and x or x + p end
local function clearbit( x, p ) return hasbit( x, p ) and x - p or x end

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

	local property

	for i=1, #properties do

		property = properties[i]
		object[property.name] = property.value

	end

	return object

end	

--------------------------------------------------------------------------------
-- Convert two-dimensional table to one-dimensional table and apply 
-- traslation/rotation.
--
-- @param points The two-dimensional table with x and y properties.
-- @param deltaX The value added to x coordinate.
-- @param deltaY The value added to y coordinate.
-- @param angle The value of rotation in degrees.
-- @return The one-dimensional table.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------
local function unpackPoints( points, deltaX, deltaY, angle )

	local listOfXY = {}
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

	local function translate( points, deltaX, deltaY ) 

		deltaX = deltaX or 0	
		deltaY = deltaY or 0

		for i=1, #points do

			x, y = points[i].x, points[i].y

			points[i].x = x + deltaX
			points[i].y = y + deltaY 
			
		end	

	end	

	-- All transformations are made in place
	rotate( points, angle )
	translate( points, deltaX, deltaY )

	for i = 1, #points do

		listOfXY[#listOfXY + 1] = points[i].x
		listOfXY[#listOfXY + 1] = points[i].y

	end

	return listOfXY

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
    local actualCenterX = ( bounds.xMin + bounds.xMax ) * 0.5
    local actualCenterY = ( bounds.yMin + bounds.yMax ) * 0.5

    object.anchorX, object.anchorY = 0.5, 0.5  
    object.x = actualCenterX
    object.y = actualCenterY

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
-- Load tileset.
--
-- @param tileset The object which contains information about tileset.
-- @param dir The directory to tileset.
-- @param tileId The id of tile.
-- @return The newly created image sheet.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------   
local function loadTileset( tileset, dir, tileId )

    if tileset.image then

    	local name = tileset.image

	    if not imageSheets[name] then	

			local tsiw,   tsih    = tileset.imagewidth, tileset.imageheight
			local margin, spacing = tileset.margin,     tileset.spacing
			local w,      h       = tileset.tilewidth,  tileset.tileheight

			local options = {
				frames             = {},
				sheetContentWidth  = tsiw,
				sheetContentHeight = tsih,
			}

			local frames = options.frames
			local tsh    = tileset.tilecount / tileset.columns 
			local tsw    = tileset.columns 

			for j=1, tsh do

			  for i=1, tsw do

			    local element = {
					x      = ( i - 1 ) * ( w + spacing ) + margin,
					y      = ( j - 1 ) *( h + spacing ) + margin,
					width  = w,
					height = h,
			    }

			    frames[#frames + 1] = element

			  end

			end

			imageSheets[name] = graphics.newImageSheet( dir .. name, options )

		end	

		return imageSheets[name], nil

	else

  		local tile
  		local tiles = tileset.tiles

  		for i=1, #tiles do

  			tile = tiles[i]

  			if tile.id == tileId then

  				return nil, dir .. tile.image, tile.imagewidth, tile.imageheight
  			
  			end	

  		end	

	end	

end

--------------------------------------------------------------------------------
--- Gets a Tile image from a GID.
--
-- @param gid The gid to use.
-- @param tilesets All tilesets.
-- @return The tileset at the gid location.
--------------------------------------------------------------------------------
local function getTilesetFromGID( gid, tilesets )
	
	for i = 1, #tilesets do

		local tileset  = tilesets[i]
		local firstgid = tileset.firstgid
		local lastgid  = tileset.lastgid

		if gid >= firstgid and gid <= lastgid then

			return tilesets[i]

		end

    end  

    return nil

end	

--------------------------------------------------------------------------------
-- Find GID for last element in tileset based on firstgids.
--
-- @param tileset The object which contains information about tileset.
-- @param nextTileset The object which contains information about tileset.
-- @return The number.
-- 
-- Original code from https://github.com/ponywolf/ponytiled 
--------------------------------------------------------------------------------    
local function findLastGID( tileset, nextTileset )

    local firstgid  = tileset.firstgid 
	local image     = tileset.image 
	local tiles     = tileset.tiles 
	local tilecount = tileset.tilecount
	local last      = firstgid

	if image then

  		return firstgid + tilecount - 1

	elseif tiles then

  		if nextTileset then

  			last = nextTileset.firstgid - 1

  		else

  			last = mHuge
  		end	

  	return last

	end  

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
-- @param tileId The id of tile.
-- @param tileset The object which contains information about tileset.
-- @return Multiple values.
--------------------------------------------------------------------------------  
local function retrieveShapeData( tileId, tileset )

	local tiles = tileset.tiles or {}
	local object, tile

	-- We need find proper tile since it stores information about shape
	for i=1, #tiles do

		tile = tiles[i]

		if tileId == tile.id then break end	

	end	

	if tile then

		local objectgroup = tile.objectgroup

		if objectgroup and objectgroup.objects and #objectgroup.objects > 0 then

			object = objectgroup.objects[1] 

			local notothershape = ( not object.ellipse and not object.polyline )
			if object.polygon or notothershape then
				
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
-- This creates a new display group with copied methods from a class
--
-- @param class The class to copy methods from
-- @return A display group with class methods.
--------------------------------------------------------------------------------  
local function setupDisplayGroup( class )
	local group = display.newGroup()

	-- Okay so normally this process is done via a metatable BUT 
	-- display groups already have a metatable setup when created
	-- making it a PIA.

	-- My solution is just a quick way to copy the methods from
	-- our Map class to our map display group (aka instance) 
	for name, method in pairs( class ) do group[name] = method end
	return group 

end
-- -------------------------------------------------------------------------- --
--                                  PUBLIC METHODS                            --	
-- -------------------------------------------------------------------------- --

--------------------------------------------------------------------------------
-- Create a new map object.
--
-- @param filename Name of map file.
-- @param tilesetsDirectory The path to tilesets.
-- @return The newly created map.
--------------------------------------------------------------------------------

function Map:new( filename, tilesetsDirectory )

	-- Read map file
	local path = system.pathForFile( filename, system.ResourceDirectory ) 
    local data = json.decodeFile( path )

	local map = setupDisplayGroup( self )

	map.tilesetsDirectory = tilesetsDirectory and tilesetsDirectory .. '/' or ''

    -- Purpose of computation here is simplification of code
    for i, tileset in ipairs( data.tilesets ) do

    	-- The tilesets are sorted always in ascending order by their firstgid
    	local nextTileset      = data.tilesets[i + 1]
    	tileset.lastgid        = findLastGID( tileset, nextTileset ) 
    	tileset.sequenceData   = buildSequences( tileset )

    end

    -- Apply properties from data
    map.tilesets     = data.tilesets
    map.orientation  = data.orientation			
    map.staggeraxis  = data.staggeraxis
    map.staggerindex = data.staggerindex
    map.tilewidth    = data.tilewidth
    map.tileheight   = data.tileheight

	
	for _, info in ipairs( data.layers ) do

		local layer = display.newGroup() 

		-- Apply properties from info
	    layer.name       = info.name
	    layer.type       = info.type
	    layer.alpha      = info.opacity
	    layer.isVisible  = info.visible
		layer.offset_x   = info.offsetx or 0
		layer.offset_y   = info.offsety or 0
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

	-- Add useful properties
    map.defaultExtensions = 'berry.plugins.'
    map.tilewidth         = data.tilewidth
    map.tileheight        = data.tileheight
    map.designedWidth     = data.width  * data.tilewidth
    map.designedHeight    = data.height * data.tileheight

    -- Center map
    map.x = display.contentCenterX - map.designedWidth * 0.5
    map.y = display.contentCenterY - map.designedHeight * 0.5

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
	local tileset = getTilesetFromGID( gid, self.tilesets )

	if tileset then

		local image 
		local firstgid, tileId = tileset.firstgid,  gid - tileset.firstgid
		local width,    height = tileset.tilewidth, tileset.tileheight 
		
		local imageSheet, pathToImage, imagewidth, imageheight = loadTileset( 
			tileset, self.tilesetsDirectory, tileId )

		if imageSheet then

			image = display.newImageRect( layer, imageSheet, 
										  tileId + 1, width, height )

		else 
          	
          	image = display.newImageRect( layer, pathToImage, 
          								  imagewidth, imageheight )

		end	

		if image then

			-- The first element from layer.data start at row=1 and column=1
			image.row    = mFloor( ( position + layer.size - 1 ) / layer.size )
			image.column = position - ( image.row - 1 ) * layer.size

			-- Apply basic properties
			image.anchorX, image.anchorY = 0, 1

			if self.orientation == 'isometric' then

				image.x = ( -1 * image.row * self.tilewidth / 2 ) + 
						  ( image.column * self.tilewidth / 2 )

				image.y = ( image.column * self.tileheight / 2) - 
						  ( -1 * image.row * self.tileheight / 2)

			elseif self.orientation == 'staggered' then

		    	local staggered_offset_y = ( self.tileheight / 2 )
		    	local staggered_offset_x = ( self.tilewidth / 2 )

		    	if self.staggeraxis == 'y' then

		    		if self.staggerindex == 'odd' then

		    			if image.row % 2 == 0 then

		    				image.x = ( image.column * self.tilewidth ) + 
		    							staggered_offset_x

		    			else

		    				image.x = ( image.column * self.tilewidth )

		    			end

		    		else

		    			if image.row % 2 == 0  then

		    				image.x = ( image.column * self.tilewidth )

						else

		    				image.x = ( image.column * self.tilewidth ) + 
		    							staggered_offset_x

						end

		    		end

		    		image.y = ( 
		    					image.row * 
		    				    ( self.tileheight - self.tileheight / 2 ) 
		    				  )

		    	else

		    		if self.staggerindex == 'odd' then

		    			if image.column % 2 == 0  then

		    				image.y = ( image.row * self.tileheight ) + 
		    							staggered_offset_y

		    			else

		    				image.y = ( image.row * self.tileheight )

		    			end

		    		else

		    			if image.column % 2 == 0  then

		    				image.y = ( image.row * self.tileheight )

						else

		    				image.y = ( image.row * self.tileheight ) + 
		    							staggered_offset_y

						end

		    		end

		    		image.x = ( 
		    					image.column * 
		    					( self.tilewidth - self.tilewidth / 2 ) 
		    				  )

		    	end

			elseif self.orientation == 'orthogonal' then

				image.x = ( image.column - 1 ) * self.tilewidth
				image.y = image.row * self.tileheight

			end

			-- If the map is already created these map_offsets will move your 
			-- object to be in synch with the map at the proper position
			local map_offset_x = self.x or 0
			local map_offset_y = self.y or 0

			image.x = image.x + layer.offset_x - map_offset_x
			image.y = image.y + layer.offset_y - map_offset_y

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
	    flip.x  = hasbit( object.gid, FlippedHorizontallyFlag )
	    flip.y  = hasbit( object.gid, FlippedVerticallyFlag )          
	    flip.xy = hasbit( object.gid, FlippedDiagonallyFlag )

	    object.gid = clearbit( object.gid, FlippedHorizontallyFlag )
	    object.gid = clearbit( object.gid, FlippedVerticallyFlag )
	    object.gid = clearbit( object.gid, FlippedDiagonallyFlag )

		-- Get the correct tileset using the GID
		tileset = getTilesetFromGID( object.gid, self.tilesets )

		if tileset then

			local firstgid      		  = tileset.firstgid
			local tileId 				  = object.gid - tileset.firstgid
			local width,      height      = object.width, object.height
			local imageSheet, pathToImage = loadTileset( 
												tileset, 
												self.tilesetsDirectory, 
												tileId ) 

			if imageSheet then

				if findProperty( layer.properties, 'isAnimated' ) or 
				   findProperty( object.properties, 'isAnimated' ) then

					image = display.newSprite( layer, 
											   imageSheet, 
											   tileset.sequenceData )

				else

					image = display.newImageRect( layer, imageSheet, 
												  tileId + 1, width, height )

				end
					
			else 

				image = display.newImageRect( layer, pathToImage, 
											  width, height ) 

			end

			local points, x, y, rotation  = retrieveShapeData( tileId, tileset )

			-- Add collsion shape
			if points then

				local deltaX = x - image.width * 0.5 
				local deltaY = y - image.height * 0.5 

				points = unpackPoints( points, deltaX, deltaY, rotation )

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

			-- Apply base properties
			image.anchorX, image.anchorY = 0, 1
			image.x, image.y             = object.x, object.y
			image.tileId                 = tileId
			image.gid                    = object.gid

		end	

	elseif object.polygon or object.polyline then 
		local points = object.polygon or object.polyline

		local xMax, xMin, yMax, yMin = -mHuge, mHuge, -mHuge, mHuge 

		for i = 1, #points do

			if points[i].x < xMin then xMin = points[i].x end  
			if points[i].y < yMin then yMin = points[i].y end 
			if points[i].x > xMax then xMax = points[i].x end   
			if points[i].y > yMax then yMax = points[i].y end  

    	end

		local centerX, centerY = ( xMax + xMin ) * 0.5, ( yMax + yMin ) * 0.5

	    if object.polygon then 
			
			image = display.newPolygon( layer, object.x, 
										object.y, unpackPoints( points ) )	

	    else

			image = display.newLine( layer, unpack( unpackPoints( points ) ) )
			image.anchorSegments = true
			image.x, image.y     = object.x, object.y

	    end

	    image:translate( centerX, centerY )

	elseif object.sprite then
		local sheet_info = object.imageSheetInfo
		local imageSheet = graphics.newImageSheet( object.image, 
												   sheet_info:getSheet() )

		-- switch this to display.newImageRect later (see if it works?)
		image = display.newImage( layer, imageSheet, 
								  sheet_info:getFrameIndex( object.name ))  

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

		image.x = image.x + layer.offset_x - map_offset_x
		image.y = image.y + layer.offset_y - map_offset_y

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

    	local extension = self.extensions or self.defaultExtensions

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