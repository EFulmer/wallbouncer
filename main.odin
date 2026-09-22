package main

import "core:math"
import "core:math/rand"
import "core:os"
import "vendor:raylib"


WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
BALL_RADIUS :: 10


main :: proc() {
    ball := raylib.Vector2{WINDOW_WIDTH / 2.0, WINDOW_HEIGHT / 2.0}
    paddle_width : f32 = 150.0
    paddle_height : f32 = 15.0
    paddle_size := [2]f32{paddle_width, paddle_height}

    paddle := raylib.Rectangle{
        WINDOW_WIDTH / 2.0 - 75.0, WINDOW_HEIGHT - 30, paddle_size[0], paddle_size[1]
    }

    paused := false
    score := 0

    bricks : [4][10]bool
    bricks = true

    // Speed will vary based on difficulty, which is still to come.
    ball_speed : f32 = 4.0
    paddle_speed : f32 = 5.0
    initial_x, initial_y := rand.float32_range(-1, 1), rand.float32_range(-1, 1)
    movement_vector := raylib.Vector2{initial_x, initial_y}
    mag := math.sqrt(initial_x * initial_x + initial_y * initial_y)
    movement_vector.x /= mag
    movement_vector.y /= mag

    raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "TopeOut!")
    raylib.SetTargetFPS(60)
    for !raylib.WindowShouldClose() {
        if raylib.IsKeyPressed(raylib.KeyboardKey.SPACE) {
            paused = !paused
        }
        if !paused {
        // Check the input
        delta_x : f32 = 0.0
        if raylib.IsKeyDown(raylib.KeyboardKey.LEFT) {
            delta_x -= paddle_speed
        }
        if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT) {
            delta_x += paddle_speed
        }
        // Handle motion - first, the paddle:
        paddle.x += delta_x
        // Paddle boundaries are easy, since the paddle can only collide with the vertical borders of the window.
        paddle.x = clamp(paddle.x, 0, WINDOW_WIDTH - paddle_width)
        update_ball(&ball, &movement_vector, ball_speed, paddle)
        }


        // Begin drawing - commenting to create additional visual distinction from surrounding code
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.DARKBLUE)
        raylib.DrawCircleV(ball, BALL_RADIUS, raylib.BEIGE)
        raylib.DrawRectangleRec(paddle, raylib.WHITE)
        draw_bricks(bricks)
        raylib.EndDrawing()
        // End drawing - commenting to create additional visual distinction from surrounding code
    }
    raylib.CloseWindow()
    os.exit(0)
}

update_ball :: proc(ball, movement_vector: ^raylib.Vector2, ball_speed: f32, paddle: raylib.Rectangle) -> () {

    // Next, the ball:
    ball^ += (movement_vector^ * ball_speed)
    // First we check whether the ball has collided with the paddle:
    if raylib.CheckCollisionCircleRec({ball.x, ball.y}, BALL_RADIUS, paddle) {
        movement_vector.x *= -1
        movement_vector.y *= -1
    }
    // Now check for collisions with the walls, which just requires a clamp and a reverse of the x component of the movement vector, aside the bottom wall:
    switch {
    case ball.x < BALL_RADIUS:
        ball.x = BALL_RADIUS
        movement_vector.x *= -1
    case ball.x > WINDOW_WIDTH:
        ball.x = WINDOW_WIDTH
        movement_vector.x *= -1
    case ball.y < BALL_RADIUS:
        ball.y = BALL_RADIUS
        movement_vector.y *= -1
    case ball.y > WINDOW_HEIGHT:
        // Bottom wall = respawn and send it off in a new direction.
        ball.x = WINDOW_WIDTH / 2.0
        ball.y = WINDOW_HEIGHT / 2.0
        movement_vector.x = rand.float32_range(-1, 1)
        movement_vector.y = rand.float32_range(-1, 1)
        mag := math.sqrt(movement_vector.x * movement_vector.x + movement_vector.y * movement_vector.y)
        movement_vector.x /= mag
        movement_vector.y /= mag
    }
}

draw_bricks :: proc(bricks: [4][10]bool) -> () {
    spacing : f32 = 1
    columns : f32 = 10
    x_margin : f32 = 30
    y_margin : f32 = 50
    board_width := WINDOW_WIDTH - (2 * x_margin) - ((columns - 1) * spacing)
    brick_width := board_width / columns
    brick_height : f32 = 10

    colors := []raylib.Color{
        raylib.BEIGE,
        raylib.BLACK,
        raylib.BLANK,
        raylib.BLUE,
        raylib.BROWN,
        raylib.DARKBLUE,
        raylib.DARKBROWN,
        raylib.DARKGRAY,
        raylib.DARKGREEN,
        raylib.DARKPURPLE,
        raylib.GOLD,
        raylib.GRAY,
        raylib.GREEN,
        raylib.LIGHTGRAY,
        raylib.LIME,
        raylib.MAGENTA,
        raylib.MAROON,
        raylib.ORANGE,
        raylib.PINK,
        raylib.PURPLE,
        raylib.RAYWHITE,
        raylib.RED,
        raylib.SKYBLUE,
        raylib.VIOLET,
        raylib.WHITE,
        raylib.YELLOW
    }
    row_colors := [4]raylib.Color{
        raylib.RED,
        raylib.YELLOW,
        raylib.ORANGE,
        raylib.LIME,
    }
    for row := 0; row < 4; row += 1 {
        for col := 0; col < 10; col += 1 {
            if !!bricks[row][col] {
                brick_rectangle := raylib.Rectangle{
                    x_margin + f32(col) * (brick_width + spacing),
                    y_margin + f32(row) * (brick_height + spacing),
                    brick_width,
                    brick_height
                }
                raylib.DrawRectangleRec(
                    brick_rectangle,
                    row_colors[row]
                )
            }
        }
    }
}
