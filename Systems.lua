require 'utils'

-- Draws entities to the screen
local function Draw(entities, dt)
  -- For draw we only care about entities with specific components
  for _,entity in pairs(entities) do
    if entity.components.appearance and entity.components.position then
      local appearance = entity.components.appearance
      local colors = appearance.colors
      local position = entity.components.position

      local appearance = {
        r = colors.r,
        g = colors.g,
        b = colors.b,
        a = colors.a or 1.0,
        x = position.x,
        y = position.y,
        size = appearance.size
      }

      love.graphics.setColor(colors.r, colors.g, colors.b, colors.a)
      love.graphics.rectangle(
        "fill",
        position.x,
        position.y,
        appearance.size * 2,
        appearance.size * 2)
    end
  end
end

local function entityRect(entity)
  return {
    x = entity.components.position.x,
    y = entity.components.position.y,
    width = entity.components.appearance.size * 2,
    height = entity.components.appearance.size * 2
  }
end

local function doesIntersect(rect1, rect2)
  return rect1.x < rect2.x + rect2.width and
    rect1.x + rect1.width > rect2.x and
    rect1.y < rect2.y + rect2.height and
    rect1.height + rect1.y > rect2.y
end

-- Updates the entites that are colliding
local function Collision(entities, dt)
  local collidingEntityIds = {}
  local maxPlayerHealth = 30
  local largeEntitySize = 20
  local largeEntityBonus = 0
  local mediumEntitySize = 10
  local mediumEntityBonus = 3
  local smallEntitySize = 3
  local smallEntityBonus = 5
  local tinyEntitySize = 1.5
  local tinyEntityBonus = 9

  local player = entities[playerEntityId]

  for _,entity in pairs(entities) do
    if entity.id ~= player.id then
      if doesIntersect(entityRect(player), entityRect(entity)) then
        -- Mark for removal
        table.insert(collidingEntityIds, entity.id)

        local entitySize = entity.components.appearance.size
        local additionalHealth = 0

        -- Extra bonus for hitting small entities
        if entitySize < tinyEntitySize then
          additionalHealth = additionalHealth + tinyEntityBonus
        elseif entitySize < smallEntitySize then
          additionalHealth = additionalHealth + smallEntityBonus
        elseif entitySize < mediumEntitySize then
          additionalHealth = additionalHealth + mediumEntityBonus
        else
          additionalHealth = additionalHealth + largeEntityBonus
        end

        player.components.health.value = math.min(player.components.health.value + additionalHealth, maxPlayerHealth)
        score = score + 1
      end
    end
  end

  -- Remove eaten entities
  for _,entityId in pairs(collidingEntityIds) do
    entities[entityId] = nil
  end
end

-- Updates the size of entities based on health
local function Decay(entities, dt)
  local deadEntityIds = {}
  local playerHealthDecay = 3 * dt
  for _,entity in pairs(entities) do

    if entity.components.health then
      local health = entity.components.health.value

      if entity.components.playerControlled then
        if health <= 0 then
          return love.event.quit()
        end
        health = entity.components.health.value - playerHealthDecay
      else
        -- Reduce size of entites over time
        if entity.components.health then
          if health < 0.7 then
            health = health - 1 * dt
          elseif health < 2 then
            health = health - 3 * dt
          elseif health < 10 then
            health = health - 5 * dt
          elseif health < 20 then
            health = health - 7 * dt
          else
            -- If the square is huge, it should very quickly decay
            health = health - 10 * dt
          end
        end

        if health <= 0 then
          -- Mark entity for removal
          table.insert(deadEntityIds, entity.id)
        end
      end

      entity.components.health.value = health
      -- Update size based on health
      entity.components.appearance.size = health
    end
  end

  for _,entityId in pairs(deadEntityIds) do
    entities[entityId] = nil
  end
end

-- Updates the position of entities
local function Position(entities, dt)
  for _,entity in pairs(entities) do
    if entity.components.playerControlled
      and entity.components.appearance
      and entity.components.position then

      entity.components.position.x = cursorPosition.x
      entity.components.position.y = cursorPosition.y
    end
  end
end

-- Creates new entities if the number on screen is "too low"
local function Spawn(entities, dt)
  local chanceOfDecay = 0.8
  local numOfNewEntities = 3

  if score > 100 then
    chanceOfDecay = 0.6
    numOfNewEntities = 4
  end

  if length(entities) < 30 then
    for i=1, numOfNewEntities, 1 do
      while numOfNewEntities > 0 do
        local newEntity = ECS.Assemblages.CollisionRect()

        -- Add % chance that the new entity will decay
        if math.random() < chanceOfDecay then
          newEntity:addComponent(ECS.Components.Health())
        end

        entities[newEntity.id] = newEntity
        numOfNewEntities = numOfNewEntities - 1
      end
    end
  end
end

return {
  Draw = {
    Draw
  },
  Update = {
    Collision,
    Decay,
    Position,
    Spawn
  },
}
