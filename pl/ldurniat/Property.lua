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
-- File name: Property.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------

local class = require 'pl.ldurniat.lib.30log-clean'

----------------------------------------------------------------------------------------------------
----									CLASS					   								----
----------------------------------------------------------------------------------------------------

local Property = class( 'Property' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

---Create a new instance of a Property object.
-- @param name The name of the Property.
-- @param value The value of the Property.
-- @return The newly created property instance.
function Property:init( name, value )

	self.name = name

	self.value = value

end	

--- Gets the name of the Property. 
-- @return The name of the Property.
function Property:getName()

	return self.name

end

--- Gets the value of the Property. 
-- @return The value of the Property.
function Property:getValue()

	return self.value

end

--- Sets the value of the Property. 
-- @param value The new value.
function Property:setValue( value )

	self.value = value

end

return Property