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

GoldTrack.tracking = {
   ["type"] = "balance",
   ["time"] = "day",
   ["scope"] = "realm"
}

GoldTrack.UI_scale = 1.0

local tracking_types = {
   ["balance"] = function(t, p) return GoldTrack:filter_log(t, true, true, p) end,
   ["earned"] = function(t, p) return GoldTrack:filter_log(t, true, false, p) end,
   ["spent"] = function(t, p) return GoldTrack:filter_log(t, false, true, p) end
}

local scope_types = {
   ["character"] = function() return GoldTrack.player end,
   ["realm"] = function() return nil end
}

local time_frames = {
   ["hour"] = function() return 60 * 60 end,
   ["day"] = function() return 24 * 60 * 60 end,
   ["week"] = function() return 7 * 24 * 60 * 60 end,
   ["month"] = function() return 30 * 24 * 60 * 60 end,
   ["year"] = function() return 365 * 24 * 60 * 60 end,
   ["session"] = function() return time() - GoldTrack.session_start end
}

------------------------
---- Slash commands ----
------------------------

local slash_commands = {
   ["scale"] = function(args) GoldTrack:set_scale(args) end
}

SlashCmdList["GOLDTRACK_SLASHCMD"] = function(msg, edit)
   -- Handle commands here
   local cmd = nil
   local args = {}
   for arg in string.gmatch(msg, "%S+") do
      if not cmd then
	 cmd = arg
      else
	 table.insert(args, arg)
      end
   end

   if slash_commands[cmd] then
      slash_commands[cmd](args)
   else
      GoldTrack:print("Unknown command \"" .. (cmd or "nil") .. "\"")
   end

end

SLASH_GOLDTRACK_SLASHCMD1 = "/goldtrack"
SLASH_GOLDTRACK_SLASHCMD2 = "/gt"

function GoldTrack:set_scale(args)
   local scale = tonumber(args[1])

   if not scale then
      self:print("Usage: /gt scale <scaling : float>")
      self:print("Example: /gt scale 1.5")
      return
   end

   self.UI_scale = scale
   self:save_opts()
   self.frame:SetScale(scale)
end

---------------------------
---- Utility functions ----
---------------------------

-- Function: ripairs
-- Descr: reverse ipairs (from LUA website)
local function ripairs(t)
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

local function coin_string(money)
	if money < 0 then
		return "|cffff0000" .. GetCoinTextureString(abs(money)) .. "|r"
	elseif money > 0 then
		return "|cff00ff00" .. GetCoinTextureString(money) .. "|r"
	else
		return "|cffffffff" .. GetCoinTextureString(money) .. "|r"
	end
end

--------------------------
---- Main addon logic ----
--------------------------

-- Function: initialize
-- Descr: Initialize the addon
function GoldTrack:on_load()
   self:create_mainframe()
end

-- Function: create_mainframe
-- Descr: Creates the main frame for the addon and registers events
--        for the frame
function GoldTrack:create_mainframe()
   self.frame = GoldTrack_MainFrame
   self.frame:Show()

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

   self:update_mainframe()
end

function GoldTrack:update_mainframe()
   local timeframe = time() - time_frames[self.tracking.time]()
   local scope = scope_types[self.tracking.scope]()
   local coins = tracking_types[self.tracking.type](timeframe, scope)

   GoldTrack_MainFrame_GoldText:SetText(coin_string(coins))
end

function GoldTrack:filter_log(timestamp, earned, spent, player)
   local gold = 0
   for i, entry in ripairs(self.realm_db[self.player.faction].gold_log) do
      if entry.timestamp < timestamp then
         break
      end

      if not entry.ignore then
         if not player or (entry.character == player.name and entry.realm == player.realm) then
            if (entry.change < 0 and spent) or (entry.change > 0 and earned) then
               gold = gold + entry.change
            end
         end
      end
   end

   return gold
end

function GoldTrack:reset_all()
   GoldTrack_DB = {}

   self:initialize()
   self.player.money = GetMoney()
   self:update_mainframe()
   self:print("Gold log cleared!")
end

function GoldTrack:reset_realm()
   self.realm_db[self.player.faction] = {
      characters = {},
      gold_log = {},
   }

   self:initialize()
   self.player.money = GetMoney()
   self:update_mainframe()
end

function GoldTrack:reset_character()
   self.character_db = {}

   for i,entry in ipairs(self.realm_db[self.player.faction].gold_log) do
      if entry.character == self.player.name then
         self.realm_db[self.player.faction].gold_log[i] = nil
      end
   end

   self:initialize()
   self.player.money = GetMoney()
   self:update_mainframe()
end

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

function GoldTrack:check_tracking_opt(opt, value)
   return self.tracking[opt] == value
end

function GoldTrack:set_tracking_opt(opt, value)
   self.tracking[opt] = value
   self:update_mainframe()
   self:tracking_opts()
end

function GoldTrack:save_opts()
   if not GoldTrack_Options then
      GoldTrack_Options = {}
   end
   GoldTrack_Options.tracking = self.tracking
   GoldTrack_Options.UI_scale = self.UI_scale
end

function GoldTrack:load_opts()
   if GoldTrack_Options then
      self.tracking = GoldTrack_Options.tracking
      self.UI_scale = GoldTrack_Options.UI_scale
   end
end

function GoldTrack:initialize()
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

   self.session_start = time()
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

   self:initialize()
   self:load_opts()
   self.frame:SetScale(self.UI_scale)
end

-- Event: PLAYER_ENTERING_WORLD
-- Descr: Called when player enters world (Loading screens),
--        get money if not already present
function GoldTrack:PLAYER_ENTERING_WORLD()
   if not self.player.money then
      self.player.money = GetMoney()
   end

   self:update_mainframe()
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
GoldTrack:on_load()
