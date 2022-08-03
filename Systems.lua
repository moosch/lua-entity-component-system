require 'utils'

local function Draw(entities)
  -- Clearing out previously drawn state will be handled by Love2d
  local currentEntity

  -- For draw we only care about entities with specific components
  for _,entity in pairs(entities) do
    if entity.components.appearance and entity.components.position then
      local colors = entity.components.appearance.colors
      local position = entity.components.position

      local appearance = {
        r = colors.r,
        g = colors.g,
        b = colors.b,
        a = colors.a or 1.0,
        x = position.x,
        y = position.y,
        size = entity.components.appearance.size
      }

      if not entity.components.collision then
        -- If the entity does not have a collision component, give it some transparency
        appearance.a = 0.1
      else
        appearance.a = 1.0
      end

      if entity.components.playerControlled and entity.components.appearance.size > 12 then
        appearance.r = 1.0
        appearance.g = 0.0
        appearance.b = 0.0
        appearance.a = 1.0
        appearance.x = cursorPosition.x
        appearance.y = cursorPosition.y
        print(dump(cursorPosition))
      end

      love.graphics.setColor(appearance.r, appearance.g, appearance.b, appearance.a)
      love.graphics.rectangle(
        "fill",
        appearance.x - appearance.size,
        appearance.y - appearance.size,
        appearance.size * 2,
        appearance.size * 2)
    end
  end
end

local function UserInput(entities)
  -- An optimization would be to have some layer which only
  -- feeds in relevant entities to the system, but for demo purposes we'll
  -- assume all entities are passed in and iterate over them.
  for _,entity in pairs(entities) do
    if entity.components.playerControlled then
      entity.components.position.x = playerPosition.x
      entity.components.position.y = playerPosition.y
    end
  end
end


local function Collision(entities)
  local function doesIntersect(obj1, obj2)
    local rect1 = {
      x = obj1.position.x,
      y = obj1.position.y,
      width = obj1.size * 2,
      height = obj1.size * 2
    }
    local rect2 = {
      x = obj2.position.x,
      y = obj2.position.y,
      width = obj2.size * 2,
      height = obj2.size * 2
    }
    return rect1.x < rect2.x + rect2.width and
      rect1.x + rect1.width > rect2.x and
      rect1.y < rect2.y + rect2.height and
      rect1.height + rect1.y > rect2.y
  end

  local collidingEntityIds = {}

  for _,entity in pairs(entities) do
    entity.components.appearance.colors.r = 0

    -- Only check for collision on player controllable entities
    -- (playerControlled) and entities with a collision component
    if entity.components.appearance
      and entity.components.playerControlled
      and entity.components.position then

      -- Systems can also modify components...Clear out existing collision appearance property
      entity.components.appearance.colors.r = 0

      -- Test for intersection of player controlled rects vs. all other collision rects
      for _,entity2 in pairs(entities) do
        if entity2.id ~= entity.id then
          -- Don't check player controller entities for collisions (otherwise, it'd always be true)
          if not entity2.components.playerControlled and
            entity2.components.position and
            entity2.components.collision and
            entity2.components.appearance then

            if doesIntersect(
              { position = entity.components.position, size = entity.components.appearance.size },
              { position = entity2.components.position, size = entity2.components.appearance.size }
            ) then
              entity.components.appearance.colors.r = 1.0
              entity2.components.appearance.colors.r = 0.5882352941

              -- Don't modify the array in place; we're still iterating over it
              table.insert(collidingEntityIds, entity.id)

              local negativeDamageCutoff = 12

              if entity.components.health then
                -- Increase the entity's health, it ate something
                entity.components.health.value = entity.components.health.value + math.max(-2, negativeDamageCutoff - entity2.components.appearance.size)


                -- extra bonus for hitting small entities
                if entity2.components.appearance.size < 1.3 then
                  if entity.components.health.value < 30 then
                    entity.components.health.value = entity.components.health.value + 9
                  end
                end

                if entity2.components.appearance.size > negativeDamageCutoff then
                  -- TODO: Flash the canvas
                  -- NOTE: Ideally this would not be coupled in the collision system

                  entity.components.health.value = entity.components.health.value - math.min(5, entity2.components.appearance.size - negativeDamageCutoff)

                else
                  -- TODO: Flash the canvas
                  -- NOTE: Ideally this would not be coupled in the collision system
                end
              end

              -- Update score
              ECS.score = ECS.score + 1
              -- entities[entity2.id] = nil
              break
            end
          end
        end
      end

      -- Add new entities if player collided with any
      local chanceOfDecay = 0.8
      local numNewEntities = 3

      if ECS.score > 100 then
        chanceOfDecay = 0.6
        numNewEntities = 4
      end

      for _, entityId in pairs(collidingEntityIds) do
        entities[entityId] = nil

        -- Only add entities if there are less than 30 existing
        if #keys(entities) < 30 then
          for i = 1, numNewEntities, 1 do
            -- Add some new collision rects
            if math.random() < 0.8 then
              local newEntity = ECS.Assemblages.CollisionRect()
              -- Add chance of decay
              if math.random() < chanceOfDecay then
                newEntity.addComponent(ECS.Components.Health())
              end
              entities[newEntity.id] = newEntity
            end
          end
        end
      end
    end
  end
end

local function Decay(entities)
  for _,entity in pairs(entities) do
    -- Check if the entity is dead
    if entity.components.playerControlled and entity.components.health.value <= 0 then
      -- END GAME
      return love.quit()
    end

    if entity.components.health then
      -- Decrease health
      local health = entity.components.health.value
      if health < 0.7 then
        entity.components.health.value = health - 0.01
      elseif health < 2 then
        entity.components.health.value = health - 0.03
      elseif health < 10 then
        entity.components.health.value = health - 0.07
      elseif health < 20 then
        entity.components.health.value = health - 0.15
      else
        -- If the rect is huge, it should very quickly decay
        entity.components.health.value = health - 1
      end
    end

    -- Check for alive/dead
    if entity.components.health and entity.components.health.value >= 0 then
      -- Set style based on other components too - player controlled
      -- entity should be style differently based on their health
      -- Update appearance based on health
      -- NOTE: Even though we set appearance properties here, they
      -- don't get rendered here - they get rendered in the draw system
      if entity.components.playerControlled then
        if entity.components.health.value > 10 then
          entity.components.colors = {
            r = 0.1960784314,
            g = 1,
            b = 0.1960784314
          }
        else
          entity.components.colors = {
            r = 1,
            g = 0.1960784314,
            b = 0.1960784314
          }
        end
      end

      -- Entity is still alive
      if entity.components.appearance.size then
        entity.components.appearance.size = entity.components.health.value
      end

    else
      -- Entity is dead
      if entity.components.playerControlled then
        -- End Game
        love.event.quit()
      else
        entities[entity.id] = nil
      end
    end
  end
end

return {
  UserInput,
  Collision,
  Decay,
  Draw
}
