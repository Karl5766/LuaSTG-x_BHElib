----------------------------------------------------------------------
-- modifier:
--      Karl, 2021.2.2 renamed some functions and added function docs.
----------------------------------------------------------------------

local FU = cc.FileUtils:getInstance()

--- Load directories "data", "data_assets" and "background"
---
--- If the directory exists, add directory path to the default paths;
--- otherwise the function will load the zip files with LoadPack() function.
function lstg.LoadData()
    local writable_path = plus.getWritablePath()
    for _, dir_name in ipairs({ 'data', 'data_assets', 'background' }) do
        -- look for directories or zip files
        local possible_dir = { dir_name .. '/', writable_path .. dir_name .. '/' }
        local possible_zip = { dir_name .. '.zip', writable_path .. dir_name .. '.zip' }
        local file_is_found = false
        for _, dir in ipairs(possible_dir) do
            if FU:isDirectoryExist(dir) then
                local fp = FU:fullPathForFilename(dir)
                FU:addSearchPath(fp)
                SystemLog(string.format(i18n "load %s from local path %q", v, fp))
                file_is_found = true
                break
            end
        end
        -- if directory is not found, look for zip files
        if not file_is_found then
            for _, zip_file in ipairs(possible_zip) do
                if plus.FileExists(zip_file) then
                    local zip_path = FU:fullPathForFilename(zip_file)
                    SystemLog(string.format(i18n "load %s from %q", v, zip_path))
                    LoadPack(zip_path)
                    file_is_found = true
                    break
                end
            end
        end
        if not file_is_found then
            -- print a message indicating directory is not found
            Print(string.format('%s %q %s', "ERROR:"..i18n "can't find", dir_name, i18n "file"))
            --Print(stringify(possible_dir), stringify(possible_zip))
        end
    end
end

--

lstg.eventDispatcher:addListener('load.THlib.after', function()
    Include('game/after_load.lua')
end, 1, 'load.data.x')

function lstg.loadMod()
    local writable_path = plus.getWritablePath()
    local mod_path = string.format('%s/mod/%s', writable_path, setting.mod)
    mod_path = mod_path:gsub('//', '/')  -- replace '//' with '/'

    local dir, zip = true, true  -- whether or not try to load directory and zip
    if setting.mod_info then
        dir = setting.mod_info.isDirectory
        zip = not dir
    end

    -- look for /root.lua or mod.zip
    if dir and plus.FileExists(mod_path .. '/root.lua') then
        FU:addSearchPath(mod_path)
        SystemLog(string.format(i18n 'load mod %q from local path', setting.mod))
    elseif zip and plus.FileExists(mod_path .. '.zip') then
        SystemLog(string.format(i18n 'load mod %q from zip file', setting.mod))
        LoadPack(path .. '.zip')
    else
        SystemLog(string.format('%s: %s', "ERROR"..i18n "can't find mod", path))
    end
    SetResourceStatus('global')
    lstg.loadPlugins()

    lstg.eventDispatcher:dispatchEvent('load.THlib.before')
    Include('root.lua')
    lstg.eventDispatcher:dispatchEvent('load.THlib.after')
    DoFile('core/score.lua')

    RegisterClasses()
    SetTitle(setting.mod)
    SetResourceStatus('stage')
end

function lstg.enumPlugins()
    --local p = plus.getWritablePath() .. 'plugin/'
    local p = 'plugin/'
    if not FU:isDirectoryExist(p) then
        SystemLog('no direcory for plugin')
        return {}
    end
    local path = FU:fullPathForFilename(p)
    FU:addSearchPath(path)
    SystemLog(string.format('enum plugins in %q', path))
    local ret = {}
    local files = plus.EnumFiles(path)
    for i, v in ipairs(files) do
        -- skip name start with dot
        if v.name:sub(1, 1) ~= '.' then
            if v.isDirectory then
                if plus.FileExists(path .. v.name .. '/__init__.lua') then
                    table.insert(ret, v)
                end
            else
                if string.lower(string.fileext(v.name)) == 'zip' then
                    v.name = v.name:sub(1, -5)
                    assert(v.name ~= '')
                    table.insert(ret, v)
                end
            end
        end
    end
    return ret
end

plugin = {}
local plugin_list = {}

function lstg.loadPlugins()
    local files = lstg.enumPlugins()
    for i, v in ipairs(files) do
        local name = v.name
        if v.isDirectory then
            local fp = FU:fullPathForFilename(string.format('plugin/%s/__init__.lua', name))
            if fp ~= '' then
                SystemLog(string.format(i18n 'load plugin %q from local path', name))
                Include(fp)
            end
        else
            local fp = FU:fullPathForFilename('plugin/' .. name .. '.zip')
            if fp ~= '' then
                SystemLog(string.format(i18n 'load plugin %q from zip file', name))
                LoadPack(fp)
                Include(name .. '/__init__.lua')
            end
        end
        table.insert(plugin_list, v)
    end
end

function lstg.getPluginList()
    return plugin_list
end
