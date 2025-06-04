using Test
using ContinuumWorld
using POMDPs
using POMDPTools
using Random
using Plots
using Plotly

@testset "ContinuumWorld Tests" begin
    # Create a basic CWorld environment
    w = CWorld()

    # Test generative model sampling
    sp, r = @inferred @gen(:sp, :r)(w, [3.0, 2.0], [4.0, 2.0], MersenneTwister(19))
    @test isa(sp, SVector{2, Float64})
    @test isa(r, Float64)

    # Create and solve with custom solver
    sol = CWorldSolver(rng=MersenneTwister(7))
    pol = solve(sol, w)
    @test isa(pol, CWorldPolicy)

    # Run simulation
    sim = HistoryRecorder(rng=MersenneTwister(5), max_steps=30)
    hist = simulate(sim, w, pol)
    @test length(state_hist(hist)) > 0
    @info "Simulation states:" state_hist(hist)

    # Visualization of value function
    plt = Plots.plot(CWorldVis(w, f=s -> value(pol, s), g=sol.grid, title="Value"))
    @test isa(plt, Plots.Plot)

    # Optional: Save visualizations (commented out for CI use)
    # savefig(plt, joinpath(tempdir(), "value_plot.png"))
end
