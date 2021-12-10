#########################################
0D Tests: Linear Ionization Recombination
#########################################

This test is designed to verify the user-defined ionization and
recombination sources in the neutral and ion density equations.

The solutions have no spatial variation so this test could be
performed on a 0D mesh i.e. at a single spatial point.

Initially the ion and neutral densities are set equal to one and the
ion parallel velocity is zero. The other field equations will not be
activated so their initial conditions are unimportant.

The boundary conditions are not explicitly specified which leads to
homogeneous Neumann boundary conditions on both density
equations. This is equivalent to specifying that no particles may flow
in or out through the boundaries. Therefore the sum of the two
densities should remain constant.

To create a very simple test the ionization and recombination
coefficients are chosen to produce a coupled set of linear equations.

Ionization Source = 1.5 * rho_n
Recombination Source = 0.5 * rho_i

These choices lead to the exact solutions:
rho_n(t) = 0.5 + 0.5 * exp(-2*t)
rho_i(t) = 1.5 - 0.5 * exp(-2*t)

A suitable command line for this test problem would be:

transport2d -m slab_16.mesh -no-amr -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1 1 1 1 1' -op 3 -term-flags '7 15 0 0 0' -vs 1 -tf 10 
