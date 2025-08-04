//
package game
//
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:time"
import "debug"
import "timer"
import rl "vendor:raylib"


// ----------------- Tipos auxiliares -------------------

Vec2 :: struct {
	x, y: f32,
}

distance_squared :: proc(a, b: Vec2) -> f32 {
	dx := a.x - b.x
	dy := a.y - b.y
	return dx * dx + dy * dy
}

// ----------------- Componentes ------------------------

OnCollideProc :: proc(ctx: rawptr, other: ^Collider)

Collider :: struct {
	position: Vec2,
	radius:   f32,
	// ctx:        rawptr,
	// on_collide: OnCollideProc,
}

Entity :: struct {
	name:     string,
	position: Vec2,
	// collider_index: int,
	collider: ^Collider,
	color:    rl.Color,
}

// ----------------- Sistema de Colisão ------------------

CollisionSystem :: struct {
	colliders: [dynamic]Collider,
}

// Adiciona collider ao sistema e retorna índice
add_collider :: proc(sys: ^CollisionSystem, collider: Collider) -> ^Collider {
	append(&sys.colliders, collider)
	return &sys.colliders[len(sys.colliders) - 1]
}


// Atualiza colisões entre colliders
update_collisions :: proc(sys: ^CollisionSystem) {
	for i in 0 ..< len(sys.colliders) {
		for j in i + 1 ..< len(sys.colliders) {
			a := &sys.colliders[i]
			b := &sys.colliders[j]
			r := a.radius + b.radius
			if distance_squared(a.position, b.position) <= r * r {
				// if a.on_collide != nil {
				// 	a.on_collide(a.ctx, b)
				// }
				// if b.on_collide != nil {
				// 	b.on_collide(b.ctx, a)
				// }
			}
		}
	}
}

random_int_between :: proc(min: int, max: int) -> int {
	// rand.float32() gera f32 entre [0, 1)
	// multiplicamos por (max‑min+1), depois truncamos por conversão para int
	return min + int(rand.float32() * f32(max - min + 1))
}

// ----------------- Programa principal ------------------

main :: proc() {

	enemy_spaw_timer := timer.create(0.5)

	enemies: [dynamic]Entity = make([dynamic]Entity, 0)
	screen_width: i32 = 800
	screen_height: i32 = 600
	rl.InitWindow(screen_width, screen_height, "Collision Demo")
	rl.SetTargetFPS(60)


	// Inicializar sistema
	collision_system := CollisionSystem {
		colliders = make([dynamic]Collider, 0, context.allocator),
	}

	// Criar entidades
	player := Entity {
		name     = "Player",
		position = Vec2{100, 300},
		color    = rl.GREEN,
	}

	// Criar colliders com callback
	player_collider := Collider {
		position = player.position,
		radius   = 30,
		// ctx = rawptr(&player),
		// on_collide = proc(ctx: rawptr, other: ^Collider) {
		// 	entity := cast(^Entity)ctx
		// 	entity.color = rl.YELLOW
		// 	// fmt.println("{} colidiu com algo!", entity.name);
		// },
	}

	// Registrar colliders no sistema
	player.collider_index = add_collider(&collision_system, player_collider)


	// Loop principal
	for !rl.WindowShouldClose() {

		timer.update(&enemy_spaw_timer, rl.GetFrameTime())

		if (enemy_spaw_timer.ready) {
			x := random_int_between(100, 700)
			y := random_int_between(100, 500)

			ent := Entity {
				name     = "Enemy",
				position = Vec2{f32(x), f32(y)},
				color    = rl.RED,
			}

			ent_col := Collider {
				position = ent.position,
				radius   = 30,
				// ctx = rawptr(&ent),
				// on_collide = proc(ctx: rawptr, other: ^Collider) {
				// 	entity := cast(^Entity)ctx
				// 	entity.color = rl.YELLOW
				// },
			}

			// ent.collider_index = add_collider(&collision_system, ent_col)
			ent.collider = add_collider(&collision_system, ent_col)

			append(&enemies, ent)
			timer.start(&enemy_spaw_timer)
		}
		mouse_pos := rl.GetMousePosition()
		player.position.x = mouse_pos.x
		player.position.y = mouse_pos.y

		// Atualizar posição do collider com base na entidade
		// collision_system.colliders[player.collider_index].position = player.position
		// collision_system.colliders[enemy.collider_index].position = enemy.position;


		// Resetar cor antes de verificar colisão
		player.color = rl.GREEN

		// Verificar colisões
		update_collisions(&collision_system)


		// Renderizar
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawCircleV(rl.Vector2{player.position.x, player.position.y}, 30, player.color)
		rl.DrawText(
			"Player",
			i32(player.position.x - 20),
			i32(player.position.y - 50),
			10,
			rl.DARKGRAY,
		)

		for enemy in enemies {
			rl.DrawCircleV(rl.Vector2{enemy.position.x, enemy.position.y}, 30, enemy.color)
			rl.DrawText(
				"Enemy",
				i32(enemy.position.x - 20),
				i32(enemy.position.y - 50),
				10,
				rl.DARKGRAY,
			)
		}

		rl.EndDrawing()
	}

	rl.CloseWindow()

}
