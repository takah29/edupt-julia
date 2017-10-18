# -*- coding: utf-8 -*-
include("object.jl")

module Scene

importall Structure
importall Object

export SceneData
export intersect_scene

mutable struct SceneData
    objects::Vector{Sphere}
    SceneData(object=Vector{Sphere}[]) = new(object)
end

function intersect_scene(scene_data::SceneData, ray::Ray)
    is = Intersection()

    for (id, obj) in enumerate(scene_data.objects)
        hp = intersect(obj, ray)
        if hp.distance < is.hitpoint.distance
            is.hitpoint = hp
            is.object_id = id
        end

    end

    return is
end

end


function test_scene()
    sn = Scene

    # SceneData test
    objects = sn.Sphere[]

    scene_data = sn.SceneData(objects)
    @assert length(scene_data.objects) == 0

    push!(scene_data.objects, sn.Sphere(0.5, sn.Point([1, 0, 0]), sn.Material(sn.Color([0.5, 0.5, 0.5]))))
    @assert length(scene_data.objects) == 1

    println("SceneData test: OK")

    # intersect_scene test
    ray = sn.Ray(sn.Point([0, 0, 0]), sn.Vec([1, 0, 0]))
    intersection = sn.intersect_scene(scene_data, ray)
    @assert intersection.object_id == 1

    push!(scene_data.objects, sn.Sphere(0.5, sn.Point([2, 0, 0]), sn.Material(sn.Color([0.5, 0.5, 0.5]))))
    intersection = sn.intersect_scene(scene_data, ray)
    @assert intersection.object_id == 1

    push!(scene_data.objects, sn.Sphere(0.5, sn.Point([0.6, 0, 0]), sn.Material(sn.Color([0.5, 0.5, 0.5]))))
    intersectoion = sn.intersect_scene(scene_data, ray)
    @assert intersection.object_id == 3

    println("intersect_scene test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_scene()
end
