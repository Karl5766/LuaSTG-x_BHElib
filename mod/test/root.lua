Include("BHElib_init.lua")

LoadImageFromFile("test:image", "data_assets/THlib/bullet/Magic1.png")
local _stage_group_menu = StageGroup.new("main_menu", "MENU", nil)
local _stage_menu = Stage.new("stage_main_menu", "", nil)
_stage_group_menu:appendStage(_stage_menu)
_stage_group_menu:enter(nil, _stage_menu)

LoadTexture("textest", "THlib/bullet/bullet_ball_huge.png")
LoadImage("imgtext", "textest", 0, 0, 32, 32, 10, 10, 1)
print("Image successfully loaded")