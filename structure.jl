# -*- coding: utf-8 -*-

module Structure

export Vec, Point, Color, Ray
export sum, dot, norm, normalize, cross, max, abs, approx

struct Vec
    x::Float64
    y::Float64
    z::Float64

    Vec(x::Float64, y::Float64, z::Float64) = new(x, y, z)
end

Base.:+(a::Vec, b::Vec) = Vec(a.x + b.x, a.y + b.y, a.z + b.z)
Base.:+(a::Float64, b::Vec) = Vec(a + b.x, a + b.y, a + b.z)
Base.:+(a::Vec, b::Float64) = Vec(a.x + b, a.y + b, a.z + b)
Base.:-(a::Vec) = Vec(-a.x, -a.y, -a.z)
Base.:-(a::Vec, b::Vec) = Vec(a.x - b.x, a.y - b.y, a.z - b.z)
Base.:-(a::Vec, b::Float64) = Vec(a.x - b, a.y - b, a.z - b)
Base.:*(a::Vec, b::Vec) = Vec(a.x * b.x, a.y * b.y, a.z * b.z)
Base.:*(a::Float64, b::Vec) = Vec(a * b.x, a * b.y, a * b.z)
Base.:*(a::Vec, b::Float64) = Vec(a.x * b, a.y * b, a.z * b)
Base.:/(a::Vec, b::Vec) = Vec(a.x / b.x, a.y / b.y, a.z / b.z)
Base.:/(a::Vec, b::Float64) = Vec(a.x / b, a.y / b, a.z / b)
Base.:/(a::Vec, b::Int) = Vec(a.x / b, a.y / b, a.z / b)

sum(a::Vec) = a.x + a.y + a.z
dot(a::Vec, b::Vec) = a.x * b.x + a.y * b.y + a.z * b.z
norm(a::Vec) = dot(a, a) |> sqrt
normalize(a::Vec) = a / norm(a)
cross(a::Vec, b::Vec) = Vec(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
max(a::Vec) = Base.max(a.x, a.y, a.z)
abs(a::Vec) = Vec(Base.abs(a.x), Base.abs(a.y), Base.abs(a.z))
isapprox(a::Vec, b::Vec) = sum(abs(a - b)) < 1e-8

Point = Vec
Color = Vec

struct Ray
    org::Point
    dir::Vec
    function Ray(org::Point, dir::Vec)
        dir = normalize(dir)
        new(org, dir)
    end
end

end

function test_structure()
    st = Structure
    # Vec test
    a = st.Vec(1., 2., 3.)
    b = st.Vec(4., 5., 6.)
    @assert st.isapprox(a + b, st.Vec(5., 7. ,9.))
    k = 2.0
    @assert st.isapprox(k + a, st.Vec(3., 4., 5.))
    @assert st.isapprox(a + k, st.Vec(3., 4., 5.))
    @assert st.isapprox(-a, st.Vec(-1., -2., -3.))
    @assert st.isapprox(a - b, st.Vec(-3., -3., -3.))
    @assert st.isapprox(a - k, st.Vec(-1., 0., 1.))
    @assert st.isapprox(a * b, st.Vec(4., 10. ,18.))
    @assert st.isapprox(k * a, st.Vec(2., 4., 6.))
    @assert st.isapprox(a * k, st.Vec(2., 4., 6.))
    @assert st.isapprox(a / b, st.Vec(1./4., 2./5., 3./6.))
    @assert st.isapprox(a / k, st.Vec(1./2., 2./2., 3./2.))
    a = st.Vec(1., 0., 0.)
    b = st.Vec(0., 1., 0.)
    @assert st.isapprox(st.cross(a, b), st.Vec(0., 0., 1.,))
    @assert isapprox(st.max(b), 1.)
    println("Vec test: OK")

    # Ray test
    r = st.Ray(st.Point(1.,1.,1.), st.Vec(2., 2., 2.))
    @assert st.isapprox(r.org, st.Vec(1.0, 1.0, 1.0))

    v = st.Vec(2., 2., 2.)
    dir = v / st.norm(v)
    @assert st.isapprox(r.dir, dir)

    println("Ray test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_structure()
end
