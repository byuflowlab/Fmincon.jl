# Fmincon.jl
Wrapper for MATLAB's fmincon.  A licensed copy of MATLAB and MATLAB's Optimization Toolbox is required to use this package.

# Installation:
First ensure that you have access to MATLAB and MATLAB's Optimization Toolbox.

Then follow the instructions for installing the [MATLAB.jl](https://github.com/JuliaInterop/MATLAB.jl) package

Then install this package
```
]add https://github.com/taylormcd/Fmincon.jl
```

# How this package handles functions callbacks

This package makes use of two packages in order to allow Fmincon to be called from Julia.  The first, [MATLAB.jl](https://github.com/JuliaInterop/MATLAB.jl) allows MATLAB to be called from Julia using the Matlab engine.  The second, [Mex.jl](https://github.com/taylormcd/Mex.jl) embeds Julia in the MATLAB process through the Mex interface. Using these packages the following relationship can be constructed.

          MATLAB ENGINE                  MEX
Julia <-------------------> MATLAB <-------------> Embedded Julia


Embedded Julia has no knowledge of the functions and variables defined in the main Julia process and can only interact through MATLAB with the main Julia process, therefore, Julia functions cannot be passed directly to/from the two Julia sessions.  To overcome this hurdle, a filename is passed which defines the objective/constraint function along with the name of the objective/constraint function.  Embedded Julia can therefore learn about these functions for itself, and since it is embedded, the functions in embedded Julia may be called freely by MATLAB.
