# -*- coding: utf-8 -*-
module Utility

export save_ppm_file, clamp, to_int

function save_ppm_file(filename, image)
    height, width, ch = size(image)
    open(filename, "w") do f
        write(f, "P3\n$width $height\n255\n")
        for i in 1:height
            for j in 1:width
                write(f, join(string.(image[i, j,:]), ' ') * "\n")
            end
        end
    end
end

function clamp(x::AbstractFloat, low=0.0, high=1.0)
    if x < 0.0
        return zero(x)
    elseif 1.0 < x
        return one(x)
    else
        return x
    end
end

to_int(x) = x^(1 / 2.2) * 255 |> round |> Int

end


function test_utility()
    # save_ppm_file test
    filename = "test.ppm"
    image = zeros(UInt8, (480, 640, 3))
    image[div(size(image)[1], 2), 1:end, :] = 255
    save_ppm_file(filename, image)

    f = open(filename, "r")
    readline(f)
    width, height = readline(f) |> x -> split(x, " ") |> x -> parse.(x)
    @assert (width, height) == (640, 480)
    max_value = parse(Int, readline(f))
    @assert max_value == 255

    tmp_image = zeros(UInt8, height * width * 3)

    for (i, x) in enumerate(eachline(f))
        tmp_image[3(i - 1) + 1: 3i] = [parse(UInt8, y) for y in split(x, " ")]
    end

    tmp_image = reshape(tmp_image, (3, width, height)) |> x -> permutedims(x, [3, 2, 1])
    @assert tmp_image == image

    rm(filename)

    println("save_ppm_file test: OK")

    # clamp test
    x = -1.0
    y = clamp(x)
    @assert y == 0.0

    x = 2.0
    y = clamp(x)
    @assert y == 1.0

    x = 0.5
    y = clamp(x)
    @assert y == 0.5

    println("clamp test: OK")

    # to_int test
    x = 0.0
    y = to_int(x)
    @assert y == 0

    x = 1.0
    y = to_int(x)
    @assert y == 255

    println("to_int test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    importall Utility
    test_utility()
end
