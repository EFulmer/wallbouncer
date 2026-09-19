package main

import "core:os"
import "core:time"
import "vendor:raylib"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
BALL_RADIUS :: 10


main :: proc() {
    ball := raylib.Vector2{WINDOW_WIDTH / 2.0, WINDOW_HEIGHT / 2.0}
    paddle_size := [2]f32{150.0, 15.0}

    paddle := raylib.Rectangle{
        // TODO some more tweaking for the center
        WINDOW_WIDTH / 2.0 - 75.0, WINDOW_HEIGHT - 30, paddle_size[0], paddle_size[1]
    }

    raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Tope!")
    raylib.SetTargetFPS(60)
    for !raylib.WindowShouldClose() {
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.DARKBLUE)
        raylib.DrawCircleV(ball, BALL_RADIUS, raylib.BEIGE)
        raylib.DrawRectangleRec(paddle, raylib.WHITE)
        raylib.EndDrawing()
    }
    raylib.CloseWindow()
    os.exit(0)
}
