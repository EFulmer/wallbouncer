package main

import "core:math"
import "core:math/rand"
import "core:os"
import "vendor:raylib"


WINDOW_WIDTH :: 980
WINDOW_HEIGHT :: 720
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

    brick_states : [6][10]bool
    brick_states = true
    bricks := initialize_bricks()

    // Speed will vary based on difficulty, which is still to come.
    ball_speed : f32 = 8.0
    paddle_speed : f32 = 10.0
    initial_x, initial_y := rand.float32_range(-1, 1), rand.float32_range(-1, 1)
    velocity := raylib.Vector2{initial_x, initial_y}
    mag := math.sqrt(initial_x * initial_x + initial_y * initial_y)
    velocity.x /= mag
    velocity.y /= mag

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
            update_ball(&ball, &velocity, ball_speed, paddle)
            update_brick_states(ball, &brick_states, bricks, &velocity)
        }


        // Begin drawing - commenting to create additional visual distinction from surrounding code
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.DARKBLUE)
        raylib.DrawCircleV(ball, BALL_RADIUS, raylib.BEIGE)
        raylib.DrawRectangleRec(paddle, raylib.WHITE)
        draw_brick_states(brick_states, bricks)
        raylib.EndDrawing()
        // End drawing - commenting to create additional visual distinction from surrounding code
    }
    raylib.CloseWindow()
    os.exit(0)
}

update_ball :: proc(ball, velocity: ^raylib.Vector2, ball_speed: f32, paddle: raylib.Rectangle) -> () {

    // Next, the ball:
    ball^ += (velocity^ * ball_speed)
    // First we check whether the ball has collided with the paddle:
    if raylib.CheckCollisionCircleRec({ball.x, ball.y}, BALL_RADIUS, paddle) {
        // Explanation:
        // the closer to the center of the paddle we hit the ball, the more vertical we want the ball to head back,
        // so we scale the x to how far off from the center of the paddle we are,
        // then to keep the velocity a unit vector (consistent ball speed), take advantage of the Pythagorean identity,
        // c^2 == a^2 + b+2; c == 1 and a = distance ball hits from the center of the paddle
        paddle_center := paddle.x + paddle.width / 2
        hit_offset : f32 = (ball.x - paddle_center) / (paddle.width / 2)
        velocity.x = hit_offset
        velocity.y = -math.sqrt(1.0 - hit_offset * hit_offset)
        return
    }
    // Now check for collisions with the walls, which just requires a clamp and a reverse of the x component of the movement vector, aside the bottom wall:
    switch {
    case ball.x < BALL_RADIUS:
        ball.x = BALL_RADIUS
        velocity.x *= -1
    case ball.x > WINDOW_WIDTH:
        ball.x = WINDOW_WIDTH
        velocity.x *= -1
    case ball.y < BALL_RADIUS:
        ball.y = BALL_RADIUS
        velocity.y *= -1
    case ball.y > WINDOW_HEIGHT:
        // Bottom wall = respawn and send it off in a new direction.
        ball.x = WINDOW_WIDTH / 2.0
        ball.y = WINDOW_HEIGHT / 2.0
        velocity.x = rand.float32_range(-1, 1)
        velocity.y = rand.float32_range(-1, 1)
        mag := math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        velocity.x /= mag
        velocity.y /= mag
    }
}

initialize_bricks :: proc () -> [6][10]raylib.Rectangle {
    result : [6][10]raylib.Rectangle
    spacing : f32 = 1
    columns : f32 = 10
    x_margin : f32 = 30
    y_margin : f32 = 50
    board_width := WINDOW_WIDTH - (2 * x_margin) - ((columns - 1) * spacing)
    brick_width := board_width / columns
    brick_height : f32 = 10

    for row := 0; row < 6; row += 1 {
        for col := 0; col < 10; col += 1 {
            result[row][col] = raylib.Rectangle{
                x_margin + f32(col) * (brick_width + spacing),
                y_margin + f32(row) * (brick_height + spacing),
                brick_width,
                brick_height
            }
        }
    }
    return result
}

draw_brick_states :: proc(brick_states: [6][10]bool, bricks: [6][10]raylib.Rectangle) -> () {
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
    row_colors := [6]raylib.Color{
        raylib.RED,
        raylib.YELLOW,
        raylib.ORANGE,
        raylib.LIME,
        raylib.PURPLE,
        raylib.PINK
    }
    for row := 0; row < 6; row += 1 {
        for col := 0; col < 10; col += 1 {
            if !!brick_states[row][col] {
                raylib.DrawRectangleRec(
                    bricks[row][col],
                    row_colors[row]
                )
            }
        }
    }
}

// Collision subprocedure #2: ball/brick collisions
update_brick_states :: proc(ball: raylib.Vector2, brick_states: ^[6][10]bool, bricks: [6][10]raylib.Rectangle, velocity: ^raylib.Vector2) -> () {
    for row := 0; row < 6; row += 1 {
        for col := 0; col < 10; col += 1 {
            if !!brick_states[row][col] && raylib.CheckCollisionCircleRec({ball.x, ball.y}, BALL_RADIUS, bricks[row][col]) {
                brick_states[row][col] = false
                x_overlap := math.min(ball.x+BALL_RADIUS/2.0, bricks[row][col].x+bricks[row][col].width) - math.max(ball.x-BALL_RADIUS/2.0, bricks[row][col].x)
                y_overlap := math.min(ball.y+BALL_RADIUS/2.0, bricks[row][col].y+bricks[row][col].height) - math.max(ball.y-BALL_RADIUS/2.0, bricks[row][col].y)
                if x_overlap < y_overlap {
                    velocity.x *= -1
                } else {
                    velocity.y *= -1
                }
                return
            }
        }
    }
}
