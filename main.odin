package game

import math "core:math"
import rl "vendor:raylib"

SCREEN_WITH :: 800
SCREEN_HEIGHT :: 450

VIRTUAL_RATIO :: 5 
VIRTUAL_WITH :: SCREEN_WITH / VIRTUAL_RATIO
VIRTUAL_HEIGHT :: SCREEN_HEIGHT / VIRTUAL_RATIO


main :: proc() {
	rl.InitWindow(SCREEN_WITH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()

	//----- Player
	text := rl.LoadTexture("./assets/image.png")
	defer rl.UnloadTexture(text)

	fw: f32 = f32(text.width)
	fh: f32 = f32(text.height)

	sourceRec: rl.Rectangle = {0.0, 0.0, fw, fh}
	destRec: rl.Rectangle = {VIRTUAL_WITH / 2, VIRTUAL_HEIGHT / 2, fw * 2, fh * 2}

	// --- Target
	target: rl.RenderTexture2D = rl.LoadRenderTexture(VIRTUAL_WITH, VIRTUAL_HEIGHT)

	//------ Camera 
	worldSpaceCamera: rl.Camera2D = {}
	worldSpaceCamera.zoom = 1

	screenSpaceCamera: rl.Camera2D = {}
	screenSpaceCamera.zoom = 1

	cameraX: f64 = 0
	cameraY: f64 = 0

	rotation: f32 = 0

	virtualSourceRec: rl.Rectangle = {0, 0, f32(target.texture.width), f32(-target.texture.height)}
	virtualDestRec: rl.Rectangle =  {
		-VIRTUAL_RATIO,
		-VIRTUAL_RATIO,
		SCREEN_WITH + (VIRTUAL_RATIO * 2),
		SCREEN_HEIGHT + (VIRTUAL_RATIO * 2),
	}

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rotation += 2

		// cameraX = (math.sin(rl.GetTime()) * 50) - 10
		// cameraY = math.cos(rl.GetTime()) * 30

		// screenSpaceCamera.target = rl.Vector2{f32(cameraX), f32(cameraY)}

		// worldSpaceCamera.target.x = math.trunc_f32(screenSpaceCamera.target.x)
		// screenSpaceCamera.target.x -= worldSpaceCamera.target.x
		// screenSpaceCamera.target.x *= VIRTUAL_RATIO

		// worldSpaceCamera.target.y = math.trunc_f32(screenSpaceCamera.target.y)
		// screenSpaceCamera.target.y -= worldSpaceCamera.target.y
		// screenSpaceCamera.target.y *= VIRTUAL_RATIO

		//------- Draw 
		{
			rl.BeginTextureMode(target)
			rl.ClearBackground(rl.BLUE)
			rl.BeginMode2D(worldSpaceCamera)
			{

				rl.DrawTexturePro(text, sourceRec, destRec, {fw, fh}, rotation, rl.WHITE)

			}
			rl.EndMode2D()
			rl.EndTextureMode()
		}


		//------ BLIP TO BIG DISPLAY
		{
			rl.BeginDrawing()
			rl.ClearBackground(rl.WHITE)
			rl.BeginMode2D(screenSpaceCamera)
			{
				// UI STUFF:

				// Blip virtual screen to mainScreen
				rl.DrawTexturePro(
					target.texture,
					virtualSourceRec,
					virtualDestRec,
					{0, 0},
					0,
					rl.WHITE,
				)
			}
			rl.EndMode2D()
			rl.EndDrawing()
		}

	}

	rl.UnloadRenderTexture(target)
	rl.CloseWindow()

}
