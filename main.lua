local bit = require 'libraries/bitop.funcs'
require 'utils'

function love.load()
  math.randomseed(os.clock())

  ECS = {}

  local Entity = require 'Entity'
  local Components = require 'Components'
  local Systems = require 'Systems'
  local Assemblages = require 'Assemblages'

  ECS = { count = 0, score = 0 }
  ECS.Entity = Entity
  ECS.Components = Components
  ECS.Systems = Systems
  ECS.Assemblages = Assemblages

  playerPosition = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2
  }

  entities = {}

  -- Create rectangle entities
  for i=1, 20, 1 do
    local entity = ECS.Entity()
    entity:addComponent(ECS.Components.Appearance())
    entity:addComponent(ECS.Components.Position())
    -- Randomize chance of decaying entities
    if math.random() < 0.8 then
      entity:addComponent(ECS.Components.Health())
    end

    -- NOTE: If we wanted some rects to not have collision, we could set it
    -- here. Could provide other gameplay mechanics perhaps?
    entity:addComponent(ECS.Components.Collision())

    entities[entity.id] = entity
  end

  -- Create player entity
  local player = ECS.Entity()
  player:addComponent(ECS.Components.Appearance())
  player:addComponent(ECS.Components.Position({ x = playerPosition.x, y = playerPosition.y }))
  player:addComponent(ECS.Components.Collision())
  player:addComponent(ECS.Components.PlayerControlled())
  player:addComponent(ECS.Components.Health())
  player.components.appearance.colors.r = 1.0
  player.components.appearance.colors.g = 0.0
  player.components.appearance.colors.b = 0.0
  player.components.appearance.colors.a = 1.0

  entities[player.id] = player

  ECS.entities = entities
end

function love.update(dt)
  -- Update mouse position
end

function love.draw()
  x, y = love.mouse.getPosition()
  cursorPosition = { x = x, y = y }

  for i = 1, #ECS.Systems, 1 do
    ECS.Systems[i](entities)
  end
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end
