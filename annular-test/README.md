The annular geometry test case has been designed to test the
`DGAnisoDiffIntegrator` and `DGAdvDiffIntegrator` integrators in the
ion density equation of the MAPS transport2d application. The test is
composed of two primary pieces. The first is a cylindrically symmetric
source function which gives rise to a known solution that varies in
time and is only dependent upon the perpendicular diffusion
coefficient. The second is an initial condition which decays at a rate
proportional to the parallel diffusion coefficient and optionally
rotates in the angular direction.

The equation being modeled in the ion density equation is:

d n_i / dt = Div(D_i Grad n_i)) - Div(v_i n_i b_hat) + S_i

with Dirichlet boundary conditions.

Where:
- `D_i` is the anisotropic diffusion tensor defined below
- `b_hat` is the unit vector field aligned with the magnetic field
  which in this test is given by `(-y/r, x/r)`
- `v_i` is the magnitude of the advection velocity and is given by
  `v1 * r` where v1 is a constant giving the velocity at a radius of 1
- `S_i` is the source term defined below

In order for the parallel portion of the solution to remain simple we
need to make the diffusion tensor depend upon the radius. Consequently
the parallel diffusion coefficient will vary with the radius
squared. The anisotropic diffusion tensor is given by:

D_i = d_perp * I - (d_perp - r^2 d_para) b_hat b_hat^T

The exact solution for either of these two modes is implemented in the
coefficient `AnnularTestSol` which can be found in the
`transport2d.cpp` miniapp source file. It is composed of three pieces:

n_i = a + a_para * n_para(r, theta, t) + a_perp * n_perp(r, t)

The solution requires nine parameters which must be specified in the
following order:

- ra: Inner radius of the annular region
- rb: Outer radius of the annular region
- w: Angular velocity of the advection term in radians per second
- d_para: Parallel diffusion coefficient
- d_perp: Perpendicular diffusion coefficient
- a: Coefficient of the constant term in the solution
- a_para: Coefficient of the parallel term in the solution
- a_perp: Coefficient of the perpendicular term in the solution
- n: Number of cycles in the angular dependence (positive integer)

The source term is only needed for the perpendicular diffusion
portions of the test. It is implemented in the coefficient
`AnnularTestSrc` which can be found in the `transport2d.cpp` miniapp
source file.  The sourse requires four parameters (a subset of the
nine needed by the solution) which must be specified in the following
order:

- ra: Inner radius of the annular region
- rb: Outer radius of the annular region
- d_perp: Perpendicular diffusion coefficient
- a_perp: Coefficient of the perpendicular term in the solution

Setting up the possible test cases requires a bit of care. Some notes
on the various input files are given here:

- transport2d_bcs.inp: The `AnnularTestSol` must be used for the
  Dirihclet BC of the ion density equation if the parallel diffusion
  and/or advection is being tested. Make sure the parameters are
  consistent with those in other input files. If only perpendicular
  diffusion is being tested this boundary condition can be set to zero
  using the line `ConstantCoefficient 0.0`.

- transport2d_ics.inp: The `AnnularTestSol` must be used for the
  initial condition of the ion density equation if the parallel
  diffusion and/or advection is being tested. Make sure the parameters
  are consistent with those in other input files. If only
  perpendicular diffusion is being tested this inital condition can be
  set to zero using the line `ConstantCoefficient 0.0`. If advection
  is being tested the `ion_parallel_velocity` must be set to `Radius [v1]`
  (with `[v1]` replaced with your angular velocity) otherwise this can
  be set to `ConstantCoefficient 0.0`.

- transport2d_ess.inp: To properly compute the error in the solution
  at each time step set the ion density to `AnnularTestSol` with the
  same parameters as elsewhere. The ion parallel velocity exact
  solution will be ignored so it does not need to be set.

- transport2d_ecs.inp: This file sets the parallel and perpendicular
  diffusion coefficients used in the simulation. The
  `para_diffusion_coef` must be set to `RadiusSqr [d_para]` with
  `[d_para]` being your desired value for the parallel diffusion
  coefficient. The `perp_diffusion_coef` can be set to any constant
  value (typically 1.0 but anything should work). For the solution to
  evolve as expected these `d_para` and `d_perp` values must be
  consistent with those provided to the `AnnularTestSol` and
  `AnnularTestSrc` coefficients in all input files. The `source_coef`
  can be omitted if the perpendicular portion of the solution is not
  being tested otherwise it must be set to `AnnularTestSrc` with a
  consistent set of parameters.


The command line to run the full test will be something like this:

mpirun -np 10 transport2d -m annulus-quad-r3-t04-o3.mesh -rs 0 -o 3 -no-amr -vs 1 -bc transport2d_bcs.inp -ic transport2d_ics.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -p 5 -term-flags '0 19 0 0 0' -op 2 -pt 1 -visit -pB 1 -B 1 > transport2d_annular.out

The `-term-flags` option is used for debugging in general. In this
test it is used to control the application of the source term and
which integrator is being used. The second value following this option
is the only relevant one for this test. The possible values are:

- 1: `DGAnisoDiffIntegrator` without source applied (implies a_perp = 0.0
  and v1 will be ignored)
- 3: `DGAdvDiffIntegrator` without source applied (implies a_perp = 0.0)
- 17: `DGAnisoDiffIntegrator` with source applied (v1 ignored)
- 19: `DGAdvDiffIntegrator` with source applied

To obtain the expected solutions `a_perp` and/or `v1` should be set to
zero in all occurances of `AnnularTestSol` and `AnnularTestSrc` if the
term flag is not set to 19.
