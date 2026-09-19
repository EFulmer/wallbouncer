package main

import "core:os"
import "core:time"
import "vendor:raylib"

main :: proc() {
    raylib.InitWindow(640, 480, "Tope!")
    raylib.BeginDrawing()
    raylib.EndDrawing()
    time.accurate_sleep(time.Second * 3)
    os.exit(0)
}
