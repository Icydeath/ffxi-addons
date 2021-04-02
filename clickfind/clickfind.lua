_addon.name = 'Clickfind'
_addon.version = '0.0.1'
_addon.author = 'Lili'

-- Prints the X,Y position of the mouse in the chatlog. Triggers when the left mouse button is *released*.
windower.register_event('mouse',function(type,x,y,delta,blocked)
    if type == 2 then
        windower.add_to_chat(158,'Mouse position - X: %s, Y: %s':format(x,y))
    end
end)
