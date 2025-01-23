package vfx

import math "core:math"
import rnd "core:math/rand"
import rl "vendor:raylib"

ParticleProps :: struct {
	position, positionVariation: rl.Vector2,
	velocity, velocityVariation: rl.Vector2,
	colorBegin, colorEnd:        rl.Color,
	// sizeBegin, sizeEnd, sizeVariation: f32,
	lifeTime:                    f32,
}

Particle :: struct {
	position:             rl.Vector2,
	velocity:             rl.Vector2,
	colorBegin, colorEnd: rl.Color,
	// rotation:             f32,
	// sizeBegin, sizeEnd:   f32,
	lifeTime, lifeRemain: f32,
	active:               bool,
}

ParticleSystem :: struct {
	particles: [dynamic]Particle,
}


emit :: proc(this: ^ParticleSystem, props: ParticleProps) {
	particle := Particle{}

	particle.active = true
	particle.position = props.position
	particle.position.x += props.positionVariation.x * (rnd.float32() - 0.5)
	particle.position.y += props.positionVariation.y * (rnd.float32() - 0.5)

	particle.velocity = props.velocity
	particle.velocity.x += props.velocityVariation.x * (rnd.float32() - 0.5)
	particle.velocity.y += props.velocityVariation.y * (rnd.float32() - 0.5)

	particle.colorBegin = props.colorBegin
	particle.colorEnd = props.colorEnd

	particle.lifeTime = props.lifeTime
	particle.lifeRemain = props.lifeTime

	append(&this.particles, particle)

	// particle.sizeBegin..
	// this.index = --this.index % len(this.particles)
}

draw :: proc(this: ^ParticleSystem) {
	for p, index in this.particles {
		life := math.clamp(p.lifeRemain / p.lifeTime, 0.0, 1.0)

		color := rl.Color {
			u8(math.lerp(f32(p.colorEnd[0]), f32(p.colorBegin[0]), f32(life))),
			u8(math.lerp(f32(p.colorEnd[1]), f32(p.colorBegin[1]), f32(life))),
			u8(math.lerp(f32(p.colorEnd[2]), f32(p.colorBegin[2]), f32(life))),
			u8(math.lerp(f32(p.colorEnd[3]), f32(p.colorBegin[3]), f32(life))),
		}
		color[3] -= color[3] * u8(life)

		rl.DrawPixelV(this.particles[index].position, color)
	}
}

update :: proc(this: ^ParticleSystem) {
	for p, index in this.particles {
		if (this.particles[index].lifeRemain <= 0) {
			this.particles[index].active = false
			unordered_remove(&this.particles, index)
		}
	}

	for p, index in this.particles {
		this.particles[index].lifeRemain -= rl.GetFrameTime()
		this.particles[index].position += this.particles[index].velocity * f32(rl.GetFrameTime())

	}
}
