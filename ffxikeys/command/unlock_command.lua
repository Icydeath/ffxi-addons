local NilCommand = require('command/nil_command')
local KeyFactory = require('model/key/key_factory')
local LockFactory = require('model/lock/lock_factory')
local UnlockFactory = require('model/action/unlock_factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local UnlockCommand = NilCommand:NilCommand()
UnlockCommand.__index = UnlockCommand

--------------------------------------------------------------------------------
function UnlockCommand:UnlockCommand(key_id, lock_id)
    local o = {}
    setmetatable(o, self)
    o._key = key_id
    o._lock = lock_id
    o._type = 'UnlockCommand'
    return o
end

--------------------------------------------------------------------------------
function UnlockCommand:__call(state)
    local key = KeyFactory.CreateKey(self._key, 0)
    local lock = LockFactory.CreateLock(self._lock, 0)
    state.running = UnlockFactory.CreateUnlock(key, lock)()
    state.command = self
    return true
end

return UnlockCommand
