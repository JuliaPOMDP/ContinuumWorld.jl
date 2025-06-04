module ContinuumWorld

using Random
using LinearAlgebra
using POMDPs
using StaticArrays
using Parameters
using GridInterpolations
using POMDPModels
using POMDPTools
using Distributions
using Statistics
using StatsBase
using Plots
using Plotly

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

Base.in(v::Vec2, r::CircularRegion) = norm(v - r.center) <= r.radius

const card_and_stay = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0), Vec2(0.0, 0.0)]
const cardinal = [Vec2(1.0, 0.0), Vec2(-1.0, 0.0), Vec2(0.0, 1.0), Vec2(0.0, -1.0)]

const default_regions = [
    CircularRegion(Vec2(3.5, 2.5), 0.5),
    CircularRegion(Vec2(3.5, 5.5), 0.5),
    CircularRegion(Vec2(8.5, 2.5), 0.5),
    CircularRegion(Vec2(7.5, 7.5), 0.5),
]

const default_rewards = [-10.0, -5.0, 10.0, 3.0]

@with_kw struct CWorld <: MDP{Vec2, Vec2}
    xlim::Tuple{Float64, Float64} = (0.0, 10.0)
    ylim::Tuple{Float64, Float64} = (0.0, 10.0)
    reward_regions::Vector{CircularRegion} = default_regions
    rewards::Vector{Float64} = default_rewards
    terminal::Vector{CircularRegion} = default_regions
    stdev::Float64 = 0.5
    actions::Vector{Vec2} = cardinal
    discount::Float64 = 0.95
end

POMDPs.actions(w::CWorld) = w.actions
POMDPs.discount(w::CWorld) = w.discount

function POMDPs.transition(w::CWorld, s::AbstractVector, a::AbstractVector)
    ImplicitDistribution(w, s, a) do w, s, a, rng
        s + a + w.stdev * randn(rng, Vec2)
    end
end

function POMDPs.transition(w::CWorld, s::AbstractVector, a::AbstractVector, rng::AbstractRNG)
    ImplicitDistribution(w, s, a) do w, s, a, rng
        s + a + w.stdev * randn(rng, Vec2)
    end
end

function POMDPs.reward(w::CWorld, s::AbstractVector, a::AbstractVector, sp::AbstractVector)
    rew = 0.0
    for (i, r) in enumerate(w.reward_regions)
        if sp in r
            rew += w.rewards[i]
        end
    end
    return rew
end

function POMDPs.isterminal(w::CWorld, s::Vec2)
    any(r -> s in r, w.terminal)
end

struct Vec2Distribution
    xlim::Tuple{Float64, Float64}
    ylim::Tuple{Float64, Float64}
    d::Product
    function Vec2Distribution(xlim, ylim)
        d = Product([Distributions.Uniform(xlim[1], xlim[2]), Distributions.Uniform(ylim[1], ylim[2])])
        new(xlim, ylim, d)
    end
end

function Base.rand(rng::AbstractRNG, v::Vec2Distribution)
    x = v.xlim[1] + (v.xlim[2] - v.xlim[1]) * rand(rng)
    y = v.ylim[1] + (v.ylim[2] - v.ylim[1]) * rand(rng)
    return Vec2(x, y)
end

Distributions.pdf(v::Vec2Distribution, x) = pdf(v.d, x)
Distributions.support(v::Vec2Distribution) = support(v.d)
StatsBase.mode(v::Vec2Distribution) = mode(v.d)
Statistics.mean(v::Vec2Distribution) = mean(v.d)

function POMDPs.initialstate(w::CWorld)
    Vec2Distribution(w.xlim, w.ylim)
end

include("solver.jl")
include("visualization.jl")

end # module
