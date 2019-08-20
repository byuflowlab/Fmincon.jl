function barnes(x)

    a1 = 75.196
    a3 = 0.12694
    a5 = 1.0345e-5
    a7 = 0.030234
    a9 = 3.5256e-5
    a11 = 0.25645
    a13 = 1.3514e-5
    a15 = -5.2375e-6
    a17 = 7.0e-10
    a19 = -1.6638e-6
    a21 = 0.0005
    a2 = -3.8112
    a4 = -2.0567e-3
    a6 = -6.8306
    a8 = -1.28134e-3
    a10 = -2.266e-7
    a12 = -3.4604e-3
    a14 = -28.106
    a16 = -6.3e-8
    a18 = 3.4054e-4
    a20 = -2.8673

    x1 = x[1]
    x2 = x[2]
    y1 = x1*x2
    y2 = y1*x1
    y3 = x2^2
    y4 = x1^2

    # --- function value ---

    f = a1 + a2*x1 + a3*y4 + a4*y4*x1 + a5*y4^2 +
        a6*x2 + a7*y1 + a8*x1*y1 + a9*y1*y4 + a10*y2*y4 +
        a11*y3 + a12*x2*y3 + a13*y3^2 + a14/(x2+1) +
        a15*y3*y4 + a16*y1*y4*x2 + a17*y1*y3*y4 + a18*x1*y3 +
        a19*y1*y3 + a20*exp(a21*y1)

    # --- constraints ---

    c = zeros(3)
    c[1] = 1 - y1/700.0
    c[2] = y4/25.0^2 - x2/5.0
    c[3] = (x1/500.0- 0.11) - (x2/50.0-1)^2


    # --- derivatives of f ---

    dy1 = x2
    dy2 = y1 + x1*dy1
    dy4 = 2*x1
    dfdx1 = a2 + a3*dy4 + a4*y4 + a4*x1*dy4 + a5*2*y4*dy4 +
        a7*dy1 + a8*y1 + a8*x1*dy1 + a9*y1*dy4 + a9*y4*dy1 + a10*y2*dy4 + a10*y4*dy2 +
        a15*y3*dy4 + a16*x2*y1*dy4 + a16*x2*y4*dy1 + a17*y3*y1*dy4 + a17*y3*y4*dy1 + a18*y3 +
        a19*y3*dy1 + a20*exp(a21*y1)*a21*dy1

    dy1 = x1
    dy2 = x1*dy1
    dy3 = 2*x2
    dfdx2 = a6 + a7*dy1 + a8*x1*dy1 + a9*y4*dy1 + a10*y4*dy2 +
        a11*dy3 + a12*x2*dy3 + a12*y3 + a13*2*y3*dy3 + a14*-1/(x2+1)^2 +
        a15*y4*dy3 + a16*y4*y1 + a16*y4*x2*dy1 + a17*y4*y1*dy3 + a17*y4*y3*dy1 + a18*x1*dy3 +
        a19*y3*dy1 + a19*y1*dy3 + a20*exp(a21*y1)*a21*dy1

    dfdx = [dfdx1, dfdx2]


    # --- derivatives of c ---

    dcdx = zeros(3, 2)
    dcdx[1, 1] = -x2/700.0
    dcdx[1, 2] = -x1/700.0
    dcdx[2, 1] = 2*x1/25^2
    dcdx[2, 2] = -1.0/5
    dcdx[3, 1] = 1.0/500
    dcdx[3, 2] = -2*(x2/50.0-1)/50.0

    dcdx = dcdx'  # matlab format

    return f/30.0, c, Float64[], dfdx/30.0, dcdx, Float64[]
end
