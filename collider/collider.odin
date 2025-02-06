package collider

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
	height, width: f32,
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

create :: proc(this: ^CollisionSystem, x, y: f32, shape: Shape) {
	collider := Collider{{}, x, y, shape, randomColor(), true}

	append(&this.colliders, collider)
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
			rl.DrawCircleLines(i32(p.x), i32(p.y), s.radius, p.color)
			break
		case RecShape:
			rl.DrawRectangleLines(i32(p.x), i32(p.y), i32(s.width), i32(s.height), p.color)
			break
		}
	}
}

checkCollision :: proc(colA, colB: ^Collider) {
	switch shapeA in colA.shape {
	case RecShape:
		switch shapeB in colB.shape {
		case RecShape:
			startAW := colA.x - shapeA.width / 2
			endAW := colA.x + shapeA.width / 2

			startBW := colB.x - shapeB.width / 2
			endBW := colB.x + shapeB.width / 2

			startAH := colA.y - shapeA.height / 2
			endAH := colA.y + shapeA.height / 2

			startBH := colB.y - shapeB.height / 2
			endBH := colB.y + shapeB.height / 2

			collidedX := startAW < endBW && endAW > startBW
			collidedY := startAH < endBH && endAH > startBH

			if collidedX && collidedY {
				colA.color = rl.GREEN
				colB.color = rl.GREEN
				return
			}
		case CircleShape:
			break
		}
	case CircleShape:
		break
	}
}

randomColor :: proc() -> rl.Color {
	return rl.RED
}
