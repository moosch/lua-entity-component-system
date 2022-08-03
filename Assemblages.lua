require 'utils'

local function CollisionRect()
  -- Basic collision rect
  local entity = ECS.Entity()
  entity:addComponent(ECS.Components.Appearance())
  entity:addComponent(ECS.Components.Position())
  entity:addComponent(ECS.Components.Collision())
  return entity
end

return { CollisionRect = CollisionRect }
