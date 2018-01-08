----------------------------------------------------------------------------------------------------
---- Lime - 2D Tile Engine for Corona SDK. (Original author: Graham Ranson)
---- http://OutlawGameTools.com
---- Copyright 2013 Three Ring Ranch
---- The MIT License (MIT) (see LICENSE.txt for details)
----------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------
---- Berry - 2D Tile Engine for Corona SDK. 
---- Author: Łukasz Durniat
----------------------------------------------------------------------------------------------------
--
-- Date: Jan-2018
--
-- Version: 3.5
-- File name: TileSet.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class      = require 'pl.ldurniat.lib.30log-clean'
local Property   = require 'pl.ldurniat.Property'
local Properties = require 'pl.ldurniat.Properties'
local utils      = require 'pl.ldurniat.utils'

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local TileSet = Properties:extend( 'TileSet' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

-- Code borrowed from Ponytiled
-- https://github.com/ponywolf/ponytiled    
local function loadTileset( directory, tileset )

	local tsiw, tsih = tileset.imagewidth, tileset.imageheight
	local margin, spacing = tileset.margin, tileset.spacing
	local w, h = tileset.tilewidth, tileset.tileheight
	local gid = 0

	local options = {
	  frames = {},
	  sheetContentWidth =  tsiw,
	  sheetContentHeight = tsih,
	}

	local frames = options.frames
	local tsh = tileset.tilecount / tileset.columns 
	local tsw = tileset.columns 

	for j=1, tsh do

	  for i=1, tsw do

	    local element = {
	      x = ( i - 1 ) * ( w + spacing ) + margin,
	      y = ( j - 1 ) *( h + spacing ) + margin,
	      width = w,
	      height = h,
	    }
	    gid = gid + 1
	    table.insert( frames, gid, element )

	  end

	end

	return graphics.newImageSheet( directory .. tileset.image, options )

end

-- Code borrowed from Ponytiled
-- https://github.com/ponywolf/ponytiled    
local function findLastGID( tileset )

	local last = tileset.firstgid

	if tileset.image then

  		return tileset.firstgid + tileset.tilecount - 1

	elseif tileset.tiles then

  		for k,v in pairs( tileset.tiles ) do

    		if tonumber( k ) + tileset.firstgid > last then

      			last = tonumber( k ) + tileset.firstgid

    		end

  		end

  	return last

	end  

end

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of a TileSet object.
-- @param data The JSON data.
-- @param directory The root dir of the tileset image. Optional.
-- @return The newly created TileSet instance.
function TileSet:init( data, directory )

    -- Make sure we have a properties table
	data.tileproperties = data.tileproperties or {}
	data.properties = data.properties or {}
    data.tiles = data.tiles or {}

	-- Add properties
    self.name = data.name
    self.directory = directory or ''
    self.firstgid = data.firstgid
    self.lastgid = findLastGID( data )
    self.tiles = data.tiles or {}
    self.tilewidth = data.tilewidth
    self.tileheight = data.tileheight
    self.tileProperties = {}
    self.tileCollisionShapes = {}
    self.tileSequencesData = {}

    -- Add custom properties for TileSet	
	for key, value in pairs( data.properties ) do self:setProperty( key, value ) end

    -- Store custom properties for Tiles
    for tileid, tileData in pairs( data.tileproperties ) do

    	for key, value in pairs( tileData ) do

    		if not self.tileProperties[tileid + 1]  then self.tileProperties[tileid + 1] = {} end

    		self.tileProperties[tileid + 1][#self.tileProperties[tileid + 1] + 1] = Property( key, value )
    	
    	end	

    end

    -- Add more information for Tiles
    for tileid, tileData in pairs( data.tiles ) do
    	local shapeLayer = tileData.objectgroup

    	if shapeLayer then
    		local shapes = shapeLayer.objects

    		-- Add collision shape for Tile
    		if shapes and #shapes > 0 then self.tileCollisionShapes[tileid + 1] = shapes[1] end	

    	end

    	-- Create animation sequences for Tiles
    	if tileData.animation then 
    		local tileProperties = data.tileproperties[tileid] or {}
    		 
    		local frames = {} 
    		for i=1, #tileData.animation do frames[#frames + 1] = tileData.animation[i].tileid + 1 end

    		local sequence = {
    			frames = frames,
    			time = tileProperties.time or 700,
    			name = tileProperties.name or tostring( tileid + 1 ),
    			loopCount = tileProperties.loopCount or 0,
    			loopDirection = tileProperties.loopDirection or 'forward',
    		}

    		self.tileSequencesData[#self.tileSequencesData + 1] = sequence

    	end	

    end	

    -- Load image sheet
	if data.image then self.imageSheet = loadTileset( self.directory, data ) end

end

--- Gets a list of Properties on a Tile.
-- @param id The id of the Tile.
-- @return A table with a list of properties for the tile or an empty table.
function TileSet:getPropertiesForTile( id )
	
	return self.tileProperties[id] or {}

end

--- Gets a list of Collision Shape on a Tile.
-- @param id The id of the Tile.
-- @return A table with a list of collsion shape for the tile or nil.
function TileSet:getCollisionShapeForTile( id )
	
	return self.tileCollisionShapes[id]

end

--- Gets a list of all sequences from whole tileset.
-- @return A table with a list sequences.
function TileSet:getSequencesData()
	
	return self.tileSequencesData 

end

--- Completely removes the TileSet.
function TileSet:destroy()

    -- I don't sure I have to do this
	--display.remove( self.imageSheet )
	
	self.imageSheet = nil

end

return TileSet