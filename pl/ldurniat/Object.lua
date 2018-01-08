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
-- File name: Object.lua
--
----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------
local class      = require 'pl.ldurniat.lib.30log-clean'
local Properties = require 'pl.ldurniat.Properties'
local utils      = require 'pl.ldurniat.utils'

----------------------------------------------------------------------------------------------------
----									CLASS 													----
----------------------------------------------------------------------------------------------------

local Object = Properties:extend( 'Object' )

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

local FlippedHorizontallyFlag = 0x80000000
local FlippedVerticallyFlag   = 0x40000000
local FlippedDiagonallyFlag   = 0x20000000

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

local function hasbit( x, p ) return x % ( p + p ) >= p end
local function setbit( x, p ) return hasbit( x, p ) and x or x + p end
local function clearbit( x, p ) return hasbit( x, p ) and x - p or x end

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of an Object object.
-- @param data The JSON data.
-- @param map The current Map object.
-- @param objectLayer The ObjectLayer the the Object resides on.
-- @return The newly created object instance.
function Object:init( data, map, objectLayer )

	-- Make sure we have a properties table
	data.properties = data.properties or {}

    self.map = map
    self.objectLayer = objectLayer
    self.data = data
    self.gid = data.gid
    self.flip = {}

    -- Name and type
    self.name = data.name
	self.type = data.type
	
    -- Add custom properties	
	for key, value in pairs( data.properties ) do self:setProperty( key, value ) end

	if self.gid then
		-- Code borrowed from Ponytiled
		-- https://github.com/ponywolf/ponytiled    
	    local gid = self.gid

	    self.flip.x = hasbit( gid, FlippedHorizontallyFlag )
	    self.flip.y = hasbit( gid, FlippedVerticallyFlag )          
	    self.flip.xy = hasbit( gid, FlippedDiagonallyFlag )

	    gid = clearbit( gid, FlippedHorizontallyFlag )
	    gid = clearbit( gid, FlippedVerticallyFlag )
	    gid = clearbit( gid, FlippedDiagonallyFlag )

	    self.gid = gid
		
	    -- Get the correct tileset using the GID
		self.tileSet = map:getTileSetFromGID( gid )

		if self.tileSet then 

			self.tileid = self.gid - self.tileSet.firstgid + 1

		end

	end	
    
end	

--- Sets the position of the Object.
-- @param x The new X position of the Object.
-- @param y The new Y position of the Object.
function Object:setPosition( x, y )

	self.x = x
	self.y = y

	if self.sprite then
		self.sprite.x = x
		self.sprite.y = y
	end

end

--- Gets the position of the Object.
-- @return The X position of the Object.
-- @return The Y position of the Object.
function Object:getPosition()
	return self.x, self.y
end

--- Moves the Object.
-- @param x The amount to move the Object along the X axis.
-- @param y The amount to move the Object along the Y axis.
function Object:move( x, y )

	utils:moveObject( self, x, y )

	if self.sprite then utils:moveObject( self.sprite, x, y ) end

end

--- Shows the Object.
function Object:show()
	
	if self.sprite then

		self.sprite.isVisible = true

	end
	
end

--- Hides the Object.
function Object:hide()
	
	if self.sprite then

		self.sprite.isVisible = false

	end
	
end

--- Gets the Object visual.
function Object:getVisual()

	return self.sprite

end

--- Gets the rotation of the Object.
-- @return The rotation of the object.
function Object:getRotation()

	if self.sprite then

		return self.sprite.rotation

	end
   
end

--- Sets the rotation of the Object.
-- @param The new rotation.
function Object:setRotation( angle )
	
	if self.sprite then

		self.sprite.rotation = angle

	end	
	
end

--- Rotates the Object.
-- @param The angle to rotate by
function Object:rotate( angle )

	if self.sprite then

		self.sprite.rotation = self.sprite.rotation + angle

	end
	
end

