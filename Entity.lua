require 'utils'

local function AddComponent(entity, component)
  -- Component MUST have a name property
  local name = component.name
  entity.components[name] = component
  return entity
end
local function RemoveComponent(entity, componentName)
  entity.components[componentName] = nil
  return entity
end
local function PrintEntity(entity)
  local components = entity.components
  print('Entity{id: '..entity.id..', #components: '..#keys(components)..', components: {'..dump(components)..'}}')
  return entity
end

-- Create an Entity
local function Entity()
  local id = generateId()
  local components = {}
  local entity = {
    id = id,
    components = components
  }
  -- Update global entity count
  count = count + 1

  function entity:addComponent(component)
    -- components[component.name] = component
    -- entity.components = components
    return AddComponent(self, component)
  end
  function entity:removeComponent(component)
    return RemoveComponent(self, component)
  end
  function entity:print()
    return PrintEntity(self)
  end
  return entity
end

return Entity
