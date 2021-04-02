local storage = {}

storage.filename = ''
storage.directory = ''
storage.file = nil

-- setup storage for current player
function storage:setup(player)
    local sub_job = player.sub_job
    if (sub_job == nil) then
        sub_job = 'NOSUB'
    end
    self.filename = player.main_job .. '-' .. sub_job
    self.directory = player.server .. '/' .. player.name

    self.file = file.new('data/hotbar/' .. self.directory .. '/' .. self.filename .. '.xml')
    self.job_default_file = file.new('data/hotbar/' .. self.directory .. '/' .. player.main_job .. '-DEFAULT.xml')
    self.all_jobs_file = file.new('data/hotbar/' .. self.directory .. '/ALL-JOBS-DEFAULT.xml')
end

function split_hotbar(hotbar_to_split)
    -- For the "normal" hotbar file: e.g. DRG-SAM.xml
    local job_sub_hotbar = {}
    job_sub_hotbar.hotbar = {}

    -- For the "job" hotbar file: e.g. DRG-DEFAULT.xml
    local job_hotbar = {}
    job_hotbar.hotbar = {}

    -- For the "character" hotbar file: e.g. ALL-JOBS-DEFAULT.xml
    local all_jobs_hotbar = {}
    all_jobs_hotbar.hotbar = {}

    for environment, hb in pairs(hotbar_to_split.hotbar) do
        if (environment == 'all-jobs-default') then
            all_jobs_hotbar.hotbar[environment] = hb
        elseif (environment == 'job-default') then
            job_hotbar.hotbar[environment] = hb
        else
            job_sub_hotbar.hotbar[environment] = hb
        end
    end

    return job_sub_hotbar, job_hotbar, all_jobs_hotbar
end

-- store an hotbar in a new file
function storage:store_new_hotbar(new_hotbar)
    self.file:create()

    local job_sub_hotbar, job_hotbar, all_jobs_hotbar = split_hotbar(new_hotbar)

    self.file:write(table.to_xml(job_sub_hotbar))
    self.job_default_file:write(table.to_xml(job_hotbar))
    self.all_jobs_file:write(table.to_xml(all_jobs_hotbar))
end

-- update filename according to jobs
function storage:update_filename(main, sub)
    self.filename = main .. '-' .. sub
    self.file = file.new('data/hotbar/' .. self.directory .. '/' .. self.filename .. '.xml')
    self.job_default_file = file.new('data/hotbar/' .. self.directory .. '/' .. main .. '-DEFAULT.xml')
    self.all_jobs_file = file.new('data/hotbar/' .. self.directory .. '/ALL-JOBS-DEFAULT.xml')
end

-- update file with hotbar
function storage:save_hotbar(new_hotbar)
    if not self.file:exists() then
        error('Hotbar file could not be found!')
        return
    end

    local job_sub_hotbar, job_hotbar, all_jobs_hotbar = split_hotbar(new_hotbar)

    self.file:write(table.to_xml(job_sub_hotbar))
    self.job_default_file:write(table.to_xml(job_hotbar))
    self.all_jobs_file:write(table.to_xml(all_jobs_hotbar))
end

return storage