--- Creates the visual representation of the Object.
function Object:create ()

	local data = self.data
	local map = self.map
	local group = self.objectLayer.group
	local objectLayer = self.objectLayer

	-- Image Object	
	if self.gid then

		if self.tileSet then
			local firstgid = self.tileSet.firstgid
			local width = data.width
			local height = data.height
			local tileID = self.tileid
			
			if self.tileSet.imageSheet then

				-- Is this object animated?
				if self.isAnimated then

					-- Create an animated Tile
					self.sprite = display.newSprite( group, self.tileSet.imageSheet, self.tileSet:getSequencesData() )
					self.sprite:setSequence( self.map:getTilePropertyValueForGID( self.gid, 'name' ) )

				else 
				
					-- Create image	
	      			self.sprite = display.newImageRect( group, self.tileSet.imageSheet, tileID, width, height )
	      		end	

	    	else -- collections of images  

	      		for k, v in pairs( self.tileSet.tiles ) do
	        	
	        		-- Tile IDs starting at 1
	        		if tonumber( k ) == tileID - 1 then
	          	
	          			-- Create image	
	          			self.sprite = display.newImageRect( group, self.tileSet.directory .. v.image, width, height )
	        	
	        		end
	      		
	      		end

	    	end   

			-- Apply base properties
			self.sprite.anchorX, self.sprite.anchorY = 0, 1
			self.sprite.x, self.sprite.y = data.x, data.y

		end
	-- Text Object		
	elseif data.text then

		-- Make sure we have a properties table
		data.properties = data.properties or {}

		-- Set defaults
	    local text = ( data.properties.label or '' ) .. ' ' .. ( data.text.text or '' )
	    local font = data.properties.font or data.text.fontfamily or native.systemFont
	    local size = data.properties.size or  tonumber( data.text.pixelsize ) or 56
	    local stroked =  data.properties.stroked 
	    local sr,sg,sb,sa = utils:decodeTiledColor( data.properties.strokeColor or '000000CC' )
	    local align = data.properties.align or data.text.halign or 'left'
	    local color = data.text.color or 'FFFFFFFF'
	    local params = { 
	    	parent = group, x = data.x, y = data.y, 
	    	text = text, font = font, fontSize = size, 
	    	align = align, width = data.width 
	    } 

	    if stroked then
			local newStrokeColor = {
				highlight = { r=sr, g=sg, b=sb, a=sa },
				shadow = { r=sr, g=sg, b=sb, a=sa }
			}

			self.sprite = display.newEmbossedText( params )
			self.sprite:setFillColor( utils:decodeTiledColor( color ) )
			self.sprite:setEmbossColor( newStrokeColor )

	    else

	      self.sprite = display.newText( params )
	      self.sprite:setFillColor( utils:decodeTiledColor( color ) )

	    end 

	    -- Default anchor point in Tiled
	    self.sprite.anchorX, self.sprite.anchorY = 0, 0 

	-- Polygon/Polyline Object
	elseif data.polygon or data.polyline then 
		local points = data.polygon or data.polyline

	    if data.polygon then 
			local xMax, xMin, yMax, yMin = -4294967296, 4294967296, -4294967296, 4294967296 -- 32 ^ 2 a large number 

			for p = 1, #points do

				if points[p].x < xMin then xMin = points[p].x end  
				if points[p].y < yMin then yMin = points[p].y end 
				if points[p].x > xMax then xMax = points[p].x end   
				if points[p].y > yMax then yMax = points[p].y end  

	    	end

			local centerX, centerY = ( xMax + xMin ) * 0.5, ( yMax + yMin ) * 0.5
			self.sprite = display.newPolygon( group, data.x, data.y, utils:unpackPoints( points ) )
			self.sprite:translate( centerX, centerY )

	    else

			self.sprite = display.newLine( group, points[1].x, points[1].y, points[2].x, points[2].y ) 
			local originX, originY = points[1].x, points[1].y

			for p = 3, #points do

				self.sprite:append( points[p].x, points[p].y )

			end  

			self.sprite.x, self.sprite.y = data.x, data.y
			self.sprite:translate( originX, originY )

	    end

	else

		self.sprite = display.newRect( group, 0, 0, data.width, data.height )

		-- Apply base properties
	    self.sprite.anchorX, self.sprite.anchorY = 0, 0
	    self.sprite.x, self.sprite.y = data.x, data.y
	
	end	

	-- Name and type
	self.sprite.name = data.name
	self.sprite.type = data.type

	-- Apply base properties
	self.sprite.rotation = data.rotation
	self.sprite.isVisible = data.visible

	-- Change anchor points to 0.5  without change position of object
	utils:centerAnchor( self.sprite )

	-- Flip it
	if self.flip.xy then

		print( 'Berry: Unsupported Tiled rotation x,y in ', self.sprite.name )

	else
		if self.flip.x then self.sprite.xScale = -1 end
		if self.flip.y then self.sprite.yScale = -1 end
	end

	local physicalProperties = {
		'bodyType',
		'isAwake',
		'isSleepingAllowed',
		'isBodyActive',
		'isSensor',
		'isFixedRotation',
		'gravityScale',
		'angularVelocity',
		'angularDamping',
		'linearDamping',
		'isBullet',
	}

	-- Copy over the custom properties to the sprite
	utils:copyPropertiesToObject( objectLayer, self.sprite, physicalProperties )
	utils:copyPropertiesToObject( self, self.sprite, physicalProperties )

    if self:hasProperty( 'fillColor' ) and self:getPropertyValue( 'fillColor' ) ~= '' then 

    	utils:setSpriteFillColor( self.sprite, self:getPropertyValue( 'fillColor' ) ) 

    end
    
    if self:hasProperty( 'strokeColor' ) and self:getPropertyValue( 'strokeColor' ) ~= '' then

    	utils:setSpriteFillColor( self.sprite, self:getPropertyValue( 'strokeColor' ) )  

    end 

	self.map:fireObjectListener( self )
		
	for key, value in pairs( self.properties ) do

		self.map:firePropertyListener( self.properties[key], 'object', self )
	
	end

