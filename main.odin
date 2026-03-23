package mapstrat

import "core:fmt"
// mapstrat is a strategy game based around maps lol

import rl "vendor:raylib"
import "core:math/noise"

SEED :: 12345
MAP_SIZE :: [2]int{320, 200}

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
    map_: [MAP_SIZE.x][MAP_SIZE.y]MapPixel
}

generate_map :: proc(data: ^GameData) {
    max_height := cast(int)Height.Land4

    for x in 0..<MAP_SIZE.x {
        for y in 0..<MAP_SIZE.y {
            val := noise.noise_2d_improve_x(SEED, {cast(f64)x, cast(f64)y})
            val = abs(val)
            fmt.printfln("noise_val: %v", val)
            val *= cast(f32)max_height
            fmt.printfln("noise*max_height: %v", val)

            val2 := cast(int)val
            fmt.printfln("height val: %v", val2)
            
            data.map_[x][y].height = cast(Height)val2
        }
    }
}

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
    generate_map(data)
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()
        
        rl.ClearBackground(rl.LIGHTGRAY)

        rl.DrawText("Hello, World!", 15, 15, 13, rl.Color{240, 235, 235, 255})


        rl.BeginMode2D(camera)
        defer rl.EndMode2D()
        

        scale: i32 = 4
        for px, x in data.map_ {
            for py, y in px {
                rl.DrawRectangle(cast(i32)x*scale, cast(i32)y*scale, scale, scale, get_height_color(py.height))
            }
        }

        

    }
}

