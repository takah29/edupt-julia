# -*- coding: utf-8 -*-
include("structure.jl")

module Object

importall Structure

export Camera, Material, Hitpoint, Intersection, Sphere
export intersect

const kEPS = 1e-6

struct Camera
    pos::Point
    dir::Vec
    up::Vec

    screen_dist::Float64
    screen_width::Float64
    screen_height::Float64
    screen_center::Point
    screen_x::Vec
    screen_y::Vec

    function Camera(pos, dir, up=Vec([0, 1, 0]), screen_dist=40.0, screen_width=40.0, screen_height=30.0)
        dir = normalize(dir)
        up = normalize(up)
        screen_center = pos + screen_dist * dir
        screen_x = normalize(cross(dir, up)) * screen_width
        screen_y = - normalize(cross(screen_x, dir)) * screen_height
        new(pos, dir, up, screen_dist, screen_width, screen_height, screen_center, screen_x, screen_y)
    end
end

struct Material
    diffuse::Color
    emission::Color
    specular::Float64
    transparency::Float64
    kIor::Float64

    function Material(diffuse, emission=Color([0, 0, 0]), specular=0.0, transparency=0.0, kIor=1.0)
        new(diffuse, emission, specular, transparency, kIor)
    end
end

mutable struct Hitpoint
    distance::Float64
    pos::Point
    normal::Vec

    function Hitpoint(distance=Inf, pos=Point([0, 0, 0]), normal=Vec([1, 0, 0]))
        normal = normalize(normal)
        new(distance, pos, normal)
    end
end

mutable struct Intersection
    hitpoint::Hitpoint
    object_id::Int

    function Intersection(hitpoint=Hitpoint(), object_id=-1)
        new(hitpoint, object_id)
    end
end

struct Sphere
    radius::Float64
    center::Point
    material::Material
    Sphere(radius, center, material) = new(radius, center, material)
end

function intersect(sphere::Sphere, ray::Ray)::Hitpoint
    center_minus_rayorg = sphere.center - ray.org
    b = ray.dir'center_minus_rayorg
    c = center_minus_rayorg'center_minus_rayorg - sphere.radius^2
    D4 = b^2 - c

    if D4 < 0
        return Hitpoint()
    end

    sqrt_D4 = sqrt(D4)
    t1 = b - sqrt_D4
    t2 = b + sqrt_D4

    if (t1 < kEPS && t2 < kEPS)
        return Hitpoint()
    end

    if t1 > kEPS
        pos = ray.org + t1 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t1, pos, normal)
    else
        pos = ray.org + t2 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t2, pos, normal)
    end
end

end


function test_object()
    obj = Object

    # Mateiral test
    material = obj.Material(obj.Color([0.5, 0.5, 0.5]), obj.Color([0, 0, 0]), 1.0, 2.0, 1.0)
    @assert material.diffuse == obj.Color([0.5, 0.5 ,0.5])
    @assert material.emission == obj.Color([0, 0, 0])
    @assert material.specular == 1.0
    @assert material.transparency == 2.0
    @assert material.kIor == 1.0

    println("Material test: OK")

    # Sphere test
    sphere = obj.Sphere(1, obj.Point([0, 0, 0]), obj.Material(obj.Color([0.5, 0.5, 0.5])))
    @assert sphere.radius == 1.0
    @assert sphere.center == obj.Point([0, 0, 0])

    println("Sphere test: OK")

    # Hitpoint test
    hitpoint = obj.Hitpoint()
    @assert hitpoint.distance == Inf
    @assert hitpoint.pos == obj.Point([0, 0, 0])
    @assert hitpoint.normal == obj.Vec([1, 0, 0])

    println("Hitpoint test: OK")

    # Intersection test
    intersection = obj.Intersection()
    @assert intersection.object_id == -1

    println("Intersection test: OK")

    # intersect test
    sphere = obj.Sphere(0.5, obj.Point([1, 0, 0]), obj.Material(obj.Color([0.5, 0.5, 0.5])))
    ray1 = obj.Ray(obj.Point([0, 0, 0]), obj.Vec([1, 0, 0]))
    hp1 = obj.intersect(sphere, ray1)
    @assert hp1.distance == 0.5

    ray2 = obj.Ray(obj.Point([0, 1, 0]), obj.Vec([1, 0, 0]))
    hp2 = obj.intersect(sphere, ray2)
    @assert hp2.distance == Inf

    println("intersect test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_object()
end
