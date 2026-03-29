package utils

import "core:fmt"
import "core:image/png"

mkmap :: proc(in_path: string, out_path: string) {
    file, err := png.load_from_file(in_path)

    if err != nil {
        fmt.printfln("Error: the file path '%v' does not exist", in_path)
    }

    width, height := file.width, file.height
    
    i := 0
    buf := file.pixels.buf
    for y in 0..<height {
        for x in 0..<width {
            r := buf[i]
            g := buf[i + 1]
            b := buf[i + 2]
            a := buf[i + 3]
            i += 4

            fmt.println(x, y, "->", r, g, b, a)
        }
    }
}

