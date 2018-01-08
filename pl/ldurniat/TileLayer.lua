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
--
-- File name: TileLayer.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class      = require 'pl.ldurniat.lib.30log-clean'
local Properties = require 'pl.ldurniat.Properties'
local Tile       = require 'pl.ldurniat.Tile'
local utils      = require 'pl.ldurniat.utils'

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local TileLayer = Properties:extend( 'TileLayer' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of a TileLayer object.
-- @param data The XML data.
-- @param map The current Map object.
-- @return The newly created tileLayer.
function TileLayer:init( data, map )

	if data.compression or data.encoding then

        print ( 'ERROR: Tile layer encoding/compression not supported. Choose CSV or XML in map options.' )

    end

    -- Make sure we have a properties table
    data.properties = data.properties or {}

	local tileIDs = data.data
	local DUMB_TILE = Tile( { gid=0 }, map, self )

	-- Add properties
	self.name = data.name
    self.map = map
    self.data = data
    self.tiles = {}
    self.width = data.width 
    self.height = data.height 

    -- Add custom properties	
	for key, value in pairs( data.properties ) do
			
		self:setProperty( key, value )
	
	end

	-- Add tiles
	for i = 1, #tileIDs do
		local data = {}
		data.gid = tileIDs[i]
		data.index = i
		
		if data.gid > 0 then

			self.tiles[i] = Tile( data, map, self )

		else 
			-- Use the same tile for all blank sections
			self.tiles[i] = DUMB_TILE

		end		

	end

end

--- Toggle visibility of the TileLayer.
function TileLayer:toggleVisibility()
	
	local visual = self:getVisual()

	if visual then

		visual.isVisible = not visual.isVisible

	end	
	
end

--- Shows the TileLayer.
function TileLayer:show()
	
	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = true

	end

end

--- Hides the TileLayer.
function TileLayer:hide()
	
	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = false

	end
	
end

--- Gets the TileLayers visual.
function TileLayer:getVisual()

	return self.group
	
end

--- Gets a list of Tiles on this TileLayer that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found Tiles. Empty if none found.
function TileLayer:getTilesWithProperty( name )

	local allTiles = self.tiles
	
	local tiles = {}
	
	for i = 1, #allTiles, 1 do

		if allTiles[i]:hasProperty( name ) then

			tiles[#tiles + 1] = allTiles[i]

		end

	end

	return tiles

end

--- Adds a display object to the layer. 
-- @param displayObject The display object to add.
-- @return The added display object.
function TileLayer:addObject( displayObject )

	return utils:addObjectToGroup( displayObject, self.group )

end

--- Sets the position of the TileLayer.
-- @param x The new X position of the TileLayer.
-- @param y The new Y position of the TileLayer.
function TileLayer:setPosition( x, y )

	if self.group then
	
			self.group.x = x
			self.group.y = y
	
	end
	
end

--- Moves the TileLayer.
-- @param x The amount to move the ObjectLayer along the X axis.
-- @param y The amount to move the ObjectLayer along the Y axis.
function TileLayer:move( x, y )

	utils:moveObject( self.group, x, y )

end

--- Sets the rotation of the TileLayer.
-- @param The new rotation.
function TileLayer:setRotation( angle )

	for i=1, #self.tiles, 1 do 

		self.tiles[i]:setRotation( angle )

	end

end

--- Rotates the TileLayer.
-- @param The angle to rotate by.
function TileLayer:rotate( angle )

	for i=1, #self.tiles, 1 do 
	
		self.tiles[i]:rotate(angle)
	
	end

end

--- Creates the visual representation of the layer.
-- @return The group containing the newly created layer.
function TileLayer:create()

	if berry:isDebugModeEnabled() then

		print( 'Creating layer - ' .. self.name )

	end

	if not self.map.world then

		self.map.world = display.newGroup()

	end
	
	self.group = display.newGroup()

	-- Create tiles
	for i=1, #self.tiles do

		tile = self.tiles[i]

		tile:create( i )

	end	

	-- Apply base properties
	self.group.name = self.name
	self.group.isVisible = self.data.visible
	self.group.alpha = self.data.opacity

	for key, value in pairs( self.properties ) do

		self.map:firePropertyListener( self.properties[key], 'layer', self )

	end

	self.map.world:insert( self.group )

end	

--- Builds the physical representation of the TileLayer.
function TileLayer:build()

	if berry:isDebugModeEnabled() then

		print( 'Building Tile Layer - ' .. self.name )

	end
	
	for i=1, #self.tiles, 1 do
		
		if self.tiles[i]:hasProperty( 'hasBody' ) then
			
			self.tiles[i]:build()

		end
		
	end

end	

--- Completely removes all visual and physical objects associated with the TileLayer.
function TileLayer:destroy()

	if self.group and self.tiles then
	
		for i=1, #self.tiles, 1 do

			self.tiles[i]:destroy()
			
		end
		
		self.tiles = nil
		
		-- Remove group
		display.remove( self.group )
		self.group = nil
		
	end

end

return TileLayer	