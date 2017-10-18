# -*- coding: utf-8 -*-

module Structure

export Vec, Point, Color, Ray

Vec = Vector{Float64}
Point = Vec
Color = Vec

struct Ray
    org::Point
    dir::Vec
    function Ray(org, dir)
        dir = normalize(dir)
        new(org, dir)
    end
end

end

function test_structure()
    st = Structure
    # Ray test
    r = st.Ray(st.Point([1,1,1]), st.Vec([2,2,2]))
    @assert r.org == Vector{Float64}([1.0, 1.0, 1.0])

    v = Vector{Float64}([2.0, 2.0, 2.0])
    dir = v / norm(v)
    @assert r.dir == dir

    println("Ray test: OK")
end

if PROGRAM_FILE == basename(@__FILE__)
    test_structure()
end
