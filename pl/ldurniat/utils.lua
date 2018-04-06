------------------------------------------------------------------------------------------------
-- The helper module.
--
-- @module utils
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Jan-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES	                                          --						
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--									DECLARATION OF MODULE									  --
-- ------------------------------------------------------------------------------------------ --

local M = {}

-- ------------------------------------------------------------------------------------------ --
--						        	MODULE VARIABLES										  --
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                  LOCALISED VARIABLES                                       --	
-- ------------------------------------------------------------------------------------------ --

local floor = math.floor
local abs   = math.abs
local ceil  = math.ceil
local atan  = math.atan
local rad   = math.rad
local deg   = math.deg
local sqrt  = math.sqrt
local pi    = math.pi
local twoPi = pi * 2

-- ------------------------------------------------------------------------------------------ --
--									PRIVATE METHODS		   									  --
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                  PUBLIC METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --

------------------------------------------------------------------------------------------------
-- Moves an object a set distance.
--
-- (something that has an X and Y property)
-- @param object The object to move.
-- @param x The amount to move the object along the X axis.
-- @param y The amount to move the object along the Y axis.
------------------------------------------------------------------------------------------------
function M:moveObject( object, x, y )
	
	local _object = object
	local _x = x or 0
	local _y = y or 0
	
	if not _object then
		return 
	end
	
	if not _object.x or not _object.y then
		return
	end

	_object.x = _object.x + _x 
	_object.y = _object.y + _y 
	
end

------------------------------------------------------------------------------------------------
-- Rounds a number.
--
-- @param number The number to utils:round.
-- @param fudge A value to add to the number before rounding. Optional.
-- @return The rounded number.
------------------------------------------------------------------------------------------------
function M:round( number, fudge )
	
	local _number = number
	local _fudge = fudge 
	local fudgeValue = _fudge or 0
	
	return ( floor( _number + fudgeValue ) )
end

------------------------------------------------------------------------------------------------
-- Copies the Properties of one object to another. 
--
-- For adding to an object that doesn't have 'addProperty' such as a Sprite.
-- @param objectA The object that has the Properties.
-- @param objectB The object that will have the Properties coped to it.
-- @param propertiesToIgnore A list of properties to not add if they exist. Optional.
------------------------------------------------------------------------------------------------
function M:copyPropertiesToObject( objectA, objectB, propertiesToIgnore )

	local _objectA = objectA
	local _objectB = objectB
	local _propertiesToIgnore = propertiesToIgnore
	
	local properties = _objectA:getProperties()
	
	for key, property in pairs( properties ) do
		
		local copyProperty = true
		
		if _propertiesToIgnore then
			
			for i = 1, #_propertiesToIgnore, 1 do
				if _propertiesToIgnore[i] == key then
					copyProperty = false
					break	
				end			
			end
			
		end
		
		if copyProperty then

			_objectB[key] = property:getValue()	

		end

	end
	
end

------------------------------------------------------------------------------------------------
-- Decoding color in hex format to ARGB.
--
-- @param hex The color to decode.
-- @return The color in ARGB format.
-- https://github.com/ponywolf/ponytiled
------------------------------------------------------------------------------------------------
function M:decodeTiledColor( hex )

	hex = hex or '#FF888888'
	hex = hex:gsub( '#', '' )
	-- change #RRGGBB to #AARRGGBB 
	hex = string.len( hex ) == 6 and 'FF' .. hex or hex

	local function hexToFloat( part ) return tonumber( '0x'.. part or '00' ) / 255 end

	local a = hexToFloat( hex:sub( 1,2 ) )
	local r = hexToFloat( hex:sub( 3,4 ) )
	local g = hexToFloat( hex:sub( 5,6 ) )
	local b = hexToFloat( hex:sub( 7,8 ) )

	return r, g, b, a

end

------------------------------------------------------------------------------------------------
-- Sets the fill colour ( tint ) of a sprite.
--
-- @param sprite The sprite to tint. Or a display object.
-- @param colour The colour to use. Table containing up to 4 values.
------------------------------------------------------------------------------------------------
function M:setSpriteFillColor( sprite, colour )

	sprite:setFillColor( self:decodeTiledColor( colour ) )

end

