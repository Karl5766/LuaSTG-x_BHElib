---
--- launcher2_ui.lua
---
--- Copyright (C) 2018-2020 Xrysnow. All rights reserved.
---

local glv = cc.Director:getInstance():getOpenGLView()
local launcher_reader
local launcher_scene
local lc

local getChildrenWithName = require('cc.children_helper').getChildrenWithName
local createItem = require('cc.selectable_item').create
local game_content = require('game.content')

---String representation for all options in the menu
local _btns = {
    'game',
    'practice',
    'spell',
    'replay',
}

---Set the color of all buttons to unselected state
local function unsel_btns()
    for _, v in ipairs(_btns) do
        lc['btn_' .. v]:setColor(cc.c3b(51, 51, 51))
    end
end
local _item_w, _item_h = 600, 80
local function createListItem(lb, btn)
    return createItem(cc.size(_item_w, _item_h), nil, nil, 20, lb, btn)
end

local contents = {
    game     = { 'dif', 'player' },
    practice = { 'dif', 'player', 'stage' },
    spell    = { 'player', 'spell' },
    replay   = { 'replay' },
}
local _list_title
local _list_scv
local current_mode
local current_mode_i
local current_content
local sel_callback = function(self, e)
    if e == 0 then
        if not self.parent.is_selected then
            for _, v in ipairs(_list_scv:getChildren()) do
                if v.setSelected then
                    v:setSelected(false)
                end
            end
        end
        self.parent:setSelected(true)
    end
end

local function setList(mode)
    assert(_list_title and _list_scv and current_content)
    _list_scv:removeAllChildren()
    local list_title_data = require('platform.launcher_ui2_data').list_title
    _list_title:setString(i18n(list_title_data[mode]))

    if mode == 'dif' then
        local ranks, rank_names = game_content.enumRanks()
        for i, v in ipairs(ranks) do
            local item = createListItem()
            item.rank = v
            item.rank_name = rank_names[v]
            item.lb:setString(item.rank_name)
            item.callback_sel = function(self)
                game_content.setRank(self.rank)
            end
            item.btn:addTouchEventListener(sel_callback)
            _list_scv:addChild(item)
        end
    elseif mode == 'player' then
        local players = game_content.enumPlayers()
        for i, v in ipairs(players) do
            local item = createListItem()
            item.player_index = i
            item.player = v
            item.lb:setString(v[1])
            item.callback_sel = function(self)
                game_content.setPlayer(self.player_index)
            end
            item.btn:addTouchEventListener(sel_callback)
            _list_scv:addChild(item)
        end
    elseif mode == 'stage' then
        local names, origin_names = game_content.enumStages()
        for i, v in ipairs(names) do
            local item = createListItem()
            item.name = v
            item.lb:setString(v)
            item.callback_sel = function(self)
                game_content.setStage(i)
            end
            item.btn:addTouchEventListener(sel_callback)
            _list_scv:addChild(item)
        end
    elseif mode == 'spell' then
        local spells = game_content.enumSpells()
        for i, v in ipairs(spells) do
            local item = createListItem()
            local score = {-1, -1}  -- TODO: replace with actual spell history numbers
            local str = string.format('No.%d %s %d/%d', v.index, v.name, score[1], score[2])
            item.index = v.index
            item.info = v
            item.score = score
            item.lb:setString(str)
            item.callback_sel = function(self)
                game_content.setSpell(self.index)
            end
            item.btn:addTouchEventListener(sel_callback)
            _list_scv:addChild(item)
        end
        --SystemLog(stringify(spells))
    elseif mode == 'replay' then
        local replays = game_content.enumReplays()
        for i, v in ipairs(replays) do
            local item = createListItem(
                    cc.Label:createWithSystemFont('button', 'Consolas', 24)
            )
            local str = string.format(
                    'No.%02d %s\n%s %s %s %s %s',
                    v.index, v.user_str, v.date_str, v.time_str, v.player_str, v.rank_str, v.stage_str
            )
            item.index = v.index
            item.replay = v
            item.lb:setString(str)
            --TODO: stage selection
            item.callback_sel = function(self)
                game_content.setReplay(self.replay, 1)
            end
            item.btn:addTouchEventListener(sel_callback)
            _list_scv:addChild(item)
        end
    else
        error('internal error')
    end
    local num = _list_scv:getChildrenCount()
    if num > 0 then
        _list_scv:getChildren()[1]:setSelected(true)
    end
    _list_scv:setInnerContainerSize(cc.size(_item_w, num * _item_h))
    current_mode = mode
    for i, v in ipairs(contents[current_content]) do
        if v == mode then
            current_mode_i = i
            break
        end
    end
end

