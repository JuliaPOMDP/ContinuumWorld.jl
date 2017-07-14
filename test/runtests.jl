using ContinuumWorld
using POMDPs
using Base.Test

w = CWorld()

write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test.png"))
@time write_file(CWorldVis(w, f=norm), joinpath(tempdir(), "test_timed.png"))

sol = CWorldSolver(max_iters=3)
solve(sol, w)
