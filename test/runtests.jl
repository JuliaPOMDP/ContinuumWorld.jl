using ContinuumWorld
using POMDPs
using POMDPModelTools
using POMDPModels
using POMDPSimulators
using Test
using Plots
using Random

w = CWorld()

@inferred gen(DDNOut(:sp, :r), w, [3,2], [4,2], MersenneTwister(19))

sol = CWorldSolver(rng=MersenneTwister(7))
pol = solve(sol, w)

sim = HistoryRecorder(rng=MersenneTwister(5), max_steps=30)
@show state_hist(simulate(sim, w, pol))

#=
write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test.png"))
@time write_file(CWorldVis(w, f=norm, g=sol.grid), joinpath(tempdir(), "test_timed.png"))
@time write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test_timed.tif"))
@time write_file(CWorldVis(w, f=norm, g=sol.grid), joinpath(tempdir(), "test_timed.tif"))
@time write_file(CWorldVis(w, f=s->action_ind(pol, s), g=sol.grid, title="Policy"), joinpath(tempdir(), "policy.png"))
@time write_file(CWorldVis(w, f=s->value(pol, s), g=sol.grid, title="Value"), joinpath(tempdir(), "value.png"))
=#
plot(CWorldVis(w, f=s->value(pol, s), g=sol.grid, title="Value"))
