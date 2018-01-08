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
-- File name: ObjectLayer.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class 	 = require 'pl.ldurniat.lib.30log-clean'
local Properties = require 'pl.ldurniat.Properties'
local Object     = require 'pl.ldurniat.Object'
local utils      = require 'pl.ldurniat.utils'

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local ObjectLayer = Properties:extend( 'ObjectLayer' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of an ObjectLayer object.
-- @param data The JSON data.
-- @param map The current Map object.
-- @return The newly created object layer.
function ObjectLayer:init( data, map )

	-- Make sure we have a properties table
	data.properties = data.properties or {}

	-- Add properties
	self.name = data.name
	self.objects = {}
    self.map = map
    self.data = data

    -- Name and type
    self.name = data.name
    self.type = data.type

    -- Add custom properties	
	for key, value in pairs( data.properties ) do
			
		self:setProperty( key, value )
	
	end

	local objects = data.objects

	for i=1, #objects do
			
		local data = objects[i]
		self.objects[#self.objects + 1] = Object( data, self.map, self )
	
	end

end

--- Get an object by its name. 
-- @param name The name of the Object to get.
-- @param objectType The type of the Object to get. Optional.
-- @return The found Object. nil if none found.
function ObjectLayer:getObject( name, objectType )

	for i=1, #self.objects, 1 do
		
		if name  then
			
			local object = nil
			
			if( self.objects[i].name == name ) then
				
				object = self.objects[i]
				
				if( objectType ) then -- Type specified to check that it is equal

					if(object.type == objectType) then

						return object

					end
				
				else -- No type specified so just return the object

					return object

				end
				
			end
			
		end
		
	end
	
	return nil
end

--- Get a list of objects by their name. 
-- @param name The name of the Objects to get.
-- @param objectType The type of the Objects to get. Optional.
-- @return A list of the found Objects. Empty if none found.
function ObjectLayer:getObjects( name, objectType )
	
	local objects = {}
		
	for i=1, #self.objects, 1 do
		
		if name  then
			
			local object = nil
			
			if self.objects[i].name == name then
				
				object = self.objects[i]
				
				if objectType then -- Type specified to check that it is equal

					if object.type == objectType  then

						objects[#objects + 1] = self.objects[i]

					end
				
				else -- No type specified so just return the object

					objects[#objects + 1] = self.objects[i]

				end
				
			end
			
		end
	end
	
	return objects
end


--- Gets a list of Objects on this ObjectLayer that have a specified property. 
-- @param name The name of the Property to look for.
-- @return A list of found Objects. Empty if none found.
function ObjectLayer:getObjectsWithProperty( name )

	local objects = {}
	
	for i = 1, #self.objects, 1 do

		if self.objects[i]:hasProperty( name ) then

			objects[#objects + 1] = self.objects[i]

		end

	end

	return objects
end

--- Gets a list of Objects on this ObjectLayer that have a certain name. 
-- @param name The name of the Object to look for.
-- @return A list of found Objects. Empty if none found.
function ObjectLayer:getObjectsWithName( name )

	local objects = {}
	
	for i = 1, #self.objects, 1 do

		if self.objects[i].name == name then

			objects[#objects + 1] = self.objects[i]

		end

	end

	return objects
end

--- Gets a list of Objects on this ObjectLayer that have a certain type. 
-- @param objectType - The type of the Object to look for.
-- @return A list of found Objects. Empty if none found.
function ObjectLayer:getObjectsWithType( objectType )

	local objects = {}
	
	for i = 1, #self.objects, 1 do

		if self.objects[i].type == objectType then

			objects[#objects + 1] = self.objects[i]

		end

	end

	return objects

end

--- Toggle visibility of the ObjectLayer.
function ObjectLayer:toggleVisibility()
	
	local visual = self:getVisual()

	if visual then

		visual.isVisible = not visual.isVisible

	end	
	
end

--- Shows the ObjectLayer.
function ObjectLayer:show()
	
	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = true

	end
	
end

--- Hides the ObjectLayer.
function ObjectLayer:hide()
	
	local visual = self:getVisual()
	
	if visual then

		visual.isVisible = false

	end
	
end

--- Gets the ObjectLayers visual.
function ObjectLayer:getVisual()

	return self.group

end

--- Moves the ObjectLayer.
-- @param x The amount to move the ObjectLayer along the X axis.
-- @param y The amount to move the ObjectLayer along the Y axis.
function ObjectLayer:move( x, y )

	utils:moveObject( self.group, x, y )

end

--- Sets the position of the ObjectLayer.
-- @param x The new X position of the ObjectLayer.
-- @param y The new Y position of the ObjectLayer.
function ObjectLayer:setPosition( x, y )

	if self.group then
	
			self.group.x = x
			self.group.y = y
	
	end
	
end

--- Sets the rotation of the ObjectLayer.
-- @param The new rotation.
function ObjectLayer:setRotation( angle )

	for i=1, #self.objects, 1 do 

		self.objects[i]:setRotation( angle )

	end

end

--- Rotates the ObjectLayer.
-- @param The angle to rotate by.
function ObjectLayer:rotate( angle )

	for i=1, #self.objects, 1 do 
	
		self.objects[i]:rotate(angle)
	
	end

end

--- Adds a displayObject to the layer. 
-- @param displayObject The displayObject to add.
-- @return The added displayObject.
function ObjectLayer:addObject( displayObject )

	return utils:addObjectToGroup( displayObject, self.group )

end

--- Destroy an object by its reference.
-- @param object The Object reference of the Object to destroy.
function ObjectLayer:destroyObject( object )
	
	for i=1, #self.objects, 1 do
	
	   if( self.objects[i] == object ) then

		   table.remove( self.objects, i )
		   object:destroy()
		   object = nil

	   end

	end

end

--- Creates the visual debug representation of the Object.
function ObjectLayer:create()

	if berry:isDebugModeEnabled() then

		print( 'Creating layer - ' .. self.name )

	end

	if not self.map.world then

		self.map.world = display.newGroup()

	end

	-- Display group used for visuals 
	if not self.group then

		self.group = display.newGroup()

	end

	-- Create objects
	for j=1, #self.objects, 1 do

		self.objects[j]:create()	

	end

	-- Apply base properties
	self.group.name = self.data.name
	self.group.isVisible = self.data.visible
	self.group.alpha = self.data.opacity

	for key, value in pairs( self.properties ) do

		self.map:firePropertyListener( self.properties[key], 'objectLayer', self )

	end

	self.map.world:insert( self.group )

end

--- Builds the physical representation of the ObjectLayer.
function ObjectLayer:build()

	if berry:isDebugModeEnabled() then

		print( 'Building Object Layer - ' .. self.name )

	end
	
	for i=1, #self.objects, 1 do
		
		if self.objects[i]:hasProperty( 'hasBody' ) then

			self.objects[i]:build()

		end
		
	end

end	

--- Completely removes all visual and physical objects associated with the ObjectLayer.
function ObjectLayer:destroy()

	if self.group and self.objects then
	
		for i=1, #self.objects, 1 do

			self.objects[i]:destroy()
			
		end
		
		self.objects = nil

		-- Remove group
		display.remove( self.group )
		self.group = nil
		
	end

end

return ObjectLayer	