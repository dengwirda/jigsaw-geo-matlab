## `JIGSAW(GEO): Mesh generation for geoscientific modelling`

<p align="center">
  <img src = "../master/jigsaw/img/JIGSAW-southern-ocean-voronoi.jpg">
</p>

`JIGSAW(GEO)` is a set of algorithms designed to generate unstructured grids for computational geophysics. Applications include: large-scale atmospheric simulation and numerical weather prediction, global and coastal ocean-modelling, and ice-sheet dynamics. 

`JIGSAW(GEO)` can be used to produce high-quality staggered Delaunay / Voronoi tessellations for unstructured finite-volume / element type models. Grids can be generated in local two-dimensional domains, and over general spheroidal surfaces. Mesh resolution can be adapted to follow complex user-defined metrics, including: topographic contours, discrete solution profiles or coastal features. These features enable the generation of complex, multi-resolution climate process models, with simulation fidelity enhanced in regions of interest.

`JIGSAW(GEO)` is a stand-alone mesh generator written in `c++`, based on the general-purpose meshing package <a href="https://github.com/dengwirda/jigsaw-matlab">`JIGSAW`</a>. This toolbox provides a <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> based scripting interface, including `file I/O`, `mesh visualisation` and `post-processing` facilities. The underlying `JIGSAW` library is a collection of unstructured triangle- and tetrahedron-based meshing algorithms, designed to produce high quality Delaunay-based grids for computational simulation. `JIGSAW` includes both Delaunay-refinement based algorithms for the 
construction of new meshes, as well as optimisation driven methods for the improvement of existing grids. 

`JIGSAW(GEO)` is typically able to produce the very high-quality unstructured grids required by contemporary unstructued general circulation models (i.e. <a href="https://github.com/MPAS-Dev/MPAS-Release">`MPAS`</a>, <a href="https://research.csiro.au/cem/software/ems/hydro/unstructured-compas/">`COMPAS`</a>, <a href="http://fesom.de/">`FESOM`</a>, <a href="https://www.mpimet.mpg.de/en/science/models/icon-esm/">`ICON`</a>, etc), generating highly optimised, multi-resolution meshes that are `locally-orthogonal`, `mutually-centroidal` and `self-centred`.

`JIGSAW(GEO)` has been compiled and tested on various `64-bit` `Linux` , `Windows` and `Mac` based platforms. 

## `Code Structure`

`JIGSAW(GEO)` is a multi-part library, consisting of a `MATLAB` / `OCTAVE` front-end, and a core `c++` back-end. All of the heavy-lifting is done in the `c++` layer - the interface contains additional scripts for `file I/O`, `visualisation` and general `data processing`:

	JIGASW(GEO) :: MATLAB/OCTAVE top-level functions
	├── script  -- MATLAB/OCTAVE utilities
	└── jigsaw
	    ├── src -- JIGSAW source files
	    ├── inc -- JIGSAW header files (for libjigsaw)
	    ├── bin -- put JIGSAW exe binaries here
	    ├── lib -- put JIGSAW lib binaries here
	    ├── geo -- default folder for JIGSAW inputs
	    ├── out -- default folder for JIGSAW output
	    └── uni -- unit tests and libjigsaw programs


The `MATLAB` / `OCTAVE` interface is provided for convenience - you're not forced to use it, but it's perhaps the easiest way to get started!

It's also possible to interact with the `JIGSAW` back-end directly, either through `(i)` scripting: building text file inputs and calling the `JIGSAW` executable from the command-line, or `(ii)` programmatically: using `JIGSAW` data-structures within your own applications and calling the library via its `API`.

## `Getting Started`

The first step is to compile the code! The `JIGSAW` src can be found in <a href="../master/jigsaw/src/">`../jigsaw/src/`</a>.

`JIGSAW` is a `header-only` package - there is only the single main `jigsaw.cpp` file that simply `#include`'s the rest of the library as headers. The resulting build process should be fairly straight-forward as a result. `JIGSAW` does not currently dependent on any external packages or libraries.

#### `On Linux/Mac`

`JIGSAW` has been successfully built using various versions of the `g++` and `llvm` compilers. Since the build process is a simple one-liner, there's no `make` script - instead:

	g++ -std=c++11 -pedantic -Wall -s -O3 -flto -D NDEBUG -static-libstdc++ 
	jigsaw.cpp -o jigsaw64r
	
can be used to build a `JIGSAW` executable, while:

	g++ -std=c++11 -pedantic -Wall -O3 -flto -fPIC -D NDEBUG -static-libstdc++ 
	jigsaw.cpp -shared -o libjigsaw64r.so

