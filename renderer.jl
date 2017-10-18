# -*- coding: utf-8 -*-
include("scene.jl")
include("utility.jl")

module Renderer

importall Scene
importall Structure
importall Object
importall Utility

export Params
export radiance, render

const BACKGROUND_COLOR = Color([0, 0, 0])

struct Params
    x_res::Int
    y_res::Int
    spp::Int
    n_super_samples::Int

    Params(x_res, y_res, spp, n_super_samples) = new(x_res, y_res, spp, n_super_samples)
end

function radiance(scene_data::SceneData, ray::Ray)::Color
    is = intersect_scene(scene_data, ray)

    if is.hitpoint.distance != Inf
        return scene_data.objects[is.object_id].material.diffuse
    else
        return BACKGROUND_COLOR
    end
end

function render(scene_data::SceneData, camera::Camera, params::Params)
    img_array = zeros(Float64, (params.y_res, params.x_res, 3))
    const rate = 1 / params.n_super_samples

    for n_iter in 1:params.spp
        for x in 0:params.x_res - 1
            for y in 0:params.y_res - 1
                for dx in 0:params.n_super_samples - 1
                    for dy in 0:params.n_super_samples - 1
                        r1 = dx * rate + rate / 2
                        r2 = dy * rate + rate / 2

                        screen_target = camera.screen_center +
                            ((x + r1) / params.x_res - 1 / 2) * camera.screen_x +
                            ((y + r2) / params.y_res- 1 / 2) * camera.screen_y

                        ray = Ray(camera.pos, normalize(screen_target - camera.pos))
                        v = radiance(scene_data, ray) / (params.spp * params.n_super_samples^2)
                        img_array[y+1,x+1,:] += v
                    end
                end
            end
        end
        save_ppm_file("result_$n_iter.ppm", to_int.(clamp.(img_array / n_iter)))
    end
end

end


function test_renderer()
    rd = Renderer

    # radiance test
    objects = rd.Sphere[]
    scene_data = rd.SceneData(objects)

    push!(scene_data.objects, rd.Sphere(20, rd.Point([0, 0, 100]),
                                        rd.Material(rd.Color([0, 0, 1]), rd.Color([0 ,0 ,0]), 0, 0, 1.)))
    ray = rd.Ray(rd.Point([0, 0, 0]), rd.Vec([0, 0, 1]))
    @assert rd.radiance(scene_data, ray) == rd.Color([0, 0, 1])
    println("radiance test: OK")

    # render test
    camera = rd.Camera(rd.Point([0, 0, 0]), rd.Vec([0, 0, 1]))
    params = rd.Params(320, 240, 2, 2)
    rd.render(scene_data, camera, params)
    println("render test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_renderer()
end
