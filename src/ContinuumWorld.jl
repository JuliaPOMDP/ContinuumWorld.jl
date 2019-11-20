module ContinuumWorld

# package code goes here
using Random
using LinearAlgebra
using POMDPs
using StaticArrays
using Parameters
using GridInterpolations
using POMDPModelTools
using POMDPModels
using Plots
plotly()

export
    CWorld,
    CWorldVis,
    CircularRegion,
    Vec2,
    CWorldSolver,
    
    evaluate,
    action_ind

const Vec2 = SVector{2, Float64}

struct CircularRegion
    center::Vec2
    radius::Float64
end

Base.in(v::Vec2, r::CircularRegion) = LinearAlgebra.norm(v-r.center) <= r.radius

const card_and_stay = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0), Vec2(0.0, 0.0)]
const cardinal = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0)]
const default_regions = [CircularRegion(Vec2(3.5, 2.5), 0.5),
                         CircularRegion(Vec2(3.5, 5.5), 0.5),
                         CircularRegion(Vec2(8.5, 2.5), 0.5),
                         CircularRegion(Vec2(7.5, 7.5), 0.5)]
const default_rewards = [-10.0, -5.0, 10.0, 3.0]


@with_kw struct CWorld <: MDP{Vec2, Vec2}
    xlim::Tuple{Float64, Float64}                   = (0.0, 10.0)
    ylim::Tuple{Float64, Float64}                   = (0.0, 10.0)
    reward_regions::Vector{CircularRegion}          = default_regions
    rewards::Vector{Float64}                        = default_rewards
    terminal::Vector{CircularRegion}                = default_regions
    stdev::Float64                                  = 0.5
    actions::Vector{Vec2}                           = cardinal
    discount::Float64                               = 0.95
end

POMDPs.actions(w::CWorld) = w.actions
POMDPs.n_actions(w::CWorld) = length(w.actions)
POMDPs.discount(w::CWorld) = w.discount

function POMDPs.gen(::DDNNode{:sp}, w::CWorld, s::AbstractVector, a::AbstractVector, rng::AbstractRNG)
    return s + a + w.stdev*randn(rng, Vec2)
end

function POMDPs.reward(w::CWorld, s::AbstractVector, a::AbstractVector, sp::AbstractVector) # XXX inefficient
    rew = 0.0
    for (i,r) in enumerate(w.reward_regions)
        if sp in r
            rew += w.rewards[i]
        end
    end
    return rew
end

function POMDPs.isterminal(w::CWorld, s::Vec2) # XXX inefficient
    for r in w.terminal
        if s in r
            return true
        end
    end
    return false
end

function POMDPs.initialstate(w::CWorld, rng::AbstractRNG)
    x = w.xlim[1] + (w.xlim[2] - w.xlim[1]) * rand(rng)
    y = w.ylim[1] + (w.ylim[2] - w.ylim[1]) * rand(rng)
    return Vec2(x,y)
end

include("solver.jl")
include("visualization.jl")

end # module
