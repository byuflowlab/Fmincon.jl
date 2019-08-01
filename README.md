# Fmincon.jl
Wrapper for MATLAB's fmincon.  A licensed copy of MATLAB and MATLAB's Optimization Toolbox is required to use this package.

# Installation:
First ensure that you have access to MATLAB and MATLAB's Optimization Toolbox.

Then follow the instructions for installing the [MATLAB.jl](https://github.com/JuliaInterop/MATLAB.jl) package

Then follow the instructions for installing the [Mex.jl](https://github.com/byuflowlab/Mex.jl) package

Then install this package
```
]add https://github.com/byuflowlab/Fmincon.jl
```

# How this package handles functions callbacks

This package makes use of two packages in order to allow Fmincon to be called from Julia.  The first, [MATLAB.jl](https://github.com/JuliaInterop/MATLAB.jl) allows MATLAB to be called from Julia using the Matlab engine.  The second, [Mex.jl](https://github.com/taylormcd/Mex.jl) embeds Julia in the MATLAB process through the Mex interface. Using these packages the following relationship can be constructed.

Julia <--- (MATLAB ENGINE) ---> MATLAB <--- (MEX Interface) ---> Embedded Julia

The Mex interface allows Julia functions to be wrapped in MATLAB function handles, whereas the MATLAB engine interface does not.  Therefore Julia callbacks need to be performed by Embedded Julia.  However, since MATLAB stands between Julia and Embedded Julia, a function cannot be directly passed from one to the other.  Therefore Julia instead passes Embedded Julia a file which defines the necessary function and the name of the function.  Embedded Julia then parses the function and MATLAB wraps the function in a MATLAB function handle.
