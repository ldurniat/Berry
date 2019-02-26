--------------------------------------------------------------------------------
-- Default Plugin Template
--
-- Plugins allow a way to extend the functionality and properties of objects. 
--
-- All Tiled objects are Corona displayObjects and inherit their default methods
-- and variables.  There are also Tiled objects that inherit from other groups 
-- such as sprites (if animated), shapes, etc. 
--------------------------------------------------------------------------------

function Plugin( displayObject )

  if not displayObject then error('ERROR: Expected display object') end  

-- -----------------------------------
-- SETUP NEW VARIABLES IF NEEDED
-- -----------------------------------
-- displayObject.foo = some_value
-- displayObject.bar = other_value


-- -----------------------------------
-- CHANGE EXISTING VARIABLES IF NEEDED
-- -----------------------------------
-- displayObject.alpha = 1
-- displayObject:scale(this_amount)
-- displayObject:rotate(other_amount)


-- -----------------------------------
-- ADD NEW METHODS IF NEEDED
-- -----------------------------------
-- function displayObject:show()
--   displayObject.alpha = 1
-- end
--
-- function displayObject:hide()
--   displayObject.alpha = 0
-- end


  return displayObject
    
end

return Plugin