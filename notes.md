# Notes

## Gold sources
   * Looting DONE
   * Vendor sell DONE
   * Quest reward
   * Mail
   * Trade

## Gold sinks
   * Vendor buy
   * Repair
   * AH
   * Trade
   * Mail
   * Other (Quests requiring gold etc)

## Events for tracking gold
   * PLAYER_MONEY
     * When player's money changes, GetMoney() to get the money amount
       and compare it to the previous time PLAYER_MONEY fired

   * PLAYER_TRADE_MONEY
     * When player trades money

   * MERCHANT_SHOW, MERCHANT_CLOSE
     * Track when merchant is open
       * UPDATE_INVENTORY_ITEM
         * Player repaired
       * ITEM_LOCKED
         * Player sold something
       * ITEM_PUSH
         * Player bought something


   * LOOT_SLOT_CLEARED
     * GetLootSlotInfo(arg1), if count = 0 -> money


## Todo

   * Log money gained/lost
     * In the future, add a 'source' for the event

   * UI for viewing the logs
   * A simple UI showing gained/lost etc

   * Enable/Disable ability