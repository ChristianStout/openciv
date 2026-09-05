package mapstrat

import "core:fmt"
// mapstrat is a strategy game based around maps lol

import rl "vendor:raylib"
import "core:math/noise"
import "src/utils"
import "core:image/png"

SEED :: 12345
MAP_SIZE :: [2]int{1983, 1336}
MAX_CAMERA_ZOOM_OUT :: -1
MAX_CAMERA_ZOOM_IN :: 3
BACKGROUND_COLOR :: rl.Color{0, 0, 38, 255}
ZOOM_AMOUNT :: 0.3

mkmap :: proc(in_path: string, out_path: string, data: ^GameData) {
    data.board.colors = rl.LoadTexture("assets/textures/map_colors.png")
    data.board.height_map = gen_height_color_map()

    file, err := png.load_from_file(in_path)
    defer free(file)

    if err != nil {
        fmt.printfln("Error: the file path '%v' does not exist", in_path)
        return
    }

    width, height := file.width, file.height

    image := rl.GenImageColor(cast(i32)width, cast(i32)height, data.board.height_map[.Ocean])
    data.board.image = image
    
    data.board.width = width
    data.board.height = height
    data.board.pixels = make([dynamic]MapCell)

    i := 0
    buf := file.pixels.buf
    for y in 0..<height {
        for x in 0..<width {
            r := buf[i]
            g := buf[i + 1]
            b := buf[i + 2]
            a := buf[i + 3]
            i += 4
    
            assert(r == g && r == b && a == 255)

            pixel: MapCell
            pixel.loc = [2]int{x, y}
            t: Height

            if r == 0 {
                t = .Ocean
            }
            else if r > 0 && r <= 15 {
                t = .Land0
            }
            else if r > 15 && r <= 42 {
                t = .Land1
            }
            else if r > 42 && r <= 153 {
                t = .Land2
            }
            else if r > 153 && r <= 204 {
                t = .Land3
            }
            else {
                t = .Land4
            }
            
            pixel.height = t
            append(&data.board.pixels, pixel)

            rl.ImageDrawPixel(&image, cast(i32)x, cast(i32)y, data.board.height_map[t])

            // fmt.print("(", x, y, ") ->", r)
            // fmt.printfln(", pixel: %v", pixel)
        }
    }
    data.board.texture = rl.LoadTextureFromImage(image)
}

Height :: enum int {
    Ocean,
    Land0,
    Land1,
    Land2,
    Land3,
    Land4,
}

MapCell :: struct {
    loc: [2]int,
    height: Height,
}

GameData :: struct {
    board: Board
}

Board :: struct {
    width: int,
    height: int,
    pixels: [dynamic]MapCell,
    colors: rl.Texture,
    height_map: map[Height]rl.Color,
    image: rl.Image,
    texture: rl.Texture,
}

gen_height_color_map :: proc() -> map[Height]rl.Color {
    height_map := make(map[Height]rl.Color)
    len: f32 = 1.0
    
    height_map[.Ocean] = rl.Color{101, 153, 225, 255}
    height_map[.Land0] = rl.Color{90, 184, 77, 255}
    height_map[.Land1] = rl.Color{115, 214, 102, 255}
    height_map[.Land2] = rl.Color{204, 211, 113, 255}
    height_map[.Land3] = rl.Color{209, 230, 206, 255}
    height_map[.Land4] = rl.Color{240, 247, 239, 255}

    return height_map
}

handle_mouse_input :: proc(camera: ^rl.Camera2D, data: ^GameData) {
    mouse_pos := rl.GetMousePosition()
    mouse_wheel_move := rl.GetMouseWheelMove()
    mouse_held_down := rl.IsMouseButtonDown(.LEFT)
    if mouse_wheel_move < 0 && camera.zoom >= MAX_CAMERA_ZOOM_OUT && camera.zoom > ZOOM_AMOUNT {
        camera.zoom -= ZOOM_AMOUNT
        camera.target = mouse_pos
    }
    if mouse_wheel_move > 0 && camera.zoom <= MAX_CAMERA_ZOOM_IN {
        camera.zoom += ZOOM_AMOUNT
        camera.target = mouse_pos
    }
    if mouse_held_down {
        camera.offset += rl.GetMouseDelta()
    }
}

main :: proc() {
    rl.InitWindow(1983, 1336, "mapstrat")
    rl.SetTargetFPS(144)
    defer rl.CloseWindow()
    camera: rl.Camera2D

    camera.zoom = 1
    camera.target = {0, 0}

    data := new(GameData)
    // generate_map(data)
    
    mkmap("iberia.png", "map", data)
    fmt.println("Map generated")
    height_map := gen_height_color_map()

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()
        
        rl.ClearBackground(BACKGROUND_COLOR)

        rl.DrawText("Hello, World!", 15, 15, 13, rl.Color{240, 235, 235, 255})

        rl.BeginMode2D(camera)
        
        scale: f32 = 1
        height := data.board.height
        i := 0

        handle_mouse_input(&camera, data)

        // for y in 0..<height {
        //     for x in 0..<data.board.width {
        //
        //         pixel := data.board.pixels[i]
        //         i += 1
        //         // rl.DrawRectangle(cast(i32)x*scale, cast(i32)y*scale, scale, scale, get_height_color(pixel.height))
        //         // rl.DrawTexture(data.board.colors, 50, 50, rl.GRAY)
        //         // rl.DrawTextureRec(data.board.colors, height_map[pixel.height], {cast(f32)x*scale, cast(f32)y*scale}, rl.WHITE)
        //         // rl.DrawTextureRec()
        //         // rl.DrawRectangle
        //     }
        // }
        rl.DrawTexture(data.board.texture, 0, 0, rl.WHITE)
        //
        // size := 50
        // height2 := Height.Land0
        // pos: f32 = 200
        // m := gen_height_color_map()
        //
        // for y in 0..<size {
        //     for x in 0..<size {
        //         rl.DrawTextureRec(data.board.colors, m[height2], {cast(f32)x+pos, cast(f32)y+pos}, rl.WHITE)
        //     }
        // }

        rl.EndMode2D()
        rl.DrawFPS(0, 0)
        rl.DrawText(fmt.caprint("zoom: %v", camera.zoom), 15, 30, 13, rl.WHITE)
    }
}

