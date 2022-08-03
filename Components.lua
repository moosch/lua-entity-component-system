local bit = require 'libraries/bitop.funcs'
require 'utils'

-- Create's a health component
local function ComponentHealth(value)
  local health = {
    name = 'health',
    value = value or 20
  }
  return health
end

local function ComponentAppearance(args)
  local args = args or {}
  local colors = args.colors or { r = math.random(), g = math.random(), b = math.random() }
  local size = args.size or bit.bor(1 + (math.floor(math.random() * 30)), 0)
  local appearance = {
    name = 'appearance',
    colors = colors,
    size = size
  }
  return appearance
end

local function ComponentPosition(args)
  local args = args or {}
  -- Generate random values if not passed in
  -- NOTE: For the tutorial we're coupling the random values to the canvas'
  -- width / height, but ideally this would be decoupled (the component should
  -- not need to know the canvas's dimensions)
  local position = {
    name = 'position',
    x = args.x or 20 + bit.bor(math.floor(math.random() * (love.graphics.getWidth() - 20)), 0),
    y = args.y or 20 + bit.bor(math.floor(math.random() * (love.graphics.getHeight() - 20)), 0)
  }
  return position
end

local function ComponentPlayerControlled(_args)
  -- local args = args or {}
  local playerControlled = {
    name = 'playerControlled',
    pc = true,
  }
  return playerControlled
end

local function ComponentCollision(args)
  local args = args or {}
  local collision = {
    name = 'collision',
    collides = true
  }
  return collision
end

return {
  Health = ComponentHealth,
  Appearance = ComponentAppearance,
  Position = ComponentPosition,
  PlayerControlled = ComponentPlayerControlled,
  Collision = ComponentCollision
}
