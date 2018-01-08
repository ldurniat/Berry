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
-- File name: berry.lua
--
--- The main Berry manager source file.
--  The API's in this source file can be seen as a set of manager methods for using Berry.
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class 	  = require 'pl.ldurniat.lib.30log-clean'
local Map         = require 'pl.ldurniat.Map'
local TileSet     = require 'pl.ldurniat.TileSet'
local ObjectLayer = require 'pl.ldurniat.ObjectLayer'
local utils       = require 'pl.ldurniat.utils'
local json        = require 'json' 

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local Berry = class( 'Berry', { berryDebugModeEnabled = false } )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Enables debug mode so messages are printed to the console when things happen.
function Berry:enableDebugMode()

	self.berryDebugModeEnabled = true

end

--- Disables debug mode so messages aren't printed to the console. Errors will still be printed.
function Berry:disableDebugMode()

		self.berryDebugModeEnabled = false

end	

--- Checks if debug mode is currently enabled or disabled.
-- @return True if enabled, false if not.
function Berry:isDebugModeEnabled()

	return 	self.berryDebugModeEnabled

end

--- Loads a map.
-- @param fileName The filename of the map.
-- @param tileSetsDirectory Path to load the images. Default is baseDirectory.
-- @return The loaded Map object.
function Berry.loadMap( filename, tileSetsDirectory )

	return Map( filename, tileSetsDirectory )	

end

--- Creates the visual representation of a map.
-- @param map The map to create.
-- @return The display group for the map world.
function Berry.createVisual( map )

	return map:create()

end

--- Build a physical representation of a map.
-- @param map - The map to build. 
function Berry.buildPhysical( map )

	map:build()
	
end

return Berry