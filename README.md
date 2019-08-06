## `JIGSAW(GEO): Mesh generation for geoscientific modelling`

<p align="center">
  <img src = "../master/image/voro.jpg">
</p>

`JIGSAW(GEO)` is a set of algorithms designed to generate unstructured grids for geoscientific modelling. Applications include: large-scale atmospheric simulation and numerical weather prediction, global and coastal ocean-modelling, and ice-sheet dynamics. 

`JIGSAW(GEO)` can be used to produce high-quality 'generalised' Delaunay / Voronoi tessellations for unstructured finite-volume / element type models. Grids can be generated in local two-dimensional domains, and over general spheroidal surfaces. Mesh resolution can be adapted to follow complex user-defined metrics, including: topographic contours, discrete solution profiles or coastal features. This enables the construction of complex, multi-resolution climate process models, with simulation fidelity enhanced in regions of interest.

`JIGSAW(GEO)` is typically able to produce the very high-quality staggered unstructured grids required by contemporary unstructued general circulation models (i.e. <a href="https://github.com/MPAS-Dev/MPAS-Release">`MPAS`</a>, <a href="https://research.csiro.au/cem/software/ems/hydro/unstructured-compas/">`COMPAS`</a>, <a href="http://fesom.de/">`FESOM`</a>, <a href="https://www.mpimet.mpg.de/en/science/models/icon-esm/">`ICON`</a>, etc), generating highly optimised, multi-resolution meshes that are `locally-orthogonal`, `mutually-centroidal` and `self-centred`.

`JIGSAW(GEO)` depends on the <a href="https://github.com/dengwirda/jigsaw-matlab">`JIGSAW-MATLAB`</a> package; a `MATLAB` / `OCTAVE` interface to the underlying `JIGSAW` meshing library.

### `Quickstart`

`JIGSAW(GEO)` requires the `JIGSAW` meshing package be installed and available on the `MATLAB` / `OCTAVE` path. `JIGSAW`'s `MATLAB` / `OCTAVE` interface is available <a href="https://github.com/dengwirda/jigsaw-matlab">here</a>. Once installed, the test problems can be run via:

    Clone/download + unpack this repository.
    From `MATLAB` / `OCTAVE`:
    Ensure `JIGSAW-MATLAB` is available on the path.
    Run example.m

Note: installation of `JIGSAW` requires a `c++` compiler and the `cmake` utility. `JIGSAW` may also be installed as a `conda` package. See <a href="https://github.com/dengwirda/jigsaw">here</a> for details.

### `Example Problems`

The following set of example problems are available in `example.m`:

    example(1); % generate a uniform resolution global grid
    example(2); % generate a regionally-refined global grid
    example(3); % build smooth mesh-spacing functions from noisy input data
    example(4); % generate a complex, variable resolution global grid
    example(5); % generate a coastal mesh for the Australasian region
    example(6); % generate a multi-part mesh for the (contiguous) USA

### `License`

This program may be freely redistributed under the condition that the copyright notices (including this entire header) are not removed, and no compensation is received through use of the software.  Private, research, and institutional use is free.  You may distribute modified versions of this code `UNDER THE CONDITION THAT THIS CODE AND ANY MODIFICATIONS MADE TO IT IN THE SAME FILE REMAIN UNDER COPYRIGHT OF THE ORIGINAL AUTHOR, BOTH SOURCE AND OBJECT CODE ARE MADE FREELY AVAILABLE WITHOUT CHARGE, AND CLEAR NOTICE IS GIVEN OF THE MODIFICATIONS`. Distribution of this code as part of a commercial system is permissible `ONLY BY DIRECT ARRANGEMENT WITH THE AUTHOR`. (If you are not directly supplying this code to a customer, and you are instead telling them how they can obtain it for free, then you are not required to make any arrangement with me.) 

`DISCLAIMER`:  Neither I nor: Columbia University, the Massachusetts Institute of Technology, the University of Sydney, nor the National Aeronautics and Space Administration warrant this code in any way whatsoever.  This code is provided "as-is" to be used at your own risk.

### `References`

There are a number of publications that describe the algorithms used in `JIGSAW(GEO)` in detail. Additional information and references regarding the formulation of the underlying `JIGSAW` mesh-generator can also be found <a href="https://github.com/dengwirda/jigsaw">here</a>. If you make use of `JIGSAW` in your work, please consider including a reference to the following: 

`[1]` - Darren Engwirda: Generalised primal-dual grids for unstructured co-volume schemes, J. Comp. Phys., 375, pp. 155-176, https://doi.org/10.1016/j.jcp.2018.07.025, 2018.

`[2]` - Darren Engwirda: JIGSAW-GEO (1.0): locally orthogonal staggered unstructured grid generation for general circulation modelling on the sphere, Geosci. Model Dev., 10, pp. 2117-2140, https://doi.org/10.5194/gmd-10-2117-2017, 2017.

`[3]` - Darren Engwirda, David Ivers, Off-centre Steiner points for Delaunay-refinement on curved surfaces, Computer-Aided Design, 72, pp. 157-171, http://dx.doi.org/10.1016/j.cad.2015.10.007, 2016.

`[4]` - Darren Engwirda: Multi-resolution unstructured grid-generation for geophysical applications on the sphere, Research note, Proceedings of the 24th International Meshing Roundtable, https://arxiv.org/abs/1512.00307, 2015.

`[5]` - Darren Engwirda, Locally-optimal Delaunay-refinement and optimisation-based mesh generation, Ph.D. Thesis, School of Mathematics and Statistics, The University of Sydney, http://hdl.handle.net/2123/13148, 2014.



