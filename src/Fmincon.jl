module Fmincon

using MATLAB

function fmincon(file::String, usrfun::String, x0::AbstractArray{<:Real,1},
    lb::AbstractArray{<:Real,1}, ub::AbstractArray{<:Real,1};
    options::AbstractDict=Dict(),
    A::AbstractArray{<:Real,2}=zeros(0,0), b::AbstractArray{<:Real,1}=zeros(0),
    Aeq::AbstractArray{<:Real,2}=zeros(0,0), beq::AbstractArray{<:Real,1}=zeros(0),
    gradients::Bool=false, printfile::String="")

    # start a MATLAB session
    msession = MSession()

    # add matlab optimization function to the MATLAB path
    moptimpath = dirname(pathof(Fmincon))
    eval_string(msession, "addpath('$moptimpath');")

    # # copy input variables to MATLAB session
    put_variable(msession, :x0, x0)
    put_variable(msession, :A, A)
    put_variable(msession, :b, b)
    put_variable(msession, :Aeq, Aeq)
    put_variable(msession, :beq, beq)
    put_variable(msession, :lb, lb)
    put_variable(msession, :ub, ub)
    put_variable(msession, :options, options)
    put_variable(msession, :gradients, gradients)

    # load embedded julia session and this package
    eval_string(msession, "jl.eval('using MATLAB');")

    # load objective/constraint function into embedded Julia
    eval_string(msession, "jl.include('$file');")

    # make user function MEX-like
    mexusrfun =
        """
        jl.eval(...
            ['function mexusrfun(prhs)' newline...
             '    args = jvalue(prhs[1])' newline...
             '    outs = $usrfun(args)' newline...
             '    return [Float64.(out) for out in outs]' newline...
             'end']);
        """
    eval_string(msession, mexusrfun)

    # create a function handle for the user function
    nargout = gradients ? 6 : 3
    eval_string(msession, "mexusrfun = jl.wrapmex('mexusrfun', $nargout);")

    # perform optimization
    eval_string(msession, "[xopt, fopt, exitflag, output] = optimize(mexusrfun, x0, A, b, Aeq, beq, lb, ub, options, gradients, '$printfile');")

    # copy output variables from MATLAB session
    xopt = jvalue(get_mvariable(msession, :xopt))
    fopt = jvalue(get_mvariable(msession, :fopt))
    exitflag = jvalue(get_mvariable(msession, :exitflag))
    output = jvalue(get_mvariable(msession, :output))

    # close MATLAB session
    close(msession)

    return xopt, fopt, exitflag, output

end

end
