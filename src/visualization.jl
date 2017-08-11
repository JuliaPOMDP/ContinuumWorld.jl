
type CWorldVis
    w::CWorld
    s::Nullable{Vec2}
    f::Nullable{Function}
    g::Nullable{AbstractGrid}
end

function CWorldVis(w::CWorld;
                   s=Nullable{Vec2}(),
                   f=Nullable{Function},
                   g=Nullable{AbstractGrid}
                  )
    return CWorldVis(w, s, f, g)
end

#=
function plot(v::CWorldVis)
    inline()
    clearws()
    setwindow(v.w.xlim..., v.w.ylim...)
    axes(1, 1, 0, 0, 2, 2, 0.01)
    setspace(0.0, 10.0, 0, 90)
    if !isnull(v.f)
        f = get(v.f)
        width = v.w.xlim[2]-v.w.xlim[1]
        height = v.w.ylim[2]-v.w.ylim[1]
        n = 200 # number of pixels
        nx = round(Int, sqrt(n^2*width/height))
        ny = round(Int, sqrt(n^2*height/width))
        xs = linspace(v.w.xlim..., nx)
        ys = linspace(v.w.ylim..., ny)
        xg, yg = meshgrid(xs, ys)
        zg = Array{Float64}(length(xg))
        for i in 1:length(xg)
            zg[i] = f(Vec2(xg[i], yg[i]))
        end
        p = surface(xs, ys, zg, 5)
    end
    return p
end
=#

function write_file(v::CWorldVis, fname::String)
    inline()
    beginprint(fname)
    setcolormap(2)
    clearws()
    setwindow(v.w.xlim..., v.w.ylim...)
    axes(1, 1, 0, 0, 2, 2, 0.01)
    setspace(-10.0, 10.0, 0, 90)
    if !isnull(v.f)
        f = get(v.f)
        width = v.w.xlim[2]-v.w.xlim[1]
        height = v.w.ylim[2]-v.w.ylim[1]
        n = 200 # number of pixels
        nx = round(Int, sqrt(n^2*width/height))
        ny = round(Int, sqrt(n^2*height/width))
        xs = linspace(v.w.xlim..., nx)
        ys = linspace(v.w.ylim..., ny)
        xg, yg = meshgrid(xs, ys)
        zg = Array{Float64}(length(xg))
        for i in 1:length(xg)
            zg[i] = f(Vec2(xg[i], yg[i]))
        end
        p = surface(xs, ys, zg, 5)
    end
    if !isnull(v.g)
        g = get(v.g)
    end
    endprint()
end

Base.show(io::IO, m::MIME"image/tif", v::CWorldVis) = show(io, "tif", v)
# Base.show(io::IO, MIME"image/png", v::CWorldVis) = show(io, "png", v)

function Base.show(io::IO, imagetype::String, v::CWorldVis)
    tmppng = tempname()*imagetype
    write_file(v, tmppng)

    open(tmppng) do f
        write(io, read(f))
    end
    # run(`rm $tmpeps`)
    run(`rm $tmppng`)
    return io
end
