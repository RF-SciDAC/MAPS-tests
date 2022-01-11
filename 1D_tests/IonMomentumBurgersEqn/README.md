##########################################
1D Tests: Ion Momentum Advection Diffusion
##########################################

This test is designed to verify the proper implementation of the advection
and diffusion terms in the ion parallel momentum equation.

The solution is an exact solution based on an exact solution of the heat
equation. By the Cole-Hopf transformation and solution of the heat equation, u,
can produce a solution of Burger's equation as -kappa (du/dx)/u, where kappa is
the diffusion constant.

The boundary conditions are fixed at zero.

Suitable command lines for this problem would be:

transport2d -m slab_64.mesh -no-amr -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1 1 1 1 1' -op 4 -term-flags '0 0 3 0 0' -mi 1 -o 1 -l 2 -vs 1 -tf 10 -dt 1e-5 -tol 1e-1 -pt 2

transport2d -m slab_64.mesh -no-amr -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1 1 1 1 1' -op 4 -term-flags '0 0 3 0 0' -mi 1 -o 2 -l 2 -vs 1 -tf 10 -dt 1e-5 -tol 1e-2 -pt 2
