package collider


import fmt "core:fmt"
import rl "vendor:raylib"

import "../config"
import "../entity"

OnCollideProc :: proc(ctx: rawptr, other: ^Collider)

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
	ctx:        rawptr,
	on_collide: OnCollideProc,
	// entity_ptr:   ^entity.Entity,
}

create :: proc(
	this: ^CollisionSystem,
	x, y: f32,
	shape: Shape,
	entity: ^entity.Entity,
	on_collide: proc(ctx: rawptr, other: ^Collider),
) -> int {
	collider := Collider {
		collisions = {},
		x          = x,
		y          = y,
		shape      = shape,
		color      = randomColor(),
		enable     = true,
		ctx        = entity,
		on_collide = on_collide,
	}
	append(&this.colliders, collider)
	return len(this.colliders) - 1
}

update :: proc(this: ^Collider, x, y: f32) {
	this.x = x
	this.y = y
}

checkCollisions :: proc(this: ^CollisionSystem) {
	for i in 0 ..< len(this.colliders) {
		this.colliders[i].color = rl.RED
		for j in 0 ..< len(this.colliders) {
			if i == j {
				continue
			}
			if checkCollided(&this.colliders[i], &this.colliders[j]) {
				if this.colliders[i].on_collide != nil {
					this.colliders[i].on_collide(this.colliders[i].ctx, &this.colliders[j])
				}
				if this.colliders[j].on_collide != nil {
					this.colliders[j].on_collide(this.colliders[j].ctx, &this.colliders[i])
				}
			}
		}
	}
}

draw :: proc(this: ^CollisionSystem) {
	for p, index in this.colliders {
		switch s in p.shape {
		case CircleShape:
			rl.DrawCircleLines(
				i32(p.x) * config.VIRTUAL_RATIO,
				i32(p.y) * config.VIRTUAL_RATIO,
				s.radius * config.VIRTUAL_RATIO,
				p.color * config.VIRTUAL_RATIO,
			)
			break
		case RecShape:
			posStr := fmt.caprintf("x %d y %d", i32(p.x), i32(p.y))
			sizeStr := fmt.caprintf("w %d H %d", i32(s.width), i32(s.height))

			rl.DrawRectangleLinesEx(
				rl.Rectangle {
					height = s.height * config.VIRTUAL_RATIO,
					width = s.width * config.VIRTUAL_RATIO,
					x = p.x * config.VIRTUAL_RATIO,
					y = p.y * config.VIRTUAL_RATIO,
				},
				2,
				p.color,
			)

			rl.DrawTextEx(
				rl.GetFontDefault(),
				posStr,
				rl.Vector2{p.x * config.VIRTUAL_RATIO - 10, p.y * config.VIRTUAL_RATIO - 10},
				18,
				1,
				rl.BLACK,
			)

			rl.DrawTextEx(
				rl.GetFontDefault(),
				sizeStr,
				rl.Vector2 {
					p.x * config.VIRTUAL_RATIO - 10,
					p.y * config.VIRTUAL_RATIO + s.height * config.VIRTUAL_RATIO,
				},
				18,
				1,
				rl.BLACK,
			)
			break
		}

	}
}

checkCollided :: proc(colA, colB: ^Collider) -> bool {
	switch shapeA in colA.shape {

	case RecShape:
		switch shapeB in colB.shape {
		case RecShape:
			if rect_rect_collision_check(colA, colB, shapeA, shapeB) {
				return true
			}
		case CircleShape:
			break
		}
	case CircleShape:
		switch shapeB in colB.shape {
		case RecShape:
			break
		case CircleShape:
			return circle_circle_collision_check(colA, colB, shapeA, shapeB)}
		break
	}
	return false
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
