---------------------------------------------------------------------------------------------------
---menu_scene.lua
---author: Karl
---date: 2021.3.4
---references:
---desc: implements the main menu
---------------------------------------------------------------------------------------------------

local GameScene = require("BHElib.scenes.game_scene")

---@class Menu:GameScene
local Menu = LuaClass("scenes.Menu", GameScene)

-- require modules
require("BHElib.scenes.menu.menu_page")
local _scene_transition = require("BHElib.scenes.scene_transition")
local _menu_transition = require("BHElib.scenes.menu.menu_page_transition")

---------------------------------------------------------------------------------------------------
---override/virtual

---create and return a new Menu instance
---@param current_task table specifies a task that the menu should carry out; format {string, table}
---@return Menu a menu object
function Menu.__create(task_spec)
    local self = GameScene.__create()

    self.task_spec = task_spec

    return self
end

---create a menu scene
---@return cc.Scene a new cocos scene
function Menu:createScene()
    -- initialize by first creating all menu pages

    -- for more complex menu, consider further moving the code of declaring object classes to another file

    local main_menu_content = {
        {"Start Game", function()
            task.New(self, function()
                -- fade out menu page
                _menu_transition.transitionTo(self.cur_menu, nil, 30)
                task.Wait(30)

                self.is_replay = false
                -- start stage
                local stage = self:constructStage()
                _scene_transition.transitionTo(self, stage)
            end)
        end},
        {"Start Replay", function()
            task.New(self, function()
                -- fade out menu page
                _menu_transition.transitionTo(self.cur_menu, nil, 30)
                task.Wait(30)

                self.is_replay = true
                -- start stage
                local stage = self:constructStage()
                _scene_transition.transitionTo(self, stage)
            end)
        end},
    }
    local main_menu = New(SimpleTextMenuPage, "TestMenu", main_menu_content, 1)
    self.cur_menu = _menu_transition.transitionTo(nil, main_menu, 30)

    return GameScene.createScene(self)
end

---construct the next stage
---@return Stage an object of Stage class
function Menu.constructStage(self)
    -- for all stages
    local is_replay = self.is_replay
    local SceneGroupInitState = require("BHElib.scenes.stage.state_of_group_init")
    local next_group_init_state = SceneGroupInitState()
    next_group_init_state.is_replay = is_replay
    next_group_init_state.replay_path_for_write = "replay/current.rep"
    if is_replay then
        next_group_init_state.replay_path_for_read = "replay/read.rep"
    end

    -- for first stage
    local GameSceneInitState = require("BHElib.scenes.stage.state_of_stage_init")
    local next_init_state = GameSceneInitState()

    local StageClass = require("BHElib.scenes.stage.game_stage_sample")
    local stage = StageClass(next_group_init_state, next_init_state)

    return stage
end

function Menu:getSceneType()
    return "menu"
end

function Menu:cleanup()
end

function Menu:update(dt)
    GameScene.update(self, dt)
end

local hud_painter = require("BHElib.ui.hud_painter")
function Menu.render(self)
    GameScene.render(self)
    hud_painter.drawHudBackground(
            "image:menu_hud_background",
            1.3
    )
end


return Menu