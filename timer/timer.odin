package timer

import fmt "core:fmt"

Timer :: struct {
	startTime:   f32,
	currentTime: f32,
	ready:       bool,
	update:      proc(this: ^Timer),
	format:      proc(this: ^Timer),
}

update :: proc(this: ^Timer, dt: f32) {
	this.currentTime -= dt
	if (this.currentTime <= 0) {
		this.ready = true
	}
}

start :: proc(this: ^Timer) {
	if this.currentTime <= 0 {
		this.currentTime = this.startTime
		this.ready = false
		return
	}
	// timer .start
}

create :: proc(startTime: f32) -> Timer {
	return Timer{startTime = startTime, currentTime = startTime, ready = false}
}


format :: proc(this: ^Timer) -> string {
	return fmt.aprintf("cur: %d, ready: %d ", this.currentTime, this.ready)
}
