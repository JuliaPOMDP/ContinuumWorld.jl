using Test
using ContinuumWorld
using POMDPs
using POMDPTools
using Random
using StaticArrays
using Plots

@testset "ContinuumWorld Tests" begin
    w = CWorld()

    s = Vec2(3.0, 2.0)
    a = Vec2(4.0, 2.0)
    rng = MersenneTwister(19)
    d = transition(w, s, a)
    sp = rand(rng, d)
    r = reward(w, s, a, sp)

    @test sp isa Vec2
    @test r isa Float64

    sol = CWorldSolver(rng = MersenneTwister(7))
    pol = solve(sol, w)
    @test typeof(pol) <: Policy

    sim = HistoryRecorder(rng = MersenneTwister(1), max_steps = 30)
    hist = simulate(sim, w, pol)
    @test length(state_hist(hist)) > 0

    plt = plot(CWorldVis(w, f = s -> value(pol, s), g = sol.grid, title = "Value"))
    @test plt isa Plots.Plot
end
