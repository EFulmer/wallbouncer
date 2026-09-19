package main

import "core:os"
import "core:time"
import "vendor:raylib"

main :: proc() {
    raylib.InitWindow(640, 480, "Tope!")
    raylib.SetTargetFPS(60)
    for !raylib.WindowShouldClose() {
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.DARKBLUE)
        raylib.EndDrawing()
    }
    os.exit(0)
}
