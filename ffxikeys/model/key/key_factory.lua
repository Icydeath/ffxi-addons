local GameKey = require('model/key/game_key')
local ItemKey = require('model/key/item_key')
local EntityFactory = require('model/entity/entity_factory')
local NilKey = require('model/key/nil_key')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local KeyFactory = {}

--------------------------------------------------------------------------------
function KeyFactory.CreateKey(id, option)
    if not id or id == 0 then
        return NilKey:NilKey()
    end

    return GameKey:GameKey(id, option, EntityFactory.CreatePlayer())
end

return KeyFactory
