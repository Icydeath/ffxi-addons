_addon.name = 'Posfind'
_addon.version = '0.0.1'
_addon.author = 'Lili'

function trunc(n) return math.floor(n*100)/100 end

-- Return the position of the player character, truncated to 2 decimals. 
-- Triggers when left mouse button is pressed.
windower.register_event('mouse',function(type,x,y,delta,blocked)
    if type == 1 then
        local player = windower.ffxi.get_mob_by_target('<me>')
        windower.add_to_chat(207,'%s pos: %s %s':format(player.name,trunc(player.x),trunc(player.y)))
    end
end)
