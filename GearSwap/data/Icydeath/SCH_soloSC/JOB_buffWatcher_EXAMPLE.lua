function get_sets()
  -- Load and initialize the include file.
  mote_include_version = 2
  include('Mote-Include.lua')
end


function job_setup()


  include('caster_buffWatcher.lua')
end

function file_unload()
  if binds_on_unload then
    binds_on_unload()
  end
end

function user_setup()

end

function user_unload()

end

function init_gear_sets()
end

function job_self_command(cmdParams, eventArgs)
-- maybe some other stuff
  if cmdParams[1] == 'buffWatcher' then
	  buffWatch(cmdParams[2],cmdParams[3])
  end
  if cmdParams[1] == 'stopBuffWatcher' then
	  stopBuffWatcher()
  end
-- maybe some other stuff
end

function job_buff_change(buff, gain)
  for index,value in pairs(buffWatcher.watchList) do
    if index==buff then
      buffWatch()
    end
  end
end