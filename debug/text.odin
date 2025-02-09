package debug

import rl "vendor:raylib"

DebugText :: struct {
  texts: [dynamic]TextProps,
}


TextProps :: struct{
  x, y,size: f32,
  text: cstring,
}


create :: proc(this:^DebugText, x,y: f32, size: f32, text: cstring){
  t := TextProps{x, y, size, text}
  append(&this.texts, t)
}


draw :: proc(this: ^DebugText){

	for text in this.texts {
			rl.DrawTextEx(
				rl.GetFontDefault(),
				text.text,
				rl.Vector2{text.x ,text.y },
				text.size,
				1,
				rl.BLACK,
			);
	}

}

