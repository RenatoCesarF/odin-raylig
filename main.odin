package game

// import fmt "core:fmt"
// import math "core:math"
// import rnd "core:math/rand"
// import "core:math/rand"
// import rl "vendor:raylib"
//
// import vfx "/vfx/"
// import collider "collider"
// import config "config"
// import debug "debug"
// import entity "entity"
// import timer "timer"
//
// collisionSystem: collider.CollisionSystem
//
// enemies: [dynamic]entity.Entity
//
// main :: proc() {
// 	rl.InitWindow(config.SCREEN_WIDTH, config.SCREEN_HEIGHT, "Game")
// 	rl.SetWindowPosition(200, 200)
// 	rl.SetWindowState({.WINDOW_RESIZABLE})
//
// 	debug_mode := true
//
// 	// --- INIT SYSTEMS --
// 	timers: [dynamic]timer.Timer
//
// 	debugText := debug.DebugText {
// 		texts = {},
// 	}
// 	partSystem := vfx.ParticleSystem {
// 		particles = {},
// 	}
// 	collisionSystem = collider.CollisionSystem {
// 		colliders = {},
// 	}
//
// 	// --- Instancing --- 
//
// 	enemy_spaw_timer := timer.create(5)
// 	// timer.start(enemy_spaw_timer)
//
// 	debug_collider := debug.create(&debugText, 0, 0, 20, "")
//
// 	//----- Enemy
// 	g_texture := rl.LoadTexture("./assets/goblin.png")
//
// 	//----- Player
// 	p_texture := rl.LoadTexture("./assets/image.png")
// 	defer rl.UnloadTexture(p_texture)
//
// 	player := entity.create(p_texture, rl.Vector2{0, 0})
//
// 	player.collisionIndex = collider.create(
// 		&collisionSystem,
// 		player.position.x,
// 		player.position.y,
// 		collider.RecShape{player.width + 2, player.height + 4},
// 		entity = &player,
// 		on_collide = proc(ctx: rawptr, other: ^collider.Collider) {
// 			entity := cast(^entity.Entity)ctx
// 			push_dir := normalize_vector2(entity.position - rl.Vector2{other.x, other.y})
// 			entity.aceleration += push_dir * 20 * rl.GetFrameTime()
// 			// entity.aceleration += rl.Vector2{0.1, 0.1}
// 		},
// 	)
//
// 	// --- Target
// 	target: rl.RenderTexture2D = rl.LoadRenderTexture(config.VIRTUAL_WITH, config.VIRTUAL_HEIGHT)
//
// 	//------ Camera 
// 	worldSpaceCamera: rl.Camera2D = {}
// 	worldSpaceCamera.zoom = 1
//
// 	screenSpaceCamera: rl.Camera2D = {}
// 	screenSpaceCamera.zoom = 1
//
// 	cameraX: f64 = 0
// 	cameraY: f64 = 0
//
// 	rotation: f32 = 0
//
// 	virtualSourceRec: rl.Rectangle = {0, 0, f32(target.texture.width), f32(-target.texture.height)}
// 	virtualDestRec: rl.Rectangle = {
// 		-config.VIRTUAL_RATIO,
// 		-config.VIRTUAL_RATIO,
// 		config.SCREEN_WIDTH + (config.VIRTUAL_RATIO * 2),
// 		config.SCREEN_HEIGHT + (config.VIRTUAL_RATIO * 2),
// 	}
//
// 	rl.SetTargetFPS(60)
//
//
// 	for !rl.WindowShouldClose() {
// 		{
// 			// cameraX = (math.sin(rl.GetTime()) * 50) - 10
// 			// cameraY = math.cos(rl.GetTime()) * 30
//
// 			// screenSpaceCamera.target = rl.Vector2{f32(cameraX), f32(cameraY)}
//
// 			// worldSpaceCamera.target.x = math.trunc_f32(screenSpaceCamera.target.x)
// 			// screenSpaceCamera.target.x -= worldSpaceCamera.target.x
// 			// screenSpaceCamera.target.x *= VIRTUAL_RATIO
//
// 			// worldSpaceCamera.target.y = math.trunc_f32(screenSpaceCamera.target.y)
// 			// screenSpaceCamera.target.y -= worldSpaceCamera.target.y
// 			// screenSpaceCamera.target.y *= VIRTUAL_RATIO
// 		}
// 		//------- Events
// 		{
// 			if rl.IsKeyPressed(rl.KeyboardKey.ZERO) {
// 				debug_mode = !debug_mode
// 			}
// 			// MOVEMENT
// 			if (rl.IsKeyDown(rl.KeyboardKey.D)) {
// 				player.aceleration.x += 30 * rl.GetFrameTime()
// 			}
// 			if (rl.IsKeyDown(rl.KeyboardKey.A)) {
// 				player.aceleration.x -= 30 * rl.GetFrameTime()
// 			}
//
// 			if (rl.IsKeyDown(rl.KeyboardKey.S)) {
// 				player.aceleration.y += 30 * rl.GetFrameTime()
// 			}
// 			if (rl.IsKeyDown(rl.KeyboardKey.W)) {
// 				player.aceleration.y -= 30 * rl.GetFrameTime()
// 			}
// 		}
//
// 		//------- Update
// 		{
// 			vfx.update(&partSystem)
// 			entity.update(&player)
// 			collider.update(
// 				&collisionSystem.colliders[player.collisionIndex],
// 				player.position.x - player.width / 2,
// 				player.position.y - player.height / 2,
// 			)
//
// 			timer.update(&enemy_spaw_timer, rl.GetFrameTime())
//
// 			debug_collider.text = fmt.caprintfln("enemies cound: %d", len(enemies))
//
// 			if (enemy_spaw_timer.ready) {
// 				ent := entity.create(
// 					g_texture,
// 					rl.Vector2{f32(random_int_between(0, 200)), f32(random_int_between(0, 50))},
// 				)
// 				ent.collisionIndex = collider.create(
// 					&collisionSystem,
// 					ent.position.x,
// 					ent.position.y,
// 					collider.RecShape{ent.width + 2, ent.height + 4},
// 					entity = &ent,
// 					on_collide = proc(ctx: rawptr, other: ^collider.Collider) {
// 						entity := cast(^entity.Entity)ctx
// 						push_dir := normalize_vector2(
// 							entity.position - rl.Vector2{other.x, other.y},
// 						)
// 						entity.aceleration += push_dir * 20 * rl.GetFrameTime()
// 					},
// 				)
// 				append(&enemies, ent)
// 				timer.start(&enemy_spaw_timer)
// 			}
//
// 			for i in 0 ..< len(enemies) {
// 				direction := rl.Vector2 {
// 					player.position.x - enemies[i].position.x,
// 					player.position.y - enemies[i].position.y,
// 				}
//
// 				direction = normalize_vector2(direction)
//
// 				enemies[i].aceleration.x += direction.x * 10 * rl.GetFrameTime()
// 				enemies[i].aceleration.y += direction.y * 10 * rl.GetFrameTime()
//
// 				entity.update(&enemies[i])
// 				collider.update(
// 					&collisionSystem.colliders[enemies[i].collisionIndex],
// 					enemies[i].position.x - enemies[i].width / 2,
// 					enemies[i].position.y - enemies[i].height / 2,
// 				)
// 			}
//
// 			collider.checkCollisions(&collisionSystem)
//
// 			// -- foot particles
// 			if entity.is_moving(&player) {
// 				vfx.emit(
// 					&partSystem,
// 					vfx.ParticleProps {
// 						position = {player.position.x, player.position.y + player.height - 1},
// 						positionVariation = {10, 0},
// 						velocity = {-4, -4},
// 						colorBegin = {200, 200, 200, 255},
// 						colorEnd = {255, 255, 255, 0},
// 						lifeTime = .3,
// 						velocityVariation = {8, 3},
// 					},
// 				)
// 			}
//
// 		}
//
// 		//------- Draw 
// 		{
// 			rl.BeginTextureMode(target)
// 			rl.ClearBackground(rl.BLUE)
// 			rl.BeginMode2D(worldSpaceCamera)
// 			{
// 				vfx.draw(&partSystem)
// 				entity.draw(&player)
// 				for i in 0 ..< len(enemies) {
// 					entity.draw(&enemies[i])
// 				}
// 			}
// 			rl.EndMode2D()
// 			rl.EndTextureMode()
// 		}
//
//
// 		//------ BLIP TO BIG DISPLAY
// 		{
// 			rl.BeginDrawing()
// 			rl.ClearBackground(rl.WHITE)
// 			rl.BeginMode2D(screenSpaceCamera)
// 			{
// 				// UI STUFF:
//
// 				// Blip virtual screen to mainScreen
//
// 				rl.DrawTexturePro(
// 					target.texture,
// 					virtualSourceRec,
// 					virtualDestRec,
// 					{0, 0},
// 					0,
// 					rl.WHITE,
// 				)
// 				// if debug_mode {
// 				collider.draw(&collisionSystem)
// 				debug.draw(&debugText)
// 				// }
//
// 				rl.DrawFPS(50, 50)
// 			}
// 			rl.EndMode2D()
// 			rl.EndDrawing()
// 		}
//
// 	}
// 	rl.UnloadRenderTexture(target)
// 	rl.CloseWindow()
// 	return
// }
//
// normalize_vector2 :: proc(v: rl.Vector2) -> rl.Vector2 {
// 	lenght := math.sqrt(v.x * v.x + v.y * v.y)
// 	if lenght != 0.0 {
// 		return rl.Vector2{v.x / lenght, v.y / lenght}
// 	}
//
// 	return rl.Vector2{0, 0}
// }
//
// random_int_between :: proc(min: int, max: int) -> int {
// 	return min + int(rand.float32() * f32(max - min + 1))
// }
