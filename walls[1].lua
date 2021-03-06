local script_name = "Compact Machine Wall"
print("Loading " .. script_name .. " robot script...")
local robot_api = require("robot")
local component = require("component")
local args,opts = require("shell").parse(...)
local y = tonumber(args[1])


local COLOR_RED     = 0xff0000
local COLOR_GREEN   = 0x00ff00
local COLOR_YELLOW  = 0xffd800
local COLOR_BLUE    = 0x0000ff
local COLOR_PURPLE  = 0xff00dc
local COLOR_WHITE   = 0xffffff

local SLOT_OUTSIDE  = 1
local SLOT_CENTER   = 2
local SLOT_CATALYST = 3

local AMOUNT_OUTSIDE  = 1
local AMOUNT_CENTER   = 1
local AMOUNT_CATALYST = 1

-- The time the craft takes to finish, in ticks. Can be found in /config/compactmachines3/recipes/
local TICK_DURATION = 100


function ChangeColor(color)
  component.robot.setLightColor(color)
end

function MoveFromChargingToCrafting()
  robot_api.forward()
  robot_api.forward()
end

function MoveFromCraftingToCharging()
  robot_api.down()
  robot_api.down()
  robot_api.back()
end

function MoveFromChargingToGathering()
  robot_api.forward()
  robot_api.forward()
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
  robot_api.up()
  robot_api.up()
end


function MoveFromGatheringToCharging()
  robot_api.back()
  robot_api.back()
  robot_api.turnRight()
  robot_api.back()
  robot_api.back()
  robot_api.back()
end

function GetFromInventory(amount, slot)
  robot_api.select(slot)
  local alreadyHas = robot_api.count(slot)
  robot_api.suck(amount - alreadyHas)
end

function HaveEnoughResources()
  local obsidian = robot_api.count(SLOT_OUTSIDE)
  local blocks = robot_api.count(SLOT_CENTER)
  local dust = robot_api.count(SLOT_CATALYST)
  if obsidian < AMOUNT_OUTSIDE or blocks < AMOUNT_CENTER or dust < AMOUNT_CATALYST then
    return false
  end

  return true
end

function ThrowItem(slot)
  robot_api.select(slot)
  robot_api.drop()
end


function GetResources()
  MoveFromChargingToGathering()

  GetFromInventory(AMOUNT_OUTSIDE, SLOT_OUTSIDE) -- 1 outside block

  robot_api.down()
  robot_api.down()
  robot_api.turnRight()
  robot_api.forward()
  robot_api.turnLeft()

  GetFromInventory(AMOUNT_CENTER, SLOT_CENTER) -- 1 center block

  GetFromInventory(AMOUNT_CATALYST, SLOT_CATALYST) -- 1 catalyst item

  MoveFromGatheringToCharging()

  -- GetFromInventory(AMOUNT_OUTSIDE, SLOT_OUTSIDE) -- 26 outside blocks

  -- robot_api.turnRight()
  -- robot_api.forward()
  -- robot_api.turnLeft()

  -- GetFromInventory(AMOUNT_CENTER, SLOT_CENTER) -- 1 center block

  -- robot_api.turnRight()
  -- robot_api.forward()
  -- robot_api.turnLeft()

  -- GetFromInventory(AMOUNT_CATALYST, SLOT_CATALYST) -- 1 catalyst item
end

function BuildStructure()
  MoveFromChargingToCrafting()

  robot_api.up()
  robot_api.forward()
  robot_api.select(SLOT_OUTSIDE)
  robot_api.placeDown()
  robot_api.up()
  robot_api.select(SLOT_CENTER)
  robot_api.placeDown()
  robot_api.back()

  -- Move back one extra space so it immediately activates
  robot_api.back()

  ThrowItem(SLOT_CATALYST)

  MoveFromCraftingToCharging()
end



-- Main action
if y == 0 then
  y = 10000000
end
for num=1,y do

  -- Charge for 5 seconds, then move on
  -- ChangeColor(COLOR_WHITE)
  -- os.sleep(5)

  -- Getting resources and see how many we get
  ChangeColor(COLOR_YELLOW)
  GetResources()

  if HaveEnoughResources() then
    -- Enough, craft
    ChangeColor(COLOR_GREEN)
    state = STATE_CRAFTING
  else
      break
  end

  -- Craft
  ChangeColor(COLOR_BLUE)
  BuildStructure()

  -- Don't have to sleep if we are on the last craft
  if num ~= y then
    os.sleep(TICK_DURATION/20)
  end

  ChangeColor(COLOR_GREEN)

end