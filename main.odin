package game

import fmt "core:fmt"
import math "core:math"
import rnd "core:math/rand"
import rl "vendor:raylib"

import vfx "/vfx/"
import collider "collider"
import entity "entity"

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

	collisionSystem := collider.CollisionSystem {
		colliders = {},
	}

	collider.create(&collisionSystem, 10, 40, collider.RecShape{10, 30})
	collider.create(&collisionSystem, 20, 40, collider.RecShape{10, 30})

	g_texture := rl.LoadTexture("./assets/goblin.png")
	defer rl.UnloadTexture(g_texture)

	//----- Player
	p_texture := rl.LoadTexture("./assets/image.png")
	defer rl.UnloadTexture(p_texture)

	player := entity.Player {
		texture  = p_texture,
		width    = f32(p_texture.width),
		height   = f32(p_texture.height),
		position = {40, 60},
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
		{
			if (rl.IsKeyDown(rl.KeyboardKey.D)) {
				player.position.x += 30 * rl.GetFrameTime()
			}
			if (rl.IsKeyDown(rl.KeyboardKey.A)) {
				player.position.x -= 30 * rl.GetFrameTime()
			}

			if (rl.IsKeyDown(rl.KeyboardKey.S)) {
				player.position.y += 30 * rl.GetFrameTime()
			}
			if (rl.IsKeyDown(rl.KeyboardKey.W)) {
				player.position.y -= 30 * rl.GetFrameTime()
				collider.create(&collisionSystem, 40, 32, collider.RecShape{10, 30})
			}

		}

		//------- Update
		{
			vfx.update(&partSystem)
			entity.update(&player)
			collider.checkCollisions(&collisionSystem)

			collider.update(
				&collisionSystem.colliders[0],
				f32(rl.GetMouseX() / 5),
				f32(rl.GetMouseY() / 5),
			)

			// -- foot particles
			if entity.is_moving(&player) {
				vfx.emit(
					&partSystem,
					vfx.ParticleProps {
						position = {player.position.x, player.position.y + player.height - 1},
						positionVariation = {10, 0},
						velocity = {-4, -4},
						colorBegin = {200, 200, 200, 255},
						colorEnd = {255, 255, 255, 0},
						lifeTime = .3,
						velocityVariation = {8, 3},
					},
				)
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
				collider.draw(&collisionSystem)

				rl.DrawTexturePro(
					g_texture,
					{0.0, 0.0, 8, 8},
					{10, 20, 16, 16},
					{8, 8},
					0,
					rl.WHITE,
				)


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
