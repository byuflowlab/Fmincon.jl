using Fmincon

# --- function to optimize ----
file = "barnes.jl"
func = "barnes"
gradients = true

# -------- starting point and bounds --------------
x0 = [10.0, 10.0]
ub = [65.0, 70.0]
lb = [0.0, 0.0]

# ---- set options ----
options = Dict(
    "Algorithm" => "active-set",
    "AlwaysHonorConstraints" => "bounds",
    "display" => "iter-detailed",
    "MaxIter" => 1000,
    "MaxFunEvals" => 10000,
    "TolCon" => 1e-6,
    "TolFun" => 1e-6,
    "Diagnostics" => "on")

printfile = "fmincon_summary.out"

# --- run optimization ----
xopt, fopt, exitflag, output = Fmincon.fmincon(file, func, x0, lb, ub,
    options=options, gradients=gradients, printfile=printfile)

# --- print results
@show xopt
@show fopt
@show exitflag
@show output