------------------------------------------------------------------------------------------------
-- Sets the stroke colour ( tint ) of a sprite.
--
-- @param sprite The sprite to tint. Or a display object.
-- @param colour The colour to use. Table containing up to 4 values.
------------------------------------------------------------------------------------------------
function M:setSpriteStrokeColor( sprite, colour )

	sprite:setStrokeColor( self:decodeTiledColor( colour ) )

end

------------------------------------------------------------------------------------------------
-- Converting two-dimensional table to one-dimensional table.
--
-- @param points The two-dimensional table.
-- @return The one-dimensional table.
------------------------------------------------------------------------------------------------
function M:unpackPoints( points )
	-- Code borrowed from https://github.com/ponywolf/ponytiled 	

	local t = {}

	for i = 1, #points do

		t[#t+1] = points[i].x

		t[#t+1] = points[i].y

	end

	return t

end

------------------------------------------------------------------------------------------------
-- Centering merged from code by Micheal Wilson/ponytiled.
--
-- Center display object
-- @param image The object to center.
------------------------------------------------------------------------------------------------
function M:centerAnchor( image )

  if image.contentBounds then 

    local bounds = image.contentBounds
    local actualCenterX, actualCenterY =  ( bounds.xMin + bounds.xMax ) * 0.5 , ( bounds.yMin + bounds.yMax ) * 0.5

    image.anchorX, image.anchorY = 0.5, 0.5  
    image.x = actualCenterX
    image.y = actualCenterY

  end

end

------------------------------------------------------------------------------------------------
-- Adds a displayObject to a displayGroup
--
-- @param displayObject The object to add.
-- @param group The group to add the object to.
-- @return The displayObject
------------------------------------------------------------------------------------------------
function M:addObjectToGroup( displayObject, group )
	
	local _displayObject = displayObject
	local _group = group
	
	if _displayObject and _group then
		
			_group:insert( _displayObject )
		
	end
	
	return _displayObject
	
end

------------------------------------------------------------------------------------------------
-- Applies physical properties to a body.
--
-- @param body The body to apply the properties to.
-- @param params The physical properties.
------------------------------------------------------------------------------------------------
function M:applyPhysicalParametersToBody( body, params )
 
	local _body = body
	local _params = params
	
	if _body then

		_body.isAwake = _params.isAwake
		_body.isBodyActive = _params.isBodyActive or true
		_body.isBullet = _params.isBullet
		_body.isSleepingAllowed = _params.isSleepingAllowed
		_body.isFixedRotation = _params.isFixedRotation
		_body.angularVelocity = _params.angularVelocity
		_body.linearDamping = _params.linearDamping
		_body.angularDamping = _params.angularDamping
		_body.bodyType = _params.bodyType
		_body.isSensor = _params.isSensor

	end
end

------------------------------------------------------------------------------------------------
-- Lua based table printing funciton similar to the PHP print_r function. 
--
-- @param t The table to print.
------------------------------------------------------------------------------------------------
function M:print_r ( t ) 
	-- Code borrowed from https://github.com/robmiracle/print_r

    local print_r_cache={}
        local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                local tLen = #t
                for i = 1, tLen do
                    local val = t[i]
                    if (type(val)=="table") then
                        print(indent.."#["..i.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(i)+8))
                        print(indent..string.rep(" ",string.len(i)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."#["..i..'] => "'..val..'"')
                    else
                        print(indent.."#["..i.."] => "..tostring(val))
                    end
                end
                for pos,val in pairs(t) do
                    if type(pos) ~= "number" or math.floor(pos) ~= pos or (pos < 1 or pos > tLen) then
                        if (type(val)=="table") then
                            print(indent.."["..pos.."] => "..tostring(t).." {")
                            sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                            print(indent..string.rep(" ",string.len(pos)+6).."}")
                        elseif (type(val)=="string") then
                            print(indent.."["..pos..'] => "'..val..'"')
                        else
                            print(indent.."["..pos.."] => "..tostring(val))
                        end
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    
   if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end

   print()
end


------------------------------------------------------------------------------------------------
-- Creates a complete/deep copy of the data 
--
-- @param object The object to copy.
--
-- @return New copy of object.
------------------------------------------------------------------------------------------------
function M:deepCopy( object )
	--https://forums.coronalabs.com/topic/27482-copy-not-direct-reference-of-table/
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

return M
