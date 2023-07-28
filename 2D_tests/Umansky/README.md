This benchmark is designed to compare with the test problem described in
section 3 of: 
M. V. Umansky, M. S. Day & T. D. Rognlien (2005) "On Numerical Solution of
Strongly Anisotropic Diffusion Equation on Misaligned Grids", Numerical Heat
Transfer, Part B: Fundamentals, 47:6, 533-554, DOI: 10.1080/10407790590928946

This test problem is defined on a rectangular domain with a fixed height of
1 unit and widths of 1, 10, or 100 units. Meshes for these different domains
are organized into subdirectories with names "L1". "L10", and "L100"
respectively. Two different mesh resolutions are provided, n5 and n15, which
produce Cartesian grids containing 5 or 15 elements in each direction. The
paper uses mesh resolutions of 20x20, 30x30, and 40x40 which can be obtained
by uniformly refining the provided meshes.

The file "transport2d_ets.inp" contains directives to disable most of the
equations and terms available in transport2d. The only enabled pieces are the
time derivative terms and the diffusion term in the ion total energy equation.

Each of the "L1", "L10", and "L100" subdirectories contains further
subdirectories to distinguish different anisotropy ratio results. These are
labeled "A1e0", "A1e3", etc.. Each "A1e?" subdirectory contains a
"transport2d_ecs.inp" file which defines the diffusion coefficients
corresponding to the desired anisotropy ratio as well as a magnetic field
directed along the diagonal of the domain corresponding to the parent "L?"
directory.

Finally the "A1e?" directories contain subdirectories for individual
simulations using particular combinations of mesh resolution and basis function
order. For example a subdirectory might be labeled "N20x20_P2" which would
indicate a 20x20 Cartesian grid and 2nd order basis functions. The names
of these subdirectories are arbitrary but some logical scheme would obviously
be useful. A few such subdirectories are provided and contain
"transport2d_ics.inp" and "transport2d_bcs.inp" files specialied to the
corresponding mesh resolution and basis function order needed to properly
initialize the new initial and boundary condition functions respectively.

The "transport2d.cpp" code contains an initial condition function, which can
also be used as a boundary condition, which approximates the discontinuous
boundary condition described in the paper. This function is continuous on the
boundary and has continuous derivatives of order one less than the basis
function order. The function is not continuous in the interior of the domain
but its discontinuity should be small. The interior function is zero above a
diagonal strip of elements, one below this strip, and transitions between
these values using a hyperbolic tangent. At the boundary this transition is
replaced with a polynomial approximation so that the basis functions can
capture it precisely. This function can be configured in input files by
providing the basis function order, the width and height of the domain, and
the expected element widths in the horizontal and vertical directions
(i.e. hx and hy) of the corner elements.

The paper makes use of a transition width metric which is implemented in the
"transport2d.cpp" code using Mesh::FindPoints and a bisection algorithm. This
width computation must be activated by providing the "-umansky" command line
option.

Suggested command line:

cd L1/A1e3/N20x20_P2
transport2d -no-amr -umansky -visit -vs 1 -et ../../../transport2d_ets.inp -ec ../transport2d_ecs.inp -ic transport2d_ics.inp -bc transport2d_bcs.inp -vis-flags '-1 -1 -1 4095 -1' -srtol 1e-6 -dt 1e-2 -dt-floor 1e-2 -tf 100 -o 2 -m ../../inline-quad-1x1-n5.mesh -rp 2 
