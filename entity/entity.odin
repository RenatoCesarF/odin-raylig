package entity

import "core:fmt"
import math "core:math"
import rl "vendor:raylib"

import collider "../collider"

Entity :: struct {
	life:           i8,
	max_life:       i8,
	position:       rl.Vector2,
	aceleration:    rl.Vector2,
	texture:        rl.Texture2D,
	collisionIndex: int, //^collider.Collider,
	height:         f32,
	width:          f32,
	rotation:       f32,
}

create :: proc(texture: rl.Texture2D, position: rl.Vector2) -> Entity {
	return Entity {
		texture = texture,
		width = f32(texture.width),
		height = f32(texture.height),
		position = position,
		aceleration = {0, 0},
		rotation = 0,
		max_life = 10,
		life = 10,
	}
}


update :: proc(this: ^Entity) {
	if is_moving(this) {
		amplitude: f32 = 10.0 // Maximum rotation angle
		speed: f32 = 10.0 // Oscillation speed
		this.rotation = amplitude * math.sin(f32(rl.GetTime()) * speed)
	} else {
		this.rotation = 0
	}

	this.position += this.aceleration

	this.aceleration = this.aceleration * 0.7 // damping, para simular atrito

	// if (this.collision != nil) {
	// 	this.collision.x = this.position.x - this.width / 2
	// 	this.collision.y = this.position.y - this.height / 2
	// }
}

is_moving :: proc(p: ^Entity) -> bool {
	return rl.Vector2Length(p.aceleration) > 0.01
}

draw :: proc(this: ^Entity) {
	rl.DrawTexturePro(
		this.texture,
		{0.0, 0.0, this.width, this.height},
		{this.position.x, this.position.y, this.width * 2, this.height * 2},
		{this.width, this.height},
		this.rotation,
		rl.WHITE,
	)
}
