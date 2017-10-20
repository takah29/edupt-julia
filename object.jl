# -*- coding: utf-8 -*-
include("structure.jl")

module Object

importall Structure

export Camera, Material, Hitpoint, Intersection, Sphere
export intersect, intersect_opt
export DIFFUSE, SPECULAR, REFRACTION
export EPS, IOR

const EPS = 1e-6
const IOR = 1.5

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

@enum REFLECTION_TYPE DIFFUSE=1 SPECULAR=2 REFRACTION=3

struct Material
    color::Color
    emission::Color
    ref_type::REFLECTION_TYPE
    ior::Float64

    function Material(color, emission=Color([0, 0, 0]), ref_type=DIFFUSE, ior=1.0)
        new(color, emission, ref_type, ior)
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

    if (t1 < EPS && t2 < EPS)
        return Hitpoint()
    end

    if t1 > EPS
        pos = ray.org + t1 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t1, pos, normal)
    else
        pos = ray.org + t2 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t2, pos, normal)
    end
end

function intersect_opt(sphere::Sphere, ray::Ray)::Hitpoint
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

    if t1 > EPS
        pos = ray.org + t1 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t1, pos, normal)
    elseif t2 > EPS
        pos = ray.org + t2 * ray.dir
        normal = normalize(pos - sphere.center)
        return Hitpoint(t2, pos, normal)
    else
        return Hitpoint()
    end
end

end


function test_object()
    obj = Object

    # Mateiral test
    material = obj.Material(obj.Color([0.5, 0.5, 0.5]), obj.Color([0, 0, 0]), obj.DIFFUSE, 1.0)
    @assert material.color == obj.Color([0.5, 0.5 ,0.5])
    @assert material.emission == obj.Color([0, 0, 0])
    @assert material.ref_type == obj.DIFFUSE
    @assert material.ior == 1.0

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
