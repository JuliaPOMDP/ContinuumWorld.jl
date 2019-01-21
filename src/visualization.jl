mutable struct CWorldVis
    w::CWorld
    s::Union{Vec2, Nothing}
    f::Union{Function, Nothing}
    g::Union{AbstractGrid, Nothing}
    title::Union{String, Nothing}
end

function CWorldVis(w::CWorld;
                   s=nothing,
                   f=nothing,
                   g=nothing,
                   title=nothing)
    return CWorldVis(w, s, f, g, title)
end

@recipe function f(v::CWorldVis)
    xlim --> v.w.xlim
    ylim --> v.w.ylim
    aspect_ratio --> 1
    title --> something(v.title, "Continuum World")
    if v.f !== nothing
        @series begin
            f = v.f
            width = v.w.xlim[2]-v.w.xlim[1]
            height = v.w.ylim[2]-v.w.ylim[1]
            n = 200 # number of pixels
            nx = round(Int, sqrt(n^2*width/height))
            ny = round(Int, sqrt(n^2*height/width))
            xs = range(v.w.xlim[1], stop=v.w.xlim[2], length=nx)
            ys = range(v.w.ylim[1], stop=v.w.ylim[2], length=ny)
            zg = Array{Float64}(undef, nx, ny)
            for i in 1:nx
                for j in 1:ny
                    zg[j,i] = f(Vec2(xs[i], ys[j]))
                end
            end
            color --> cgrad([:red, :white, :green])
            seriestype := :heatmap
            xs, ys, zg
        end
    end
    if v.g !== nothing
        @series begin
            g = v.g
            xs = collect(ind2x(g, i)[1] for i in 1:length(g))
            ys = collect(ind2x(g, i)[2] for i in 1:length(g))
            label --> "Grid"
            marker --> :+
            markercolor --> :blue
            seriestype := :scatter
            xs, ys
        end
    end
end

Base.show(io::IO, m::MIME, v::CWorldVis) = show(io, m, plot(v)) 
Base.show(io::IO, m::MIME"text/plain", v::CWorldVis) = println(io, v)
