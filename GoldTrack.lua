local ADDON_NAME = ...
local ADDON_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

GoldTrack = {}
GoldTrack.__index = GoldTrack
GoldTrack.debug_ = true

GoldTrack.events_ = {
   "ADDON_LOADED",
   "PLAYER_ENTERING_WORLD",
   "PLAYER_MONEY"
}

SLASH_GOLDTRACK1 = "/goldtrack"
SLASH_GOLDTRACK2 = "/gt"

function SlashCmdList.GOLDTRACK(msg, edit)
   -- Handle commands here
end

--------------------------
---- Main addon logic ----
--------------------------

-- Function: initialize
-- Descr: Initialize the addon
function GoldTrack:initialize()
   self:create_mainframe()
end

-- Function: create_mainframe
-- Descr: Creates the main frame for the addon and registers events
--        for the frame
function GoldTrack:create_mainframe()
   self.frame = CreateFrame("Button" ,"GoldTrack_Frame", UIParent)
   self.frame:Hide()

   for _, event in ipairs(self.events_) do
      self.frame:RegisterEvent(event)
   end

   -- Calls the associated event handlers
   self.frame:SetScript("OnEvent", function(frame, event, ...) self[event](self, ...) end)
end

-- Function: process_money_change
-- Descr: Creates a log entry for the money changes
function GoldTrack:process_money_change(change, money_after)
   table.insert(self.realm_db[self.player.faction].gold_log, {
                   timestamp = time(),
                   character = self.player.name,
                   realm = self.player.realm,
                   change = change,
                   money_after = money_after
   })
end

-- Function: earned_after
-- Descr: Return amount of money earned after the specified time
function GoldTrack:earned_after(timestamp)
   local earned = 0
   for i, entry in self:ripairs(self.realm_db[self.player.faction].gold_log) do

      if entry.timestamp < timestamp then
         break
      end

      if not entry.ignore and entry.change > 0 then
         earned = earned + entry.change
      end
   end

   return earned
end

-- Function: spent_after
-- Descr: Return amount of money spent after specified time
function GoldTrack:spent_after(timestamp)
   local spent = 0
   for i, entry in self:ripairs(self.realm_db[self.player.faction].gold_log) do

      if entry.timestamp < timestamp then
         break
      end

      if not entry.ignore and  entry.change < 0 then
         spent = spent + entry.change
      end
   end

   return spent
end

-- Function: balance_after
-- Descr: Return balance after specified time
function GoldTrack:balance_after(timestamp)
   local balance = 0
   for i, entry in self:ripairs(self.realm_db[self.player.faction].gold_log) do

      if entry.timestamp < timestamp then
         break
      end

      if not entry.ignore then
         balance = balance + entry.change
      end
   end

   return balance
end

---------------------------
---- Utility functions ----
---------------------------

-- Function: print
-- Descr: Print the message in the default chat frame
function GoldTrack:print(msg)
   ChatFrame1:AddMessage("|cff00ffcc" .. ADDON_NAME .. "|r: " .. msg)
end

-- Function: debug_print
-- Descr: Print a debug message
function GoldTrack:debug_print(msg)
   if true then
      self:print(msg)
   end
end

-- Function: ripairs
-- Descr: reverse ipairs (from LUA website)
function GoldTrack:ripairs(t)
  local max = 1
  while t[max] ~= nil do
    max = max + 1
  end
  local function ripairs_it(t, i)
    i = i-1
    local v = t[i]
    if v ~= nil then
      return i,v
    else
      return nil
    end
  end
  return ripairs_it, t, max
end

------------------------
---- Event handlers ----
------------------------

-- Event: ADDON_LOADED
-- Descr: Called when the addon is loaded, setup the
--        database and other required stuff
function GoldTrack:ADDON_LOADED(addon)
   -- Ignore events for other addons
   if addon ~= ADDON_NAME then
      return
   end

   if not GoldTrack_DB then
      GoldTrack_DB = {
         version = ADDON_VERSION
      }
   end

   self.db = GoldTrack_DB

   local name, _  = UnitName("player")
   local _, class = UnitClass("player")
   local realm    = GetRealmName()
   local faction  = UnitFactionGroup("player")

   local realm_uid = ""
   local connected_realms = GetAutoCompleteRealms() or { (realm:gsub("%s+", "")) }

   table.sort(connected_realms)
   for i, r in ipairs(connected_realms) do
      realm_uid = realm_uid .. r
   end

   if not self.db[realm_uid] then
      self.db[realm_uid] = {
         Horde = {
            characters = {
            },
            gold_log = {
               
            }
         },
         Alliance = {
            characters = {
            },
            gold_log = {
               
            }
         }
      }
   end

   self.realm_db = self.db[realm_uid]

   if not self.realm_db[faction].characters[name] then
      self.realm_db[faction].characters[name] = {
         name = name,
         realm = realm,
         class = class,

      }
   end

   self.character_db = self.realm_db[faction].characters[name]

   self.player = {
      name = name,
      class = class,
      realm = realm,
      faction = faction,
   }
end

-- Event: PLAYER_ENTERING_WORLD
-- Descr: Called when player enters world (Loading screens),
--        get money if not already present
function GoldTrack:PLAYER_ENTERING_WORLD()
   if not self.player.money then
      self.player.money = GetMoney()
   end
end

-- Event: PLAYER_MONEY
-- Descr: Called when player loses or gains money
function GoldTrack:PLAYER_MONEY()
   local money = GetMoney()
   local diff = money - self.player.money

   self:process_money_change(diff, money)
   self.player.money = money
end


-- Call initialize to setup the addon
GoldTrack:initialize()
