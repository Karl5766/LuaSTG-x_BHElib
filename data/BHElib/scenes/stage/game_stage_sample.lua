---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Karl2.
--- DateTime: 2021/3/4 17:08
---

local Stage = require("BHElib.scenes.stage.stage")

---@class SampleStage:Stage
local SampleStage = LuaClass("scenes.SampleStage", Stage)
Stage.registerStageClass(SampleStage)

---------------------------------------------------------------------------------------------------
---override/virtual

function SampleStage.__create(...)
    local self = Stage.__create(...)
    return self
end

function SampleStage:getDisplayName()
    return "sample stage"
end

function SampleStage:getSid()
    return "sample_stage"
end

function SampleStage:cleanup()
    Stage.cleanup(self)
end

local input = require("BHElib.input.input_and_replay")

local TestClass = Class(Object)
TestClass.frame = task.Do
function TestClass:init()
    local scr = require("BHElib.coordinates_and_screen")
    task.New(self, function()
        task.Wait(60)
        for i = 1, 10000000 do
            local w, h = 192 + 96 * sin(i), 224 + 112 * cos(i)
            scr.setPlayFieldBoundary(-w, w, -h, h)
            scr.setOutOfBoundDeletionBoundary(-w - 30, w + 30, -h - 30, h + 30)
            task.Wait(1)
        end
    end)
end
RegisterGameClass(TestClass)

function SampleStage:update(dt)
    Stage.update(self, dt)

    if self.timer > 1.5 and self.timer < 2.5 then
        local obj = New(TestClass)
        obj.img = "image:test"
    end

    if self.timer > 60.5 and self.timer < 61.5 then
        local Menu = require("BHElib.scenes.menu.menu_scene")
        local SceneTransition = require("BHElib.scenes.scene_transition")
        SceneTransition.transitionTo(self, Menu())
    end

    if input.isAnyRecordedKeyDown("down") then
        for _=1, 9 do
            if ran:Float(0, 1) > 0 then
                local obj = New(Object)
                obj.img = "image:test"
                obj.vx = ran:Float(-4, 4)
                obj.vy = ran:Float(-4, 4)
            end
        end
    end
end


return SampleStage