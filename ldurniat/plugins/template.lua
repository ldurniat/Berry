--------------------------------------------------------------------------------
-- Default Plugin Template
--
-- Plugins allow a way to extend the functionality and properties of objects. 
--
-- All Tiled objects are Corona displa_objects and inherit their default methods
-- and variables.  There are also Tiled objects that inherit from other groups 
-- such as sprites (if animated), shapes, etc. 
--------------------------------------------------------------------------------

local Plugin = {}

function Plugin.new( displa_object, map ) 
-- -----------------------------------
-- SETUP NEW VARIABLES IF NEEDED
-- -----------------------------------
-- displa_object.foo = some_value
-- displa_object.bar = other_value


-- -----------------------------------
-- CHANGE EXISTING VARIABLES IF NEEDED
-- -----------------------------------
-- displa_object.alpha = 1
-- displa_object:scale(this_amount)
-- displa_object:rotate(other_amount)


-- -----------------------------------
-- ADD NEW METHODS IF NEEDED
-- -----------------------------------
-- function displa_object:show()
--   displa_object.isVisible = true
-- end
--
-- function displa_object:hide()
--   displa_object.isVisible = false
-- end

  return displa_object
    
end

return Plugin