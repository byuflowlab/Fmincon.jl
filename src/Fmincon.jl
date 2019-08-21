module Fmincon

using MATLAB

function fmincon(fundef::String, fun::String, x0::AbstractArray{<:Real,1},
    lb::AbstractArray{<:Real,1}, ub::AbstractArray{<:Real,1};
    options::AbstractDict=Dict(),
    A::AbstractArray{<:Real,2}=zeros(0,0), b::AbstractArray{<:Real,1}=zeros(0),
    Aeq::AbstractArray{<:Real,2}=zeros(0,0), beq::AbstractArray{<:Real,1}=zeros(0),
    gradients::Bool=false, printfile::String="")

    # get the default matlab session
    msession = MATLAB.get_default_msession()

    # add matlab optimization function to the MATLAB path
    moptimpath = dirname(pathof(Fmincon))
    eval_string(msession, "addpath('$moptimpath');")

    # make sure inputs are compatible with MATLAB
    x0_m = Float64.(x0)
    A_m = Float64.(A)
    b_m = Float64.(b)
    Aeq_m = Float64.(Aeq)
    beq_m = Float64.(beq)
    lb_m = Float64.(lb)
    ub_m = Float64.(ub)
    options_m = Dict{String, Any}()
    for key in keys(options)
        if isa(options[key], Number)
            options_m[key] = Float64.(options[key])
        else
            options_m[key] = options[key]
        end
    end
    gradients_m = Bool(gradients)

    # # copy input variables to MATLAB session
    put_variable(msession, :x0, x0_m)
    put_variable(msession, :A, A_m)
    put_variable(msession, :b, b_m)
    put_variable(msession, :Aeq, Aeq_m)
    put_variable(msession, :beq, beq_m)
    put_variable(msession, :lb, lb_m)
    put_variable(msession, :ub, ub_m)
    put_variable(msession, :options, options_m)
    put_variable(msession, :gradients, gradients_m)

    # load objective/constraint function into embedded Julia
    if isfile(fundef)
        eval_string(msession, "jl.include('$fundef');")
    else
        eval_string(msession, "jl.eval('$fundef');")
    end

    nargout = gradients ? 6 : 3

    # make user function MEX-like
    mexusrfun =
        """
        jl.eval(...
            ['function mexusrfun(prhs)' newline...
             '    args = vec(jarray(prhs[1]))' newline...
             '    outs = $fun(args)' newline...
             '    return [Float64.(outs[i]) for i=1:$nargout]' newline...
             'end']);
        """
    eval_string(msession, mexusrfun)

    # create a function handle for the user function
    eval_string(msession, "mexusrfun = jl.wrapmex('mexusrfun', $nargout);")

    # clear outputs
    eval_string(msession, "clear xopt, fopt, exitflag, output")

    # perform optimization
    eval_string(msession, "[xopt, fopt, exitflag, output] = optimize(mexusrfun, x0, A, b, Aeq, beq, lb, ub, options, gradients, '$printfile');")

    # check if optimization was performed succesfully
    eval_string(msession, "fail = exist(xopt) == 0;")
    fail = jvalue(get_mvariable(msession, :fail))

    # throw error if it didn't, and redirect user to other error messages
    if fail
        error("An error occured during call to fmincon, see error messages from MATLAB and embedded Julia")
    end

    # copy output variables from MATLAB session
    xopt = vec(jarray(get_mvariable(msession, :xopt)))
    fopt = jvalue(get_mvariable(msession, :fopt))
    exitflag = jvalue(get_mvariable(msession, :exitflag))
    output = jvalue(get_mvariable(msession, :output))

    return xopt, fopt, exitflag, output

end

end
