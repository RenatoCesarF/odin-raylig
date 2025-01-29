package timer

import fmt "core:fmt"

Timer :: struct {
	startTime:   f16,
	currentTime: f32,
	ready:       bool,
	update:      proc(this: ^Timer),
	format:      proc(this: ^Timer),
}

update :: proc(this: ^Timer, dt: f32) {
	this.currentTime -= dt
}


start :: proc(this: ^Timer) {
	if this.startTime <= 0 {
		//stop
		// return
	}
	// timer .start

}


format :: proc(this: ^Timer) -> string {
	return fmt.aprintf("cur: %d, ready: %d ", this.currentTime, this.ready)
}
