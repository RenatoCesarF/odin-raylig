package debug

import rl "vendor:raylib"

DebugText :: struct {
	texts: [dynamic]DebugTextProps,
}


DebugTextProps :: struct {
	x, y, size: f32,
	text:       cstring,
}


create :: proc(this: ^DebugText, x, y: f32, size: f32, text: cstring) -> ^DebugTextProps {
	t := DebugTextProps{x, y, size, text}
	append(&this.texts, t)

	return &this.texts[len(this.texts) - 1]
}


draw :: proc(this: ^DebugText) {
	for text in this.texts {
		rl.DrawTextEx(
			rl.GetFontDefault(),
			text.text,
			rl.Vector2{text.x, text.y},
			text.size,
			1,
			rl.BLACK,
		)
	}

}
