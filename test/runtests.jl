using ContinuumWorld
using POMDPs
using POMDPToolbox
using Base.Test

w = CWorld()

write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test.png"))
@time write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test_timed.png"))
@time write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test_timed.tif"))

sol = CWorldSolver(max_iters=3)
pol = solve(sol, w)

sim = RolloutSimulator(rng=MersenneTwister(2))
simulate(sim, w, pol)
