require 'utils'

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

-- Updates the size of entities based on health
local function Decay(entities, dt)
  local deadEntityIds = {}
  for _,entity in pairs(entities) do

    -- Reduce size of entites over time
    if entity.components.health then
      local health = entity.components.health.value
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
      entity.components.health.value = health

      if health <= 0 then
        -- Check playerControlled health
        if entity.components.playerControlled then
          print('Decay:')
          print(dump(entity))
          return love.event.quit()
        else
          -- Mark entity for removal
          table.insert(deadEntityIds, entity.id)
        end
      else
        -- Update size based on health
        entity.components.appearance.size = health
      end
    end
  end

  for _,entityId in pairs(deadEntityIds) do
    entities[entityId] = nil
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
  local negativeDamageCutoff = 12

  for _,entity in pairs(entities) do
    if entity.components.playerControlled then

      for _,entity2 in pairs(entities) do
        if not entity2.components.playerControlled then
          local rect1 = entityRect(entity)
          local rect2 = entityRect(entity2)
          local collided = doesIntersect(rect1, rect2)

          if collided then
            -- Mark for removal
            table.insert(collidingEntityIds, entity2.id)

            local entity2Size = entity2.components.appearance.size

            -- Add entity health to player
            local additionalHealth = math.max(-2, negativeDamageCutoff - entity2Size)
            -- Extra bonus for hitting small entities
            if entity2Size < 1.3 and entity.components.health.value < 30 then
              additionalHealth = additionalHealth + 9
            end

            -- Classed as a "bad" hit if eaten entity is too large
            -- Subtract even more from player, but no more than 5
            if entity2Size > negativeDamageCutoff then
              additionalHealth = additionalHealth - math.min(5, entity2Size - negativeDamageCutoff)
            else
              -- Otherwise classed as a "good" hit
            end

            entity.components.health.value = entity.components.health.value + additionalHealth
            score = score + 1
          end
        end
      end

      -- Remove eaten entities
      for _,entityId in pairs(collidingEntityIds) do
        entities[entityId] = nil
      end
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
