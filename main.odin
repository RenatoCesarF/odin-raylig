package game

import fmt "core:fmt"
import math "core:math"
import rnd "core:math/rand"
import rl "vendor:raylib"

import vfx "/vfx/"
import entity "entities"

SCREEN_WITH :: 800
SCREEN_HEIGHT :: 450

VIRTUAL_RATIO :: 5
VIRTUAL_WITH :: SCREEN_WITH / VIRTUAL_RATIO
VIRTUAL_HEIGHT :: SCREEN_HEIGHT / VIRTUAL_RATIO


main :: proc() {
	rl.InitWindow(SCREEN_WITH, SCREEN_HEIGHT, "Game")
	rl.SetWindowPosition(200, 200)
	rl.SetWindowState({.WINDOW_RESIZABLE})


	partSystem := vfx.ParticleSystem {
		particles = {},
	}

	//----- Player
	text := rl.LoadTexture("./assets/image.png")
	defer rl.UnloadTexture(text)

	player := entity.Player {
		texture  = text,
		width    = f32(text.width),
		height   = f32(text.height),
		x        = 100,
		y        = 50,
		rotation = 0,
	}


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
		{

			// cameraX = (math.sin(rl.GetTime()) * 50) - 10
			// cameraY = math.cos(rl.GetTime()) * 30

			// screenSpaceCamera.target = rl.Vector2{f32(cameraX), f32(cameraY)}

			// worldSpaceCamera.target.x = math.trunc_f32(screenSpaceCamera.target.x)
			// screenSpaceCamera.target.x -= worldSpaceCamera.target.x
			// screenSpaceCamera.target.x *= VIRTUAL_RATIO

			// worldSpaceCamera.target.y = math.trunc_f32(screenSpaceCamera.target.y)
			// screenSpaceCamera.target.y -= worldSpaceCamera.target.y
			// screenSpaceCamera.target.y *= VIRTUAL_RATIO
		}
		//------- Events
		if (rl.IsKeyDown(rl.KeyboardKey.D)) {
			player.x += 30 * rl.GetFrameTime()
		}
		if (rl.IsKeyDown(rl.KeyboardKey.A)) {
			player.x -= 30 * rl.GetFrameTime()
		}

		if (rl.IsKeyDown(rl.KeyboardKey.S)) {
			player.y += 30 * rl.GetFrameTime()
		}
		if (rl.IsKeyDown(rl.KeyboardKey.W)) {
			player.y -= 30 * rl.GetFrameTime()
		}

		if (rl.IsKeyDown(rl.KeyboardKey.G)) {
			vfx.emit(
				&partSystem,
				vfx.ParticleProps {
					position = {player.x, player.y + player.height - 2},
					velocity = {-1, -1},
					colorBegin = rl.BROWN,
					colorEnd = {255, 255, 255, 0},
					lifeTime = 2,
					velocityVariation = {5, 2},
				},
			)

		}


		//------- Update
		{
			vfx.update(&partSystem)
			entity.update(&player)

			// -- foot particles
			if entity.is_moving(&player) {
				// for i in 0 ..< 4 {
				vfx.emit(
					&partSystem,
					vfx.ParticleProps {
						position = {player.x, player.y + player.height - 1},
						positionVariation = {10, 0},
						velocity = {-4, -4},
						colorBegin = {200, 200, 200, 255},
						colorEnd = {255, 255, 255, 0},
						lifeTime = .3,
						velocityVariation = {8, 3},
					},
				)
				// }
			}

			// -- Remove dead particles
		}

		//------- Draw 
		{
			rl.BeginTextureMode(target)
			rl.ClearBackground(rl.BLUE)
			rl.BeginMode2D(worldSpaceCamera)
			{
				vfx.draw(&partSystem)
				entity.draw(&player)


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

				// fmt.fmt_cstring(),
				rl.DrawTexturePro(
					target.texture,
					virtualSourceRec,
					virtualDestRec,
					{0, 0},
					0,
					rl.WHITE,
				)

				cstr := fmt.caprintf("rotation %f", player.rotation)
				rl.DrawText(cstr, 10, 10, 20, rl.BLACK)

				rl.DrawText(
					fmt.caprintf("particle amount: %d", len(partSystem.particles)),
					10,
					40,
					20,
					rl.BLACK,
				)
			}
			rl.EndMode2D()
			rl.EndDrawing()
		}

	}
	rl.UnloadRenderTexture(target)
	rl.CloseWindow()
	return
}
