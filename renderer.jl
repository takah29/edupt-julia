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

const BACKGROUND_COLOR = Color(0., 0., 0.)
const DEPTH_LOWER = 5
const DEPTH_LIMIT = 64

struct Params
    x_res::Int
    y_res::Int
    spp::Int
    n_super_samples::Int

    Params(x_res, y_res, spp, n_super_samples) = new(x_res, y_res, spp, n_super_samples)
end

function calc_orthonormal_basis(vec::Vec)
    if Base.abs(vec.x) > EPS
        u = normalize(cross(Vec(0., 1., 0.), vec))
    else
        u = normalize(cross(Vec(1., 0., 0.), vec))
    end
    
    v = cross(vec, u)
    return u, v
end

function f(orienting_normal::Vec, ray_dir::Vec, into::Bool)
    nc = 1.0
    nt = IOR
    nnt = ifelse(into, nc / nt, nt / nc)
    ddn = dot(ray_dir, orienting_normal)
    return 1.0 - nnt^2. * (1.0 - ddn^2.), nnt, ddn
end

function g(orienting_normal::Vec, dir::Vec, into::Bool, ddn::Float64)
    nc = 1.0
    nt = IOR
    a = nt - nc
    b = nt + nc
    R0 = a^2. / b^2.
    c = 1.0 - ifelse(into, -ddn, dot(-orienting_normal, dir))
    Re = R0 + (1.0 - R0) * c^5.
    nnt2 = ifelse(into, nc / nt, nt / nc)^2.
    Tr = (1.0 - Re) * nnt2
    return Re, Tr
end

function radiance(scene_data::SceneData, ray::Ray, depth_count::Int)::Color
    is = intersect(scene_data, ray)

    if is.object_id == -1
        return BACKGROUND_COLOR
    end

    hit_object = scene_data.objects[is.object_id]

    russian_roulette_probability = max(hit_object.material.color)

    if depth_count > DEPTH_LIMIT
        russian_roulette_probability *= 0.5^(depth_count - DEPTH_LIMIT)
    end

    if depth_count > DEPTH_LOWER
        if rand() >= russian_roulette_probability
            return hit_object.material.emission
        end
    else
        russian_roulette_probability = 1.0
    end

    hitpoint = is.hitpoint
    orienting_normal = ifelse(dot(hitpoint.normal, ray.dir) < 0.0, hitpoint.normal, -hitpoint.normal)

    if hit_object.material.ref_type == DIFFUSE
        w = orienting_normal
        u, v = calc_orthonormal_basis(w)

        r1 = 2pi * rand()
        r2 = rand()
        r2s = sqrt(r2)

        dir = normalize(u * cos(r1) * r2s + v * sin(r1) * r2s + w * sqrt(1.0 - r2))

        incoming_radiance = radiance(scene_data, Ray(hitpoint.pos, dir), depth_count + 1)
        weight = hit_object.material.color / russian_roulette_probability

    elseif hit_object.material.ref_type == SPECULAR
        dir = ray.dir - 2.0 * dot(hitpoint.normal, ray.dir) * hitpoint.normal
        incoming_radiance = radiance(scene_data, Ray(hitpoint.pos, dir), depth_count + 1)
        weight = hit_object.material.color / russian_roulette_probability

    elseif hit_object.material.ref_type == REFRACTION
        reflection_ray = Ray(hitpoint.pos, ray.dir - 2. * dot(hitpoint.normal, ray.dir) * hitpoint.normal)
        into = dot(hitpoint.normal, orienting_normal)  > 0.0

        cos2t, nnt, ddn = f(orienting_normal, ray.dir, into)

        if cos2t < 0.0
            incoming_radiance = radiance(scene_data, reflection_ray, depth_count + 1)
            weight = hit_object.material.color / russian_roulette_probability
        else
            dir = normalize(ray.dir * nnt - hitpoint.normal * (into ? 1.0 : -1.0) * (ddn * nnt + sqrt(cos2t)))
            refraction_ray = Ray(hitpoint.pos, dir)

            Re, Tr = g(orienting_normal, dir, into, ddn)

            probability = 0.25 + 0.5 * Re
            if depth_count > 2
                if rand()  < probability
                    incoming_radiance = radiance(scene_data, reflection_ray, depth_count + 1) * Re
                    weight = hit_object.material.color / (probability * russian_roulette_probability)
                else
                    incoming_radiance = radiance(scene_data, reflection_ray, depth_count + 1) * Tr
                    weight = hit_object.material.color / ((1.0 - probability) * russian_roulette_probability)
                end
            else
                incoming_radiance = radiance(scene_data, reflection_ray, depth_count + 1) * Re +
                    radiance(scene_data, refraction_ray, depth_count + 1) * Tr
                weight = hit_object.material.color / russian_roulette_probability
            end
        end
    end

    return hit_object.material.emission + weight * incoming_radiance
end

function render(scene_data::SceneData, camera::Camera, params::Params)
    img_array = zeros(Float64, (params.y_res, params.x_res, 3))
    depth_count = 0
    const rate = 1. / params.n_super_samples

    for n_iter in 1:params.spp
        for x in 0:params.x_res - 1
            println("v-line $(x + 1) of iteration $n_iter")
            for y in 0:params.y_res - 1
                for dx in 0:params.n_super_samples - 1
                    for dy in 0:params.n_super_samples - 1
                        r1 = dx * rate + rate / 2.
                        r2 = dy * rate + rate / 2.

                        screen_target = camera.screen_center +
                            ((x + r1) / params.x_res - 1. / 2.) * camera.screen_x +
                            ((y + r2) / params.y_res - 1. / 2.) * camera.screen_y

                        ray = Ray(camera.pos, normalize(screen_target - camera.pos))
                        v = radiance(scene_data, ray, 0) / params.n_super_samples^2.
                        img_array[y+1, x+1, 1] += v.x
                        img_array[y+1, x+1, 2] += v.y
                        img_array[y+1, x+1, 3] += v.z
                    end
                end
            end
        end
        if true
            save_ppm_file("result_$n_iter.ppm", to_int.(clamp.(img_array / n_iter)))
        end

    end
end

end


function test_renderer()
    rd = Renderer

    # radiance test
    objects = rd.Sphere[]
    scene_data = rd.SceneData(objects)

    push!(scene_data.objects, rd.Sphere(20, rd.Point(0., 0., 100.),
                                        rd.Material(rd.Color(0.25, 0.25, 1.), rd.Color(0. ,0. ,0.), rd.DIFFUSE, 1.)))
    ray = rd.Ray(rd.Point(0., 0., 0.), rd.Vec(0., 0., 1.))
    c = rd.radiance(scene_data, ray, 0)
    @assert typeof(c) == rd.Color
    println("radiance test: OK")

    # render test
    push!(scene_data.objects,
          rd.Sphere(10., rd.Point(20., 20., 60.),
                    rd.Material(rd.Color(0., 0., 0.), rd.Color(3. ,3. ,3.), rd.DIFFUSE, 1.)))
    camera = rd.Camera(rd.Point(0., 0., 0.), rd.Vec(0., 0., 1.))
    params = rd.Params(320, 240, 1, 1)
    rd.render(scene_data, camera, params)
    println("render test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_renderer()
end