can be used to build a `JIGSAW` shared library. See the headers in <a href="../master/jigsaw/inc/">`../jigsaw/inc/`</a> for details on the `API`. The `#define __lib_jigsaw` directive in `jigsaw.cpp` toggles the source between executable and shared-library modes.

#### `On Windows`

`JIGSAW` has been successfully built using various versions of the `msvc` compiler. I do not provide a sample `msvc` project, but the following steps can be used to create one:

	* Create a new, empty MSVC project.
	* Import the jigsaw.cpp file, this contains the main() entry-point.
	* Modify the MSVC project settings to include the "../src/" directory.

#### `Folder Structure`

Once you have built the `JIGSAW` binaries, place them in the appropriate sub-folders in`../jigsaw/bin/` and/or `../jigsaw/lib/` directories, so that they can be found by the `MATLAB` / `OCTAVE` interface, and the unit tests in `../jigsaw/uni/`. If you wish to support multiple platforms, simply build binaries for each `OS` and place them in the appropriate directory - the `MATLAB` / `OCATVE` interface will do an `OS`-dependent lookup to call the appropriate binary.

## `Example Problems`

After downloading and building the code, navigate to the root `JIGSAW(GEO)` directory within your <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> installation to run the set of examples contained in `meshdemo.m`:
````
meshdemo(1); % a simple, two-dimensional domain.
meshdemo(2); % a multi-resolution grid for the Australian region.
meshdemo(3); % a uniform resolution spheroidal grid.
meshdemo(4); % a global grid with regional "patch".
meshdemo(5); % a global grid with multi-resolution grid-spacing constraints.
````
Additionally, the <a href="../master/jigsaw/example.jig">`../jigsaw/example.jig`</a> file provides a description of `JIGSAW`'s configuration options, and can be used as a command-line example. A set of unit-tests and `libjigsaw` example programs are contained in <a href="../master/jigsaw/uni/">`../jigsaw/uni/`</a>. The `JIGSAW-API` is documented via the header files in <a href="../master/jigsaw/inc/">`../jigsaw/inc/`</a>.

## `License`

This program may be freely redistributed under the condition that the copyright notices (including this entire header) are not removed, and no compensation is received through use of the software.  Private, research, and institutional use is free.  You may distribute modified versions of this code `UNDER THE CONDITION THAT THIS CODE AND ANY MODIFICATIONS MADE TO IT IN THE SAME FILE REMAIN UNDER COPYRIGHT OF THE ORIGINAL AUTHOR, BOTH SOURCE AND OBJECT CODE ARE MADE FREELY AVAILABLE WITHOUT CHARGE, AND CLEAR NOTICE IS GIVEN OF THE MODIFICATIONS`. Distribution of this code as part of a commercial system is permissible `ONLY BY DIRECT ARRANGEMENT WITH THE AUTHOR`. (If you are not directly supplying this code to a customer, and you are instead telling them how they can obtain it for free, then you are not required to make any arrangement with me.) 

`DISCLAIMER`:  Neither I nor: Columbia University, the Massachusetts Institute of Technology, the University of Sydney, nor the National Aeronautics and Space Administration warrant this code in any way whatsoever.  This code is provided "as-is" to be 
used at your own risk.

## `References`

Information and references regarding the formulation of the underlying `JIGSAW` mesh-generator can also be found <a href="https://github.com/dengwirda/jigsaw-matlab">here</a>. Additionally, there are a number of publications that describe the algorithms used in `JIGSAW(GEO)` in detail. Please cite as appropriate:

`[1]` - Darren Engwirda: Generalised primal-dual grids for unstructured co-volume schemes, to appear: J. Comp. Phys., https://arxiv.org/abs/1712.02657, 2017.

`[2]` - Darren Engwirda: JIGSAW-GEO (1.0): locally orthogonal staggered unstructured grid generation for general circulation modelling on the sphere, Geosci. Model Dev., 10, 2117-2140, https://doi.org/10.5194/gmd-10-2117-2017, 2017.

`[3]` - Darren Engwirda, David Ivers, Off-centre Steiner points for Delaunay-refinement on curved surfaces, Computer-Aided Design, 72, 157-171, http://dx.doi.org/10.1016/j.cad.2015.10.007, 2016.

`[4]` - Darren Engwirda: Multi-resolution unstructured grid-generation for geophysical applications on the sphere, Research note, Proceedings of the 24th International Meshing Roundtable, https://arxiv.org/abs/1512.00307, 2015.

`[5]` - Darren Engwirda, Locally-optimal Delaunay-refinement and optimisation-based mesh generation, Ph.D. Thesis, School of Mathematics and Statistics, The University of Sydney, http://hdl.handle.net/2123/13148, 2014.

