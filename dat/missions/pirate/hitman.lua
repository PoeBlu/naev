--[[

   Pirate Hitman

   Corrupt Merchant wants you to destroy competition

   Author: nloewen

--]]

-- Localization, choosing a language if naev is translated for non-english-speaking locales.
lang = naev.lang()
if lang == "es" then
else -- Default to English
   -- Bar information
   bar_desc = "You see a shifty looking man sitting in a darkened corner of the bar. He is trying to discreetly motion you to join him, but is only managing to look stupid."

   -- Mission details
   misn_title  = "Pirate Hitman"
   misn_reward = "Some easy money." -- Possibly some hard to get contraband once it is introduced
   misn_desc   = {}
   misn_desc[1] = "Chase away merchant competition in the %s system."
   misn_desc[2] = "Return to %s in the %s system for payment."

   -- Text
   title    = {}
   text     = {}
   title[1] = "Spaceport Bar"
   text[1]  = [[How'd you like to earn some easy money?]]
   title[3] = "Mission Complete"
   text[2] = [[There're some new merchants edging in on my trade routes in %s. I want you to let them know they're not welcome. You don't have to kill anyone, just rough them up a bit.]]
   text[3] = [[Did everything go well? Good, good. That should teach them to stay out of my space.]]

   -- Messages
   msg      = {}
   msg[1]   = "MISSION SUCCESS! Return for payment."
end

function create ()
   targetsystem = system.get("Delta Pavonis") -- Find target system

   -- Spaceport bar stuff
   misn.setNPC( "Shifty Trader",  "shifty_merchant")
   misn.setDesc( bar_desc )
end


--[[
Mission entry point.
--]]
function accept ()
   -- Mission details:
   if not tk.yesno( title[1], string.format( text[1],
          targetsystem:name() ) ) then
      misn.finish()
   end
   misn.accept()

   -- Some variables for keeping track of the mission
   misn_done      = false
   attackedTraders = {}
   attackedTraders["__save"] = true
   attackedTraders[1] = 0
   fledTraders = 0
   misn_base, misn_base_sys = planet.cur()

   -- Set mission details
   misn.setTitle( string.format( misn_title, targetsystem:name()) )
   misn.setReward( string.format( misn_reward, credits) )
   misn.setDesc( string.format( misn_desc[1], targetsystem:name() ) )
   misn_marker = misn.markerAdd( targetsystem, "low" )

   -- Some flavour text
   tk.msg( title[1], string.format( text[2], targetsystem:name()) )

   -- Set hooks
   hook.enter("sys_enter")
end

-- Entering a system
function sys_enter ()
   cur_sys = system.get()
   -- Check to see if reaching target system
   if cur_sys == targetsystem then
      hook.pilot(nil, "attacked", "trader_attacked")
      hook.pilot(nil, "jump", "trader_jumped")
   end
end

-- Attacked a trader
function trader_attacked (hook_pilot, hook_attacker, hook_arg)
   if misn_done then
      return
   end

   if hook_pilot:faction() == faction.get("Trader") and hook_attacker == pilot.player() then
      attackedTraders[1] = attackedTraders[1] + 1
      attackedTraders[attackedTraders[1]+1] = hook_pilot
   end
end

-- An attacked Trader Jumped
function trader_jumped (hook_pilot, hook_arg)
   if misn_done then
      return
   end

   for i, array_pilot in pairs(attackedTraders) do
      if array_pilot == hook_pilot then
         fledTraders = fledTraders + 1
         if fledTraders >= 5 then
            attack_finished()
         end
      end
   end
end

-- attack finished
function attack_finished()
   misn_done = true
   player.msg( msg[1] )
   misn.setDesc( string.format( misn_desc[2], misn_base:name(), misn_base_sys:name() ) )
   misn.markerRm( misn_marker )
   misn_marker = misn.markerAdd( misn_base_sys, "low" )
   hook.land("landed")
end

-- landed
function landed()
   if planet.get() == misn_base then
      tk.msg(title[3], text[3])
      player.pay(15000)
      player.modFaction("Pirate",5)
      misn.finish(true)
   end
end
