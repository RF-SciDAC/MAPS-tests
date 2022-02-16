##################################
1D Tests: Robin Boundary Condition
##################################

This test is designed to verify the user-defined Robin boundary
condition in the total energy equations.

The problem consists of constant density, velocity, and electron
energy with only the ion temperature allowed to vary. A homogeneous
Neumann BC (insulating) is applied at x=0 and a Robin BC at x=1. The
precise time evolution of the solution is unknown but we can compare
to a known steady state.

The Robin BC is defined as:

n_i chi_parallel Grad T_i + a n_i T_i = b

Where 'a' and 'b' are user defined constants and chi_parallel is the
parallel thermal diffusion coefficient. Clearly 'a' should be chosen
realtive to chi_parallel and 'b' to n_i * chi+parallel.

A suitable command line for this test problem would be:

transport2d -m slab_128.mesh -no-amr -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1e14 1e19 1 10 10' -op 8 -term-flags '-1 -1 -1 15 -1' -vs 1 -tf 1.0 -o 3
