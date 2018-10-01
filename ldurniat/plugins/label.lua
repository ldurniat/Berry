-- Code from https://github.com/ponywolf/ponytiled/blob/master/com/ponywolf/plugins/label.lua 

-- tiledObject template

-- Use this as a template to extend a tiled object with functionality

local M = {}

------------------------------------------------------------------------------------------------
-- Decoding color in hex format to ARGB.
--
-- @param hex The color to decode.
-- @return The color in ARGB format.
-- https://github.com/ponywolf/ponytiled
------------------------------------------------------------------------------------------------
local function decodeTiledColor( hex )

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

function M.new( instance )

  if not instance then error('ERROR: Expected display object') end  
  
  -- Remember inital object
  local tiledObj = instance

    -- set defaults
    local text        = tiledObj.text or ' '
    local font        = tiledObj.font or native.systemFont
    local size        = tiledObj.size or 20
    local stroked     = tiledObj.stroked
    local sr,sg,sb,sa = decodeTiledColor( tiledObj.strokeColor or '000000CC' )
    local align       = tiledObj.align or 'center'
    local color       = tiledObj.color or 'FFFFFFFF'
    local params      = { 
        parent   = tiledObj.parent,
        x        = tiledObj.x, 
        y        = tiledObj.y,
        text     = text, 
        font     = font, 
        fontSize = size,
        align    = align, 
        width    = tiledObj.width 
    } 

    if stroked then

        local newStrokeColor = {
          highlight = { r=sr, g=sg, b=sb, a=sa },
          shadow    = { r=sr, g=sg, b=sb, a=sa }
        }

        instance = display.newEmbossedText( params )
        instance:setTextColor( decodeTiledColor( color ) )
        instance:setEmbossColor( newStrokeColor )
    
    else
    
        instance = display.newText( params )
        instance:setTextColor( decodeTiledColor( color ) )
    
    end

    -- Push the rest of the properties
    instance.rotation = tiledObj.rotation 
    instance.name     = tiledObj.name 
    instance.type     = tiledObj.type
    instance.alpha    = tiledObj.alpha 

    display.remove( tiledObj )

    return instance
    
end

return M