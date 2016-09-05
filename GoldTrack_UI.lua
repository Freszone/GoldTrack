-----------------------------
---- GoldTrack_MainFrame ----
-----------------------------
function GoldTrack_MainFrame_OnMouseDown(self, button)
   if button == "LeftButton" then
      if not self.isMoving then
         self:StartMoving()
         self.isMoving = true
      end
   end

end

function GoldTrack_MainFrame_OnMouseUp(self, button)
   if button == "RightButton" then
      ToggleDropDownMenu(1, nil, GoldTrack_MainMenu, "GoldTrack_MainFrame", 0, 0)
   elseif button == "LeftButton" then
      if self.isMoving then
         self:StopMovingOrSizing()
         self.isMoving = false
      end
   end
end

----------------------------
---- GoldTrack_MainMenu ----
----------------------------

local function tracking_menu_option(opt, text, value)
   return {
      ["text"] = text,
      ["checked"] = function() return GoldTrack:check_tracking_opt(opt, value) end,
      ["func"] = function() GoldTrack:set_tracking_opt(opt, value) end
   }
end

local function tracking_status_option(text, enabled)
   return {
      ["text"] = text,
      ["checked"] = function() return GoldTrack.enabled == enabled end,
      ["func"] = function() if enabled then GoldTrack:enable() else GoldTrack:disable() end end,
   }
end

local GoldTrack_MainMenu_Info = {
   -- Level 1
   [1] = {
      -- List 1
      [1] = {
         -- Title
         [1] = {
            ["isTitle"] = true,
            ["text"] = "Tracking options",
            ["notCheckable"] = true
         },

         -- Submenus
         [2] = {
            ["text"] = "Status",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 1,
         },
         [3] = {
            ["text"] = "Type",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 2,
         },
         [4] = {
            ["text"] = "Time",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 3,
         },
         [5] = {
            ["text"] = "Scope",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 4,
         },
      },
   },

   -- Level 2
   [2] = {
      -- List 1
      [1] = {
	 [1] = tracking_status_option("Enabled", true),
	 [2] = tracking_status_option("Disabled", false)
      },
      [2] = {
         -- Options
         [1] = tracking_menu_option("type", "Balance", "balance"),
         [2] = tracking_menu_option("type", "Earned", "earned"),
         [3] = tracking_menu_option("type", "Spent", "spent"),
      },
      [3] = {
         [1] = tracking_menu_option("time", "Session", "session"),
         [2] = tracking_menu_option("time", "Hour", "hour"),
         [3] = tracking_menu_option("time", "Day", "day"),
         [4] = tracking_menu_option("time", "Week", "week"),
         [5] = tracking_menu_option("time", "Month", "month"),
         [6] = tracking_menu_option("time", "Year", "year"),
      },
      [4] = {
         [1] = tracking_menu_option("scope", "Character", "character"),
         [2] = tracking_menu_option("scope", "Realm", "realm"),
      },
   },
}

function GoldTrack_MainMenu_OnLoad(self, level, menuList)
   level = level or 1
   menuList = menuList or 1

   for _,v in ipairs(GoldTrack_MainMenu_Info[level][menuList]) do
      local info = UIDropDownMenu_CreateInfo()

      for k,v in pairs(v) do
         if type(v) == "function" and k ~= "func" then
            info[k] = v()
         else
            info[k] = v
         end
      end

      UIDropDownMenu_AddButton(info, level)
   end

end

