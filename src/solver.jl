immutable GIValue{G <: AbstractGrid}
    grid::G
    gdata::Vector{Float64}
end

evaluate(v::GIValue, s::Vec2) = interpolate(v.grid, v.gdata, convert(Vector{Float64}, s))

@with_kw type CWorldSolver{G<:AbstractGrid, RNG<:AbstractRNG}
    grid::G                     = RectangleGrid(linspace(0.0,10.0, 20), linspace(0.0, 10.0, 20))
    max_iters::Int              = 100
    tol::Float64                = 0.01
    m::Int                      = 20
    value_hist::AbstractVector  = []
    rng::RNG                    = Base.GLOBAL_RNG
end

function solve(sol::CWorldSolver, w::CWorld)
    sol.value_hist = []
    data = zeros(length(sol.grid))
    val = GIValue(sol.grid, data)

    for k in 1:sol.max_iters
        newdata = similar(data)
        for i in 1:length(sol.grid)
            s = Vec2(ind2x(sol.grid, i))
            if isterminal(w, s)
                newdata[i] = 0.0
            else
                best_Qsum = -Inf
                for a in iterator(actions(w, s))
                    Qsum = 0.0
                    for j in 1:sol.m
                        sp, r = generate_sr(w, s, a, sol.rng)
                        Qsum += r + discount(w)*evaluate(val, sp)
                    end
                    best_Qsum = max(best_Qsum, Qsum)
                end
                newdata[i] = best_Qsum/sol.m
            end
        end
        push!(sol.value_hist, val)
        print("\rfinished iteration $k")
        val = GIValue(sol.grid, newdata)
    end
    println()
end