local function setPrevNext(pos)
    lc.next_content:setVisible(true)
    lc.next_btn:setEnabled(true)
    local label_data = require('platform.launcher_ui2_data').button_label
    local str_prev = i18n(label_data.prev)
    local str_next = i18n(label_data.next)
    local str_start = i18n(label_data.start)
    lc.prev_lb:setString(str_prev)
    if pos == 'first' then
        lc.prev_content:setVisible(false)
        lc.prev_btn:setEnabled(false)
        lc.next_lb:setString(str_next)
    elseif pos == 'last' then
        lc.prev_content:setVisible(true)
        lc.prev_btn:setEnabled(true)
        lc.next_lb:setString(str_start)
    elseif pos == 'only' then
        lc.prev_content:setVisible(false)
        lc.prev_btn:setEnabled(false)
        lc.next_lb:setString(str_start)
    else
        lc.prev_content:setVisible(true)
        lc.prev_btn:setEnabled(true)
        lc.next_lb:setString(str_next)
    end
end

local scene_tasks = {}

---Setup launcher ui and push the scene to the director
local function CreateLauncher2UI()
    local scene = require("launcher_scene")
    scene.initScene()

    -- setup for update and push the scene to director
    scene:scheduleUpdateWithPriorityLua(function(dt)
        scene:update(dt)
    end, 0)
    for name, node in pairs(getChildrenWithName(scene)) do
        print("node name "..name)
    end
    print("!!!!!!!\ncomparing\n!!!!!!!")
    cc.Director:getInstance():pushScene(scene)


    if false and not launcher_reader then
        assert(setting)
        launcher_reader = creator.CreatorReader:createWithFilename('creator/Scene/launcher2.ccreator')
        launcher_reader:setup()
        launcher_scene = launcher_reader:getSceneGraph()
        launcher_scene:setName('launcher_scene')
        lc = getChildrenWithName(launcher_scene)  -- create a reference table for all nodes in launcher scene graph
        unsel_btns()

        for name, node in pairs(lc) do
            print("node name "..name)
        end

        local title_data = require('platform.launcher_ui2_data').title
        for node_name, node in pairs(lc) do
            if string.starts_with(node_name, 'button_') then
                local name = node_name:sub(8)
                local lb = node:getChildren()[2]
                local s = title_data[name]
                if s and lb then
                    lb:setString(i18n(s))
                end
            end
        end

        --SystemLog(stringify(_sc_table))
        lc.caption_lb:setDimensions(480, 40)
        lc.caption_lb:setString(setting.mod)
        _list_title = lc.select_title
        _list_scv = lc.select_scv
        _list_scv:setLayoutType(ccui.LayoutType.VERTICAL)

        local sel_color = cc.c3b(128, 128, 64)  -- button color when selected
        for _, option_name in ipairs(_btns) do
            local btn = lc['btn_' .. option_name]
            btn:addClickEventListener(function()
                unsel_btns()
                btn:setColor(sel_color)
                current_content = option_name
                setList(contents[option_name][1])
                if #contents[option_name] == 1 then
                    setPrevNext('only')
                else
                    setPrevNext('first')
                end
                if option_name == 'practice' or option_name == 'spell' then
                    lc.cheat_content:setVisible(true)
                    lc.cheat_tg:setEnabled(true)
                else
                    lc.cheat_content:setVisible(false)
                    lc.cheat_tg:setEnabled(false)
                    cheat = false
                end
            end)
        end

        unsel_btns()
        lc.btn_game:setColor(sel_color)
        current_content = 'game'
        setList(contents['game'][1])
        setPrevNext('first')

        -- exit button
        lc.btn_exit:addClickEventListener(function()
            --TODO: since clean a mod is not easy, we exit rather than return
            --cc.Director:getInstance():popScene()

            if GameExit then
                GameExit()
            else
                os.exit()
            end
        end)

        -- cheat mode related
        lc.cheat_content:setVisible(false)
        lc.cheat_tg:setEnabled(false)
        lc.cheat_tg:setSelected(cheat or false)
        lc.cheat_tg:addEventListener(function(t, e)
            if e == 0 then
                cheat = true
            elseif e == 1 then
                cheat = false
            end
        end)

        lc.prev_btn:addClickEventListener(function(t, e)
            assert(current_mode_i > 1)
            setList(contents[current_content][current_mode_i - 1])
            if current_mode_i == 1 then
                setPrevNext('first')
            else
                setPrevNext('')
            end
        end)

        lc.next_btn:addClickEventListener(function(t, e)
            local c = contents[current_content]
            local n = #c
            assert(current_mode_i <= n)
            if current_mode_i == n then
                require('app.views.MainScene'):runGameScene()
                return
            else
                lc.prev_content:setVisible(true)
                lc.prev_btn:setEnabled(true)
                setList(c[current_mode_i + 1])
                if current_mode_i == n then
                    setPrevNext('last')
                else
                    setPrevNext('')
                end
            end
        end)

        launcher_scene.update = function(self, dt)
            for i, v in pairs(scene_tasks) do
                v()
            end
        end
        launcher_scene:scheduleUpdateWithPriorityLua(function(dt)
            launcher_scene:update(dt)
        end, 0)

        --SystemLog('[CreateLauncher2UI] before pushScene')
        cc.Director:getInstance():pushScene(launcher_scene)
    end
end

return CreateLauncher2UI
