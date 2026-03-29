package mapstrat

import "core:fmt"
// mapstrat is a strategy game based around maps lol

import rl "vendor:raylib"
import "core:math/noise"
import "src/utils"
import "core:image/png"

SEED :: 12345
MAP_SIZE :: [2]int{320, 200}

mkmap :: proc(in_path: string, out_path: string, data: ^GameData) {
    file, err := png.load_from_file(in_path)
    defer free(file)

    if err != nil {
        fmt.printfln("Error: the file path '%v' does not exist", in_path)
        return
    }

    width, height := file.width, file.height
    
    data.board.width = width
    data.board.height = height
    data.board.pixels = make([dynamic]MapPixel)

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

            pixel: MapPixel
            pixel.loc = [2]int{x, y}
            t: Height

            if r == 0 {
                t = .Ocean
            }
            else if r > 0 && r <= 51 {
                t = .Land0
            }
            else if r > 51 && r <= 102 {
                t = .Land1
            }
            else if r > 102 && r <= 153 {
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

            fmt.print("(", x, y, ") ->", r)
            fmt.printfln(", pixel: %v", pixel)
        }
    }
}

Height :: enum int {
    DeepOcean,
    Ocean,
    ShallowWater,
    Land0,
    Land1,
    Land2,
    Land3,
    Land4,
}

MapPixel :: struct {
    loc: [2]int,
    height: Height,
}

GameData :: struct {
    board: Board
}

Board :: struct {
    width: int,
    height: int,
    pixels: [dynamic]MapPixel
}

// generate_map :: proc(data: ^GameData) {
//     max_height := cast(int)Height.Land4
//
//     for x in 0..<MAP_SIZE.x {
//         for y in 0..<MAP_SIZE.y {
//             val := noise.noise_2d_improve_x(SEED, {cast(f64)x, cast(f64)y})
//             val = abs(val)
//             fmt.printfln("noise_val: %v", val)
//             val *= cast(f32)max_height
//             fmt.printfln("noise*max_height: %v", val)
//
//             val2 := cast(int)val
//             fmt.printfln("height val: %v", val2)
//
//             data.map_[x][y].height = cast(Height)val2
//         }
//     }
// }

get_height_color :: proc(height: Height) -> rl.Color {
    switch height {
    case .DeepOcean:
        return rl.Color{22, 33, 54, 255}
    case .Ocean:
        return rl.Color{34, 53, 73, 255}
    case .ShallowWater:
        return rl.Color{48, 88, 103, 255}
    case .Land0:
        return rl.Color{108, 168, 92, 255}
    case .Land1:
        return rl.Color{108, 128, 76, 255}
    case .Land2:
        return rl.Color{149, 153, 113, 255}
    case .Land3:
        return rl.Color{209, 207, 190, 255}
    case .Land4:
        return rl.Color{240, 235, 235, 255}
    }
    return rl.RED
}

main :: proc() {
    rl.InitWindow(1920, 1080, "mapstrat")
    rl.SetTargetFPS(144)
    defer rl.CloseWindow()
    camera: rl.Camera2D

    camera.zoom = 2
    camera.target = {0, 0}

    data := new(GameData)
    // generate_map(data)
    
    mkmap("iberia.png", "map", data)
    fmt.println("Map generated")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()
        
        rl.ClearBackground(rl.LIGHTGRAY)

        rl.DrawText("Hello, World!", 15, 15, 13, rl.Color{240, 235, 235, 255})

        rl.BeginMode2D(camera)
        defer rl.EndMode2D()
        
        scale: i32 = 4
        height := data.board.height

        for y in 0..<height {
            for x in 0..<data.board.width {
                pixel := data.board.pixels[y*height+x]
                rl.DrawRectangle(cast(i32)x*scale, cast(i32)y*scale, scale, scale, get_height_color(pixel.height))
            }
        }

        

    }
}

