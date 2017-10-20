# -*- coding: utf-8 -*-
include("renderer.jl")
importall Structure
importall Object
importall Scene
importall Renderer

function set_scene1!(scene_data::SceneData)
    push!(scene_data.objects, Sphere(1e5, Point([1e5+1, 40.8, 81.6]),
                                     Material(Color([0.75, 0.25, 0.25]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(1e5, Point([-1e5+99, 40.8, 81.6]),
                                     Material(Color([0.25, 0.25, 0.75]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(1e5, Point([50, 40.8, 1e5]),
                                     Material(Color([0.75, 0.75, 0.75]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(1e5, Point([50, 40.8, -1e5+250]),
                                     Material(Color([0, 0, 0]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(1e5, Point([50, 1e5, 81.6]),
                                     Material(Color([0.75, 0.75, 0.75]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(1e5, Point([50, -1e5+81.6, 81.6]),
                                     Material(Color([0.75, 0.75, 0.75]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(20, Point([65, 20, 20]),
                                     Material(Color([0.25, 0.75, 0.25]), Color([0 ,0 ,0]), DIFFUSE, 1.)))
    push!(scene_data.objects, Sphere(16.5, Point([27, 16.5, 47]),
                                     Material(Color([0.99, 0.99, 0.99]), Color([0 ,0 ,0]), SPECULAR, 1.)))
    push!(scene_data.objects, Sphere(16.5, Point([77, 16.5, 78]),
                                     Material(Color([0.99, 0.99, 0.99]), Color([0 ,0 ,0]), REFRACTION, 1.)))
    push!(scene_data.objects, Sphere(15., Point([50, 90, 81.6]),
                                     Material(Color([0, 0, 0]), Color([36 ,36 ,36]), DIFFUSE, 1.)))

end

if PROGRAM_FILE == basename(@__FILE__)
    scene_data = SceneData()
    set_scene1!(scene_data)
    camera = Camera(Point([50, 52, 220]), Vec([0, -0.04, -1.0]))
    params = Params(320, 240, 16, 1)
    render(scene_data, camera, params)
end
