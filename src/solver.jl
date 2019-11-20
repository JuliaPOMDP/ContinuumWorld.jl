struct GIValue{G <: AbstractGrid}
    grid::G
    gdata::Vector{Float64}
end

evaluate(v::GIValue, s::AbstractVector{Float64}) = interpolate(v.grid, v.gdata, convert(Vector{Float64}, s))

@with_kw mutable struct CWorldSolver{G<:AbstractGrid, RNG<:AbstractRNG} <: Solver
    grid::G                     = RectangleGrid(range(0.0, stop=10.0, length=30), range(0.0, stop=10.0, length=30))
    max_iters::Int              = 50
    tol::Float64                = 0.01
    m::Int                      = 20
    value_hist::AbstractVector  = []
    rng::RNG                    = Random.GLOBAL_RNG
end

struct CWorldPolicy{V} <: Policy
    actions::Vector{Vec2}
    Qs::Vector{V}
end

function POMDPs.solve(sol::CWorldSolver, w::CWorld)
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
                for a in actions(w, s)
                    Qsum = 0.0
                    for j in 1:sol.m
                        sp, r = gen(DDNOut(:sp, :r), w, s, a, sol.rng)
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

    print("\nextracting policy...     ")

    Qs = Vector{GIValue}(undef,n_actions(w))
    acts = collect(actions(w))
    for j in 1:n_actions(w)
        a = acts[j]
        qdata = similar(val.gdata)
        for i in 1:length(sol.grid)
            s = Vec2(ind2x(sol.grid, i))
            if isterminal(w, s)
                qdata[i] = 0.0
            else
                Qsum = 0.0
                for k in 1:sol.m
                    sp, r = gen(DDNOut(:sp, :r), w, s, a, sol.rng)
                    Qsum += r + discount(w)*evaluate(val, sp)
                end
                qdata[i] = Qsum/sol.m
            end
        end
        Qs[j] = GIValue(sol.grid, qdata)
    end
    println("done.")

    return CWorldPolicy(acts, Qs)
end

function POMDPs.action(p::CWorldPolicy, s::AbstractVector{Float64})
    best = action_ind(p, s)
    return p.actions[best]
end

action_ind(p::CWorldPolicy, s::AbstractVector{Float64}) = argmax([evaluate(Q, s) for Q in p.Qs])

POMDPs.value(p::CWorldPolicy, s::AbstractVector{Float64}) = maximum([evaluate(Q, s) for Q in p.Qs])