end	


--- Builds the physical representation of the Object.
function Object:build()
	local visual = self:getVisual()
	local body = visual
	
	if self.hasBody and visual then

		if self.gid and self.gid > 0 then

			local tileID = self.gid - self.tileSet.firstgid + 1
			local object = self.tileSet:getCollisionShapeForTile( tileID ) 
			local mSin = math.sin
			local mCos = math.cos
			local mRad = math.rad 

			if object then

				local function rotate( vertices, angleInDeg )

					local angleInRad = mRad( angleInDeg ) 

					for _, vertex in ipairs( vertices ) do
						local x = vertex.x
						local y = vertex.y
						local newX = x * mCos( angleInRad ) - y * mSin( angleInRad )
						local newY = x * mSin( angleInRad ) + y * mCos( angleInRad )

						vertex.x = newX
						vertex.y = newY

					end	
						
				end	

				local function translate( vertices, deltaX, deltaY  ) 

					for _, vertex in ipairs( vertices ) do
						local newX = vertex.x + deltaX
						local newY = vertex.y + deltaY 

						vertex.x = newX
						vertex.y = newY
						
					end	

				end	

				-- Use polygon or rectangle as collision shape
				if object.polygon or ( not object.ellipse and not object.polyline ) then
					
					local vertices = object.polygon or { 
						{ x=0, y=0 },
						{ x=object.width, y=0 },
						{ x=object.width, y=object.height },
						{ x=0, y=object.height }, 
					}
					local angle = object.rotation
					local deltaX = object.x - visual.width * 0.5 
					local deltaY = object.y - visual.height * 0.5 

					rotate( vertices, angle )
					translate( vertices, deltaX, deltaY )

					local shape = {}

					-- Transform two-dimensional table to one-dimensional table
					for i=1, #vertices do

						shape[2 * i - 1] = vertices[i].x
						shape[2 * i] = vertices[i].y

					end	

					body.shape = shape	

				end	

			end	

		end

		physics.addBody( body, visual ) 

		utils:applyPhysicalParametersToBody( body, self )

	end	

end	

--- Completely removes all visual and physical objects associated with the Object if not nil.
function Object:destroy()
	
	-- Destroy the visual object
 	local visual = self:getVisual()

	if visual then

		display.remove( visual )

	end
	
	visual = nil

end

return Object