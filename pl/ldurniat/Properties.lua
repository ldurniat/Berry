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
-- File name: Properties.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class    = require 'pl.ldurniat.lib.30log-clean'
local Property = require 'pl.ldurniat.Property'

----------------------------------------------------------------------------------------------------
----									CLASS					   								----
----------------------------------------------------------------------------------------------------

local Properties = class( 'Properties', { properties = {} } )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Sets the value of a Property of the Object. Will create a new Property if none found.
-- @param name The name of the Property.
-- @param value The new value.
-- @return
function Properties:setProperty( name, value )
	local property = self:getProperty( name )

	if property then

		return property:setValue( value )

	else

		self:addProperty( Property( name, value ) )

	end
	
	self[name] = self:getPropertyValue( name )

end

--- Gets a Property of the Object.
-- @param name The name of the Property.
-- @return The Property. nil if no Property found.
function Properties:getProperty( name )

	return self.properties[name]

end

--- Gets the value of a Property of the Object.
-- @param name The name of the Property.
-- @return The Property value. nil if no Property found.
function Properties:getPropertyValue( name )
	
	local property = self:getProperty( name )
	
	if property then

		return property:getValue()

	end
	
end

--- Gets a list of all Properties of the Object.
-- @return The list of Properties.
function Properties:getProperties()

	return self.properties

end

--- Gets a count of how many properties the Object has.
-- @return The Property count.
function Properties:getPropertyCount()

	local count = 0
	
	for _k, _v in pairs( self.properties ) do

		count = count + 1

	end

	return count

end

--- Checks whether the Object has a certain Property.
-- @param name The name of the property to check for.
-- @return True if the Object has the Property, false if not.
function Properties:hasProperty( name )

	return self:getProperty( name ) ~= nil

end

--- Adds a Property to the Object. 
-- @param property The Property to add.
-- @return The added Property.
function Properties:addProperty( property )

	self.properties[ property:getName() ] = property
	
	self[ property:getName() ] = property:getValue()
	
	return property

end

--- Removes a Property from the Object. 
-- @param name The name of the Property to remove.
function Properties:removeProperty( name )

	self.properties[name] = nil

end

return Properties