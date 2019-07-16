function [xopt, fopt, exitflag, output] = optimize(usrfun, x0, A, b, ...
    Aeq, beq, lb, ub, opt_struct, gradients, printfile)

% Written by Andrew Ning.  Feb 2016.
% FLOW Lab, Brigham Young University.

    % set options
    options = optimoptions('fmincon');
    names = fieldnames(opt_struct);
    for i = 1:length(names)
        options = optimoptions(options, names{i}, opt_struct.(names{i}));
    end

    % check if gradients provided
    if gradients
        options = optimoptions(options, 'GradObj', 'on', 'GradConstr', 'on');
    end

    % shared variables
    xcheck = 2*ub;
    c = [];
    ceq = [];
    gc = [];
    gceq = [];

    % turn on file recording
    if ~isempty(printfile)
        % opens diary
        diary(printfile)
        % hack to flush diary to output file at each iteration
        usroutfun = options.OutputFcn;
        options = optimoptions(options, 'OutputFcn', @outfun);
    end

    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);

    % turn off file recording
    if ~isempty(printfile)
        diary off
    end

    % ---------- Update objectives and constraints ------------------
    function [Jout, cout, ceqout, gJout, gcout, gceqout] = fupdate(x)

        % run user function
        if ~gradients
            [Jout, cout, ceqout] = usrfun(x);
        else
            [Jout, cout, ceqout, gJout, gcout, gceqout] = usrfun(x);
        end

        if ~gradients
            gJout = [];
            gcout = [];
            gceqout = [];
        end

        xcheck = x;

    end

    % ---------- Objective Function ------------------
    function [Jout, gJout] = obj(x)
        [J, c, ceq, gJ, gc, gceq] = fupdate(x);
        Jout = J;
        gJout = gJ;
    end
    % -------------------------------------------------

    % ------------- Constraints ------------------------
    function [cout, ceqout, gcout, gceqout] = con(x)
        if any(x ~= xcheck)
            [J, c, ceq, gJ, gc, gceq] = fupdate(x);
        end
        cout = c;
        ceqout = ceq;
        gcout = gc;
        gceqout = gceq;
    end
    % ------------------------------------------------

    function stop = outfun(x, optimValues, state)
        diary off
        diary on
        if ~isempty(usroutfun)
            stop = usroutfun(x, optimValues, state);
        else
            stop = false;
        end
    end

end
