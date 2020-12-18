-- Plugin used for add pivot joint between two display objects. 

local M = {}

function M.new( display_object, map )

	if display_object then

		local bodyA_name 	 = display_object.bodyA_name
		local bodyB_name 	 = display_object.bodyB_name
		local anchor_x   	 = display_object.anchor_x or display_object.x
		local anchor_y   	 = display_object.anchor_y or display_object.y	

		if bodyA_name and bodyB_name and anchor_x and anchor_y then

			local bodyA = map:getObjects( { name=bodyA_name } )
			local bodyB = map:getObjects( { name=bodyB_name } )

			if bodyA and bodyB then

				local joint = physics.newJoint( 'pivot', bodyA, bodyB, anchor_x, anchor_y )	

				if joint then

					joint.isMotorEnabled = display_object.isMotorEnabled
					joint.motorSpeed     = display_object.motorSpeed
					joint.maxMotorTorque = display_object.maxMotorTorque
					joint.motorTorque    = display_object.motorTorque

					-- Add joint reference for futher manipulation
					bodyA.joint = joint
					bodyB.joint = joint

					display.remove( display_object )

				else

					print( 'Pivot Joint Plugin: Can not create joint.')

				end	

			else

				local message = string.format( 
					'Pivot Joint Plugin: Can not find %q and/or %q display objects.',
					bodyA_name,
					bodyB_name
				)
				print( message )

			end		

		else

			local message = 
				'Pivot Joint Plugin: Provide "bodyA_name", "bodyB_name", "anchor_x" and "anchor_y" properties in Tiled.',
			print( message )

		end	
	
	end	

end

return M