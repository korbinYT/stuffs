local script_name = "Ender Pearl"
print("Loading " .. script_name .. " robot script...")
local robot_api = require("robot")
local component = require("component")


local COLOR_RED     = 0xff0000
local COLOR_GREEN   = 0x00ff00
local COLOR_YELLOW  = 0xffd800
local COLOR_BLUE    = 0x0000ff
local COLOR_PURPLE  = 0xff00dc
local COLOR_WHITE   = 0xffffff

local SLOT_OUTSIDE  = 1
local SLOT_CENTER   = 2
local SLOT_CATALYST = 3

local AMOUNT_OUTSIDE  = 26
local AMOUNT_CENTER   = 1
local AMOUNT_CATALYST = 1

local STATE_GATHERING = 1
local STATE_CRAFTING  = 2
local STATE_CHARGING  = 3


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
  robot_api.down()
  robot_api.back()
end

function MoveFromChargingToGathering()
  robot_api.forward()
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
end


function MoveFromGatheringToCharging()
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
  robot_api.forward()
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
  robot_api.turnLeft()
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

function PlaceThree(outsideSlot, insideSlot)
  robot_api.select(outsideSlot)
  robot_api.placeDown()
  robot_api.forward()
  robot_api.select(insideSlot)
  robot_api.placeDown()
  robot_api.forward()
  robot_api.select(outsideSlot)
  robot_api.placeDown()
end

function ThrowItem(slot)
  robot_api.select(slot)
  robot_api.drop()
end

function BuildLevel(outsideSlot, insideSlot)
  -- Start
  robot_api.up()
  robot_api.forward()

  PlaceThree(outsideSlot, outsideSlot)

  robot_api.turnRight()
  robot_api.forward()
  robot_api.turnRight()

  PlaceThree(outsideSlot, insideSlot)

  robot_api.turnLeft()
  robot_api.forward()
  robot_api.turnLeft()

  PlaceThree(outsideSlot, outsideSlot)

  -- Return to beginning, but one block up
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
  robot_api.turnLeft()
  robot_api.forward()
  robot_api.forward()
  robot_api.forward()
  robot_api.turnAround()
end


function GetResources()
  MoveFromChargingToGathering()

  GetFromInventory(AMOUNT_OUTSIDE, SLOT_OUTSIDE) -- 26 outside blocks

  robot_api.turnRight()
  robot_api.forward()
  robot_api.turnLeft()

  GetFromInventory(AMOUNT_CENTER, SLOT_CENTER) -- 1 center block

  robot_api.turnRight()
  robot_api.forward()
  robot_api.turnLeft()

  GetFromInventory(AMOUNT_CATALYST, SLOT_CATALYST) -- 1 catalyst item

  MoveFromGatheringToCharging()
end

function BuildStructure()
  MoveFromChargingToCrafting()
  
  for i=1,3 do
    local center = SLOT_OUTSIDE
    if i == 2 then
      center = SLOT_CENTER
    end
    
    BuildLevel(SLOT_OUTSIDE, center)
  end

  -- Move back one extra space so it immediately activates
  robot_api.back()

  ThrowItem(SLOT_CATALYST)

  MoveFromCraftingToCharging()
end



-- Main action
local forever = 1
local chargeTime = 0 -- os.time not behaving for me?
local state = STATE_CHARGING
while forever do

  if state == STATE_CHARGING then
    -- charge for 5 seconds, then move on
    ChangeColor(COLOR_WHITE)
    chargeTime = chargeTime + 1
    if chargeTime >= 5 then
      state = STATE_GATHERING
    end
 
  elseif state == STATE_GATHERING then
    -- Getting resources and see how many we get
    ChangeColor(COLOR_YELLOW)
    GetResources()
    if HaveEnoughResources() then
      -- enough, craft
      ChangeColor(COLOR_GREEN)
      state = STATE_CRAFTING
    else
      -- not enough, wait a while (and charge)
      ChangeColor(COLOR_RED)
      chargeTime = 0
      state = STATE_CHARGING
    end

  elseif state == STATE_CRAFTING then
    -- craft
    ChangeColor(COLOR_BLUE)
    BuildStructure()
    os.sleep(15)
    
    ChangeColor(COLOR_GREEN)
    chargeTime = 0
    state = STATE_CHARGING
  end
  
  os.sleep(1)
  
end