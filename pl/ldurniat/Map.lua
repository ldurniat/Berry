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
-- File name: Map.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class 	  = require 'pl.ldurniat.lib.30log-clean'
local Properties  = require 'pl.ldurniat.Properties'
local TileSet     = require 'pl.ldurniat.TileSet'
local ObjectLayer = require 'pl.ldurniat.ObjectLayer'
local TileLayer   = require 'pl.ldurniat.TileLayer'
local utils       = require 'pl.ldurniat.utils'
local json        = require 'json' 

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local Map = Properties:extend( 'Map' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

local abs = math.abs 
local floor = math.floor

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of a Map object.
-- @param filename
-- @param tileSetsDirectory
-- @return The newly created Map instance.
function Map:init( filename, tileSetsDirectory )

	if berry:isDebugModeEnabled() then

		print( 'Loading Map - ' .. filename )

	end
    
    -- Read map file
    local data = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )

    -- Add properties
    self.header = {}   
    self.tileSets = {}
    self.tileLayers = {}
    self.objectLayers = {}
    self.layers = {}
    self.objectListeners = {}
    self.propertyListeners = {}
    self.filename = filename
    self.tileSetsDirectory = tileSetsDirectory and tileSetsDirectory .. '/' or ''
    self.defaultExtensions = 'berry.plugins.'
    self.data = data
    self.tilewidth = data.tilewidth
    self.tileheight = data.tileheight
    self.designedWidth, self.designedHeight = data.width * data.tilewidth, data.height * data.tileheight

	local tileLayer, tileSet, objectLayer

	-- Add custom properties	
	data.properties = data.properties or {}
	for key, value in pairs( data.properties ) do
			
		self:setProperty( key, value )
	
	end

	-- Load In Map Items 
	for i=1, #data.tilesets do

		local tileSet = TileSet( data.tilesets[i], self.tileSetsDirectory )

		self.tileSets[#self.tileSets + 1] = tileSet

		if berry:isDebugModeEnabled() then

			print( 'Loaded TileSet - ' .. tileSet.name )

		end

	end 

	for i=1, #data.layers do

		local layer = data.layers[i]

		if layer.type == 'objectgroup' then
			
			local objectLayer = ObjectLayer( layer, self )
			self.objectLayers[#self.objectLayers + 1] = objectLayer
			self.layers[#self.layers + 1] = objectLayer

			if berry:isDebugModeEnabled() then

				print( 'Loaded Object Layer - ' .. objectLayer.name )

			end

		elseif layer.type == 'tilelayer' then

			local tileLayer = TileLayer( layer, self )
			self.tileLayers[#self.tileLayers + 1] = tileLayer
			self.layers[#self.layers + 1] = tileLayer

			if berry:isDebugModeEnabled() then

				print( 'Loaded Tile Layer - ' .. tileLayer.name )

			end

		end	

	end 

	return self

end

--- Gets a TileLayer.
-- @param indexOrName The index or name of the TileLayer to get.
-- @return The tile layer at indexOrName.
function Map:getTileLayer( indexOrName )
	
	if type( indexOrName ) == 'number' then
		
		return self.tileLayers[indexOrName]
		 
	elseif type( indexOrName ) == 'string' then
		
		for i=1, #self.tileLayers, 1 do 
			
			if self.tileLayers[i].name == indexOrName then

				return self.tileLayers[i]
			
			end
			
		end
		
	end
	
end

--- Gets an ObjectLayer.
-- @param indexOrName The index or name of the ObjectLayer to get.
-- @return The object layer at indexOrName.
function Map:getObjectLayer( indexOrName )
	
	if type( indexOrName ) == 'number' then
		
		return self.objectLayers[indexOrName]
		 
	elseif type( indexOrName ) == 'string' then
		
		for i=1, #self.objectLayers, 1 do 
			
			if self.objectLayers[i].name == indexOrName then

				return self.objectLayers[i]
			
			end
			
		end
		
	end
	
end

--- Gets a list of TileLayers across the map that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found TileLayer. Empty if none found.
function Map:getTileLayersWithProperty( name )

	local tileLayers = {}
	
	for i = 1, #self.tileLayers, 1 do
		
		if self.tileLayers[i]:hasProperty( name ) then

			tileLayers[#objectLayers + 1] = self.tileLayers[i]

		end
	end

	return tileLayers
	
end

--- Gets a list of ObjectLayers across the map that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found ObjectLayer. Empty if none found.
function Map:getObjectLayersWithProperty( name )

	local objectLayers = {}
	
	for i = 1, #self.objectLayers, 1 do
		
		if self.objectLayers[i]:hasProperty( name ) then

			objectLayers[#objectLayers + 1] = self.objectLayers[i]

		end
	end

	return objectLayers
	
end

--- Gets a TileSet.
-- @param indexOrName The index or name of the TileSet to get.
-- @return The tileset at indexOrName.
function Map:getTileSet( indexOrName )

	if type( indexOrName ) == 'number' then
		
		return self.tileSets[indexOrName]
		 
	elseif type( indexOrName ) == 'string' then
		
		for i=1, #self.tileSets, 1 do 
			
			if self.tileSets[i].name == indexOrName then

				return self.tileSets[i]

			end
			
		end
		
	end
	
end

--- Gets a property value from a tileset.
--	Originally created by FrankS - http://developer.anscamobile.com/forum/2011/02/19/additional-convenience-functions-navigate-lime-world-tree
-- @param gid The gid of the tile to check.
-- @param name The name of the property to look for.
-- @return The value of the property. Nil if none found.
function Map:getTilePropertyValueForGID( gid, name )

	local properties = self:getTilePropertiesForGID( gid )

	for i = 1, #properties, 1 do
		
		if properties[i]:getName() == name then
			
			return properties[i]:getValue()
		
		end
	
	end

end

--- Gets the tile properties for a tile 
-- @param gid The gid of the tile to check
-- @return the set of properties for that tile or {}
function Map:getTilePropertiesForGID( gid )

	local tileSet = self:getTileSetFromGID( gid )

	if tileSet then

		return tileSet:getPropertiesForTile( gid - tileSet.firstgid + 1 )

	end

	return {}

end

--- Gets a Tile image from a GID.
-- Fixed fantastically by FrankS - http://developer.anscamobile.com/forum/2011/02/18/bug-mapgettilesetfromgidgid
-- @param gid The gid to use.
-- @return The tileset at the gid location.
function Map:getTileSetFromGID( gid )
	
	for i = 1, #self.tileSets do

		local tileSet = self.tileSets[i]
		local firstgid = tileSet.firstgid
		local lastgid = tileSet.lastgid

		if gid >= firstgid and gid <= lastgid then

			return self.tileSets[i]

		end

    end  

    return nil

end	

--- Shows the Map.
function Map:show()

	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = true

	end

end

--- Hides the Map.
function Map:hide()

	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = false

	end
	
end

--- Gets the Maps visual.
function Map:getVisual()

	return self.world

end

--- Moves the Map.
-- @param x The amount to move the Map along the X axis.
-- @param y The amount to move the Map along the Y axis.
function Map:move( x, y )
	
	if self.world then
	
		utils:moveObject( self.world, x, y )
		
	end
	
end

--- Sets the rotation of the Map.
-- @param angle The new rotation.
function Map:setRotation( angle )

	for i=1, #self.tileLayers, 1 do 

		self.tileLayers[i]:setRotation( angle )

	end
	
	for i=1, #self.objectLayers, 1 do 

		self.objectLayers[i]:setRotation( angle )

	end
	
end

--- Rotates the Map.
-- @param angle The angle to rotate by.
function Map:rotate( angle )

	for i=1, #self.tileLayers, 1 do 

		self.tileLayers[i]:rotate( angle )

	end
	
	for i=1, #self.objectLayers, 1 do 

		self.objectLayers[i]:rotate( angle )

	end
	
end

--- Sets the scale of the Map.
-- @param xScale The new scale of the map by in the X direction.
-- @param yScale The new scale of the map by in the Y direction. Leave nil to set X and Y as the first paramater.
function Map:setScale( xScale, yScale )

	if self.world then

		self.world.xScale = xScale or 1
		self.world.yScale = yScale or self.world.xScale 

	end
	
end

--- Scales the Map.
-- @param xScale The amount to scale the map by in the X direction.
-- @param yScale The amount to scale the map by in the Y direction. Leave nil to scale X and Y as the first paramater.
function Map:scale( xScale, yScale )

	if self.world then

		self.world.xScale = self.world.xScale + ( xScale or 0 )
		self.world.yScale = self.world.yScale + ( yScale or xScale or 0 )

	end
	
end

--- Gets the scale of the Map.
-- @return The X scale of the Map.
-- @return The Y scale of the Map.
function Map:getScale()

	if self.world then

		return self.world.xScale, self.world.yScale

	end

end

--- Sets the position of the Map.
-- @param x The new X position of the Map.
-- @param y The new Y position of the Map.
function Map:setPosition( x, y )

	if self.world then

		self.world.x = x
		self.world.y = y
		
	end	

end

--- Gets the position of the Map.
-- @return The X position of the Map.
-- @return The Y position of the Map.
function Map:getPosition()

	if self.world then
	
		return self.world.x, self.world.y
		
	end

end

--- Gets a list of Tiles across all TileLayers that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found Tiles. Empty if none found.
function Map:getTilesWithProperty( name )

	local tiles = {}
	
	local tileLayers = {}
	
	for i = 1, #self.tileLayers, 1 do
		
		tileLayers = self.tileLayers[i]:getTilesWithProperty( name )
		
		for j = 1, #tileLayers, 1 do

			tiles[#tiles + 1] = tileLayers[j]

		end

	end

	return tiles
end

--- Gets a list of Objects across all ObjectLayers that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found Objects. Empty if none found.
function Map:getObjectsWithProperty( name )

	local objects = {}
	
	local objectLayers = {}
	
	for i = 1, #self.objectLayers, 1 do
		
		objectLayers = self.objectLayers[i]:getObjectsWithProperty( name )
		
		for j = 1, #objectLayers, 1 do

			objects[#objects + 1] = objectLayers[j]

		end

	end

	return objects
end

--- Gets a list of Objects across all ObjectLayers that have a specified name. 
-- @param name The name of the Objects to look for.
-- @return A list of found Objects. Empty if none found.
function Map:getObjectsWithName( name )

	local objects = {}
	
	local objectLayers = {}
	
	for i = 1, #self.objectLayers, 1 do
		
		objectLayers = self.objectLayers[i]:getObjectsWithName( name )
		
		for j = 1, #objectLayers, 1 do

			objects[#objects + 1] = objectLayers[j]

		end

	end

	return objects

end

--- Gets a first Object across all ObjectLayers that have a specified name. 
-- @param name The name of the Object to look for.
-- @return A found Object. False if none found.
function Map:getObjectWithName( name )
	
	for i = 1, #self.objectLayers, 1 do
		
		object = self.objectLayers[i]:getObject( name )
		
		if object then

			return object
		end	

	end

	return false

end

--- Gets a list of Objects across all ObjectLayers that have a specified type. 
-- @param objectType The type of the Objects to look for.
-- @return A list of found Objects. Empty if none found.
function Map:getObjectsWithType( objectType )

	local objects = {}
	
	local objectLayers = {}
	
	for i = 1, #self.objectLayers, 1 do
		
		objectLayers = self.objectLayers[i]:getObjectsWithType( objectType )
		
		for j = 1, #objectLayers, 1 do

			objects[#objects + 1] = objectLayers[j]

		end

	end

	return objects

end

--- Adds a displayObject to the world. 
-- @param displayObject The displayObject to add.
-- @return The added displayObject.
function Map:addObject( displayObject )

	return utils:addObjectToGroup( displayObject, self.world )

end

--- Adds an Object listener to the Map.
-- @param objectType The type of Object to listen for.
-- @param listener The listener function.
function Map:addObjectListener( objectType, listener )
	
	if objectType and listener then

		if not self.objectListeners[objectType]  then

			self.objectListeners[objectType] = {} 

		end

		self.objectListeners[objectType][#self.objectListeners[objectType] + 1] = listener
		
	end
	
end

--- Gets a table containing all the object listeners that have been added to the Map.
-- @return The object listeners.
function Map:getObjectListeners()

	return self.objectListeners

end

--- Adds a Property listener to the Map.
-- @param propertyName The name of the Property to listen for.
-- @param listener The listener function.
function Map:addPropertyListener( propertyName, listener )
	if propertyName and listener then

		if not self.propertyListeners[propertyName] then

			self.propertyListeners[propertyName] = {} 

		end
		
		self.propertyListeners[propertyName][#self.propertyListeners[propertyName] + 1] = listener
	end		
end

--- Gets a table containing all the property listeners that have been added to the Map.
-- @return The property listeners.
function Map:getPropertyListeners()

	return self.propertyListeners

end

--- Fires an already added property listener.
-- @param property The property object that was hit.
-- @param propertyType The type of the property object. 'map', 'tileLayer', 'objectLayer', 'tile', 'object'.
-- @param object The object that has the property.
function Map:firePropertyListener( property, propertyType, object )
	
	local listeners = self.propertyListeners[property.name] or {}
	
	for i=1, #listeners, 1 do

		listeners[i]( property, propertyType, object )

	end

end

--- Fires an already added object listener
-- @param object The object that the listener was waiting for.
function Map:fireObjectListener( object )

	local listeners = self.objectListeners[object.type] or {}
			
	for i=1, #listeners, 1 do

		listeners[i]( object )

	end

end	

--- Sort the objects on layers.
-- https://github.com/ponywolf
function Map:sort()

	local function rightToLeft( a, b )

		return ( a.x or 0 ) + ( a.width or 0 ) * 0.5 > ( b.x or 0 ) + ( b.width or 0 ) * 0.5

	end

	local function upToDown( a, b )

		return ( a.y or 0 ) + ( a.height or 0 ) * 0.5 < ( b.y or 0 ) + ( b.height or 0 ) * 0.5 

	end

    for layer = 1, self.world.numChildren do

		local objects = {}    
		local layerToSort = self.world[layer] or {}

		if layerToSort.numChildren then 

			for i = 1, layerToSort.numChildren do

				objects[#objects+1] = layerToSort[i]

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

--- Extend Objects using modules with custom code.
-- @param The list of types of objects to extend
-- https://github.com/ponywolf
function Map:extendObjects( ... )

    local objectTypes = arg or {}

    -- each custom object above has its own ponywolf.plugin module
    for i = 1, #objectTypes do 

      -- load each module based on type
		local plugin = require ( ( self.extensions or self.defaultExtensions ) .. objectTypes[i] )

		-- find each type of tiled object
		local images = self:getObjectsWithType( objectTypes[i] )

		if images then 

			-- do we have at least one?
			for i = 1, #images do
				
				-- extend the object with its own custom code
				images[i] = plugin.new( images[i] )

			end

		end  

    end

end    

--- Creates the visual representation of the map.
-- @return The newly created world a visual representation of the map.
function Map:create()

	self.world = display.newGroup()
	
	for i=1, #self.layers, 1 do

		self.layers[i]:create()
			
	end	
	
	for key, value in pairs( self.properties ) do

		self:firePropertyListener( self.properties[key], 'map', self )

	end

	-- Set the background color to the map background
	display.setDefault( 'background', utils:decodeTiledColor( self.data.backgroundcolor ) )

	-- Center map on the screen
	self.world.x =  display.contentCenterX - self.designedWidth * 0.5
	self.world.y =  display.contentCenterY - self.designedHeight * 0.5

	-- Show layers/objects in right order
	self:sort()

	return self.world

end	

--- Builds the physical representation of the Map.
function Map:build()
	local physics = require( 'physics' )

	physics.start()

	-- Set gravity force
	local gravityX, gravityY = physics.getGravity()
	physics.setGravity( self:getPropertyValue( 'gravityX' ) or gravityX, self:getPropertyValue( 'gravityY' ) or gravityY )

	-- Set scale
	physics.setScale( self:getPropertyValue( 'scale') or 30 )

	-- Set draw mode
	physics.setDrawMode( self:getPropertyValue( 'drawMode' ) or 'normal' )

	for i=1, #self.objectLayers, 1 do

		self.objectLayers[i]:build()

	end
	
	for i=1, #self.tileLayers, 1 do

		self.tileLayers[i]:build()

	end	

	if berry:isDebugModeEnabled() then

		print( 'Map Built - ' .. self.filename )

	end

end	

--- Completely removes all visual and physical objects associated with the Map.
function Map:destroy()

	if self.world then
		
		for i=1, #self.tileLayers, 1 do

			self.tileLayers[i]:destroy()

		end
		
		for i=1, #self.objectLayers, 1 do

			self.objectLayers[i]:destroy()

		end
		
		for i=1, #self.tileSets, 1 do

			self.tileSets[i]:destroy()

		end
		
		-- Remove group
		display.remove( self.world )
		self.world = nil

	end

end

return Map	