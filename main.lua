local bit = require 'libraries/bitop.funcs'
require 'utils'

function love.load()
  math.randomseed(os.clock())

  ECS = {}

  local Entity = require 'Entity'
  local Components = require 'Components'
  local Systems = require 'Systems'
  local Assemblages = require 'Assemblages'

  count = 0
  score = 0

  ECS.Entity = Entity
  ECS.Components = Components
  ECS.Systems = Systems
  ECS.Assemblages = Assemblages

  cursorPosition = {
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
  local component = ECS.Components.Appearance({
      colors = {
        r = 1.0,
        g = 0.0,
        b = 0.0,
        a = 1.0
      },
      size = 20
  })
  player:addComponent(component)
  player:addComponent(ECS.Components.Position({ x = cursorPosition.x, y = cursorPosition.y }))
  player:addComponent(ECS.Components.Collision())
  player:addComponent(ECS.Components.PlayerControlled())
  player:addComponent(ECS.Components.Health())

  entities[player.id] = player
  playerEntityId = player.id

  ECS.entities = entities
end

function love.update(dt)
  x, y = love.mouse.getPosition()
  cursorPosition = { x = x, y = y }

  if ECS.Systems.Update then
    for i = 1, #ECS.Systems.Update, 1 do
      ECS.Systems.Update[i](entities, dt)
    end
  end
end

function love.draw()
  if ECS.Systems.Draw then
    for i = 1, #ECS.Systems.Draw, 1 do
      ECS.Systems.Draw[i](entities)
    end
  end

  -- for i = 1, #ECS.Systems, 1 do
  --   ECS.Systems[i](entities)
  -- end

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end
