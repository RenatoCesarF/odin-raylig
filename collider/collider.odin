package collider


import fmt "core:fmt"
import rl "vendor:raylib"

// TODO: Event system? 

CollisionSystem :: struct {
	colliders: [dynamic]Collider,
}

Shape :: union {
	RecShape,
	CircleShape,
}

RecShape :: struct {
	width, height: f32,
}

CircleShape :: struct {
	radius: f32,
}

Collider :: struct {
	collisions: [dynamic]Collider,
	x, y:       f32,
	shape:      Shape,
	color:      rl.Color,
	enable:     bool,
}

create :: proc(this: ^CollisionSystem, x, y: f32, shape: Shape) -> ^Collider {
	collider := Collider{{}, x, y, shape, randomColor(), true}

	append(&this.colliders, collider)

	return &this.colliders[len(this.colliders) - 1]
}

update :: proc(this: ^Collider, x, y: f32) {
	this.x = x
	this.y = y
}

checkCollisions :: proc(this: ^CollisionSystem) {
	for &colA in this.colliders {
		colA.color = rl.RED
		for &colB in this.colliders {
			if (&colA == &colB) {
				continue
			}
			checkCollision(&colA, &colB)
		}
	}
}

draw :: proc(this: ^CollisionSystem) {
	for p, index in this.colliders {
		switch s in p.shape {
		case CircleShape:
			rl.DrawCircleLines(i32(p.x) * 5, i32(p.y) * 5, s.radius * 5, p.color * 5)
			break
		case RecShape:
			posStr := fmt.caprintf("x %d y %d", i32(p.x), i32(p.y))
			sizeStr := fmt.caprintf("w %d H %d", i32(s.width), i32(s.height))

			rl.DrawRectangleLinesEx(
				rl.Rectangle{height = s.height * 5, width = s.width * 5, x = p.x * 5, y = p.y * 5},
				2,
				p.color,
			)

			rl.DrawTextEx(
				rl.GetFontDefault(),
				posStr,
				rl.Vector2{p.x * 5 - 10, p.y * 5 - 10},
				18,
				1,
				rl.BLACK,
			)

			rl.DrawTextEx(
				rl.GetFontDefault(),
				sizeStr,
				rl.Vector2{p.x * 5 - 10, p.y * 5 + s.height * 5},
				18,
				1,
				rl.BLACK,
			)
			break
		}
	}
}

checkCollision :: proc(colA, colB: ^Collider) {
	switch shapeA in colA.shape {
	case RecShape:
		switch shapeB in colB.shape {
		case RecShape:
			if rect_rect_collision_check(colA, colB, shapeA, shapeB) {
				colA.color = rl.GREEN
				colB.color = rl.GREEN
				return
			}
		case CircleShape:
			break
		}
	case CircleShape:
		switch shapeB in colB.shape {
		case RecShape:
			break
		case CircleShape:
			if (circle_circle_collision_check(colA, colB, shapeA, shapeB)) {
				colA.color = rl.GREEN
				colB.color = rl.GREEN
				return
			}
			break

		}
		break
	}
}

randomColor :: proc() -> rl.Color {
	return rl.RED
}

circle_circle_collision_check :: proc(colA, colB: ^Collider, shapeA, shapeB: CircleShape) -> bool {
	dx := colB.x - colA.x
	dy := colB.y - colA.y
	distance_squared := dx * dx + dy * dy
	radius_sum := shapeA.radius + shapeB.radius

	return distance_squared <= radius_sum * radius_sum
}


rect_rect_collision_check :: proc(colA, colB: ^Collider, shapeA, shapeB: RecShape) -> bool {
	leftA := colA.x
	rightA := colA.x + shapeA.width
	topA := colA.y
	bottomA := colA.y + shapeA.height

	leftB := colB.x
	rightB := colB.x + shapeB.width
	topB := colB.y
	bottomB := colB.y + shapeB.height

	collidedX := rightA > leftB && leftA < rightB
	collidedY := bottomA > topB && topA < bottomB

	return collidedX && collidedY
}
