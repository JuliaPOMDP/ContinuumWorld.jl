module ContinuumWorld

# package code goes here

importall POMDPs
using StaticArrays
using Parameters
using GR
using GridInterpolations
using POMDPToolbox

export
    CWorld,
    CWorldVis,
    CircularRegion,
    Vec2,
    CWorldSolver,
    
    write_file,
    evaluate,
    plot

typealias Vec2 SVector{2, Float64}

immutable CircularRegion
    center::Vec2
    radius::Float64
end

Base.in(v::Vec2, r::CircularRegion) = norm(v-r.center) <= r.radius

const card_and_stay = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0), Vec2(0.0, 0.0)]
const cardinal = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0)]
const default_regions = [CircularRegion(Vec2(3.5, 2.5), 0.5),
                         CircularRegion(Vec2(3.5, 5.5), 0.5),
                         CircularRegion(Vec2(8.5, 2.5), 0.5),
                         CircularRegion(Vec2(7.5, 7.5), 0.5)]
const default_rewards = [-10.0, -5.0, 10.0, 3.0]


@with_kw immutable CWorld <: MDP{Vec2, Vec2}
    xlim::Tuple{Float64, Float64}                   = (0.0, 10.0)
    ylim::Tuple{Float64, Float64}                   = (0.0, 10.0)
    reward_regions::Vector{CircularRegion}          = default_regions
    rewards::Vector{Float64}                        = default_rewards
    terminal::Vector{CircularRegion}                = default_regions
    stdev::Float64                                  = 0.5
    actions::Vector{Vec2}                           = cardinal
    discount::Float64                               = 0.95
end

actions(w::CWorld) = w.actions
discount(w::CWorld) = w.discount

function generate_s(w::CWorld, s::Vec2, a::Vec2, rng::AbstractRNG)
    return s + a + w.stdev*randn(rng, Vec2)
end

function reward(w::CWorld, s, a, sp) # XXX inefficient
    rew = 0.0
    for (i,r) in enumerate(w.reward_regions)
        if sp in r
            rew += w.rewards[i]
        end
    end
    return rew
end

function isterminal(w::CWorld, s) # XXX inefficient
    for r in w.terminal
        if s in r
            return true
        end
    end
    return false
end


include("solver.jl")
include("visualization.jl")

end # module
