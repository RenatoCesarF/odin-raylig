package entity

import math "core:math"
import rl "vendor:raylib"

import collider "../collider"

Player :: struct {
	position:  rl.Vector2,
	texture:   rl.Texture2D,
	collision: ^collider.Collider,
	height:    f32,
	width:     f32,
	rotation:  f32,
}

update :: proc(this: ^Player) {
	if is_moving(this) {
		amplitude: f32 = 10.0 // Maximum rotation angle
		speed: f32 = 10.0 // Oscillation speed
		this.rotation = amplitude * math.sin(f32(rl.GetTime()) * speed)
		return
	}
	this.rotation = 0
}

is_moving :: proc(this: ^Player) -> bool {
	return(
		rl.IsKeyDown(rl.KeyboardKey.W) ||
		rl.IsKeyDown(rl.KeyboardKey.A) ||
		rl.IsKeyDown(rl.KeyboardKey.S) ||
		rl.IsKeyDown(rl.KeyboardKey.D) \
	)
}


draw :: proc(this: ^Player) {
	rl.DrawTexturePro(
		this.texture,
		{0.0, 0.0, this.width, this.height},
		{this.position.x, this.position.y, this.width * 2, this.height * 2},
		{this.width, this.height},
		this.rotation,
		rl.WHITE,
	)
}
