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

local GoldTrack_MainMenu_Info = {
   -- Level 1
   [1] = {
      -- List 1
      [1] = {
         -- Title
         [1] = {
            ["isTitle"] = true,
            ["text"] = "Display",
            ["notCheckable"] = true
         },

         -- Submenus
         [2] = {
            ["text"] = "Type",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 1
         },
         [3] = {
            ["text"] = "Time",
            ["notCheckable"] = true,
            ["hasArrow"] = true,
            ["menuList"] = 2,
         }
      }
   },

   -- Level 2
   [2] = {
      -- List 1
      [1] = {
         -- Options
         [1] = {
            ["text"] = "Balance",
            ["checked"] = function() return GoldTrack:check_tracking_type(GoldTrack.BALANCE) end,
            ["func"] = function() GoldTrack:set_tracking_type(GoldTrack.BALANCE) end,
         },
         [2] = {
            ["text"] = "Earned",
            ["checked"] = function() return GoldTrack:check_tracking_type(GoldTrack.EARNED) end,
            ["func"] = function() GoldTrack:set_tracking_type(GoldTrack.EARNED) end,
         },
         [3] = {
            ["text"] = "Spent",
            ["checked"] = function() return GoldTrack:check_tracking_type(GoldTrack.SPENT) end,
            ["func"] = function() GoldTrack:set_tracking_type(GoldTrack.SPENT) end,
         }
      },
      [2] = {
         [1] = {
            ["text"] = "1 day",
            ["checked"] = function() return GoldTrack:check_tracking_time(GoldTrack.DAY) end,
            ["func"] = function() GoldTrack:set_tracking_time(GoldTrack.DAY) end,

         },
         [2] = {
            ["text"] = "1 week",
            ["checked"] = function() return GoldTrack:check_tracking_time(GoldTrack.WEEK) end,
            ["func"] = function() GoldTrack:set_tracking_time(GoldTrack.WEEK) end,
         },
         [3] = {
            ["text"] = "1 month",
            ["checked"] = function() return GoldTrack:check_tracking_time(GoldTrack.MONTH) end,
            ["func"] = function() GoldTrack:set_tracking_time(GoldTrack.MONTH) end,
         }
      }
   }
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

