## `JIGSAW(GEO): Grid-generation for geophysical modelling`

<p align="center">
  <img src = "../master/jigsaw-geo/img/JIGSAW-southern-ocean-voronoi.jpg">
</p>

`JIGSAW(GEO)` is a set of algorithms designed to generate complex, unstructured grids for geophysical modelling applications, including `locally-orthogonal` `staggered` `Delaunay/Voronoi` tessellations appropriate for unstructured `finite-volume`/`element` type general circulation models. Grids can be generated in local, two-dimensional domains, and over general spheroidal surfaces. Typical applications include: large-scale atmospheric simulation, ocean-modelling and numerical weather predicition, as well as coastal ocean modelling and ice-sheet dynamics.

`JIGSAW(GEO)` is a stand-alone mesh generator written in `c++`, based on the general-purpose meshing package <a href="https://github.com/dengwirda/jigsaw-matlab">`JIGSAW`</a>. This toolbox provides a <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> based scripting interface, including file I/O, mesh visualisation and post-processing facilities. The underlying `JIGSAW` library is a collection of unstructured triangle- and tetrahedron-based meshing algorithms, designed to produce very high quality Delaunay-based grids for computational simulation. `JIGSAW` includes both Delaunay "refinement" based algorithms for the 
construction of new meshes, as well as optimisation driven methods for the "improvement" of existing grids. `JIGSAW` supports both two- and three-dimensional operations, catering to a variety of planar, surface and volumetric configurations.

`JIGSAW(GEO)` is typically able to produce the very high-quality `staggered` `Voronoi` type grids required by a number of unstructued geophysical solvers (i.e. <a href="https://github.com/MPAS-Dev/MPAS-Release">`MPAS`</a>, <a href="http://www.emg.cmar.csiro.au/www/en/emg/software/EMS/hydrodynamics/Unstructured.html">`COMPAS`</a>, etc), generating highly optimised, multi-resolution meshes that are `locally-orthogonal`, `centroidal` and `well-centred`.

`JIGSAW(GEO)` has been compiled and tested on various `64-bit` `Linux` , `Windows` and `Mac` based platforms. 

## `Code Structure`

`JIGSAW(GEO)` is a multi-part library, consisting of a `MATLAB`/`OCTAVE` front-end, and a core `c++` back-end. All of the heavy-lifting is done in the `c++` layer - the interface contains additional scripts for file I/O, visualisation and general data processing:

	JIGASW(GEO)::
	├── mesh-util -- MATLAB/OCTAVE utilities
	└── jigsaw
	    ├── src -- JIGSAW src code
	    ├── inc -- JIGSAW header files (for libjigsaw)
	    ├── bin -- put JIGSAW exe binaries here
	    ├── lib -- put JIGSAW lib binaries here
	    ├── geo -- geometry definitions and input data
	    ├── out -- default folder for JIGSAW output
	    └── uni -- unit tests and libjigsaw example programs


The `MATLAB`/`OCTAVE` interface is provided for convenience - you don't have to use it, but it's probably the easiest way to get started!

It's also possible to interact with the `JIGSAW` back-end directly, either through (i) scripting: building text file inputs and calling the `JIGSAW` executable from the command-line, or (ii) programmatically: using the JIGSAW data-structures within your own applications and calling the `JIGSAW` library via its `API`.

## `Getting Started`

The first step is to compile the code! The `JIGSAW` src can be found in <a href="../master/jigsaw/src/">`../jigsaw/src/`</a>.

`JIGSAW` is a `header-only` package - there is only the single main `jigsaw.cpp` file that simply `#include`'s the rest of the library as headers. The resulting build process should be fairly straight-forward as a result. `JIGSAW` does not currently depened on any external packages or libraries.

### `On Linux/Max`

`JIGSAW` has been successfully built using various versions of the `g++` and `llvm` compilers. Since the build process is a simple one-liner, there's no `make` script - instead:

	g++ -std=c++11 -pedantic -Wall -s -O3 -flto -D NDEBUG -I libcpp 
	-static-libstdc++ jigsaw.cpp -o jigsaw64r
	
can be used to build a `JIGSAW` executable, while:

	g++ -std=c++11 -pedantic -Wall -O3 -flto -fPIC -D NDEBUG -I libcpp 
	-static-libstdc++ jigsaw.cpp -shared -o libjigsaw64r.so

can be used to build a `JIGSAW` shared library. See the headers in <a href="../master/jigsaw/inc/">`../jigsaw/inc/`</a> for details on the `API`. The `#define __lib_jigsaw` directive in `jigsaw.cpp` toggles the source between executable and shared-library modes.

### `On Windows`

`JIGSAW` has been successfully built using various versions of the `msvc` compiler. I do not provide a sample `msvc` project, but the following steps can be used to create one:

	* Create a new, empty MSVC project.
	* Import the jigsaw.cpp file, this contains the main() entry-point.
	* Modify the MSVC project settings to include the directory "../src/libcpp/" directory.
	* Modify the MSVC project settings and select "Disable Language Extensions" (i.e. just standard c++ !).

### `Folder Structure`

Once you have built the `JIGSAW` binaries, place them in the appropraiet sub-folders in`../jigsaw/bin/` and/or `../jigsaw/lib/` directories, so that they can be found by the `MATLAB`/`OCTAVE` interface, and the unit tests in `../jigsaw/uni/`. If you wish to support multiple platforms, simply build binaries for each `OS` and place them in the appropriate directory - the `MATLAB`/`OCATVE` interface will do an `OS`-dependent lookup when calling the binary.

## `Example Problems`

After downloading and building the code, navigate to the root `JIGSAW(GEO)` directory within your <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> installation to run the set of examples contained in `meshdemo.m`:
````
meshdemo(1); % a simple, two-dimensional domain.
meshdemo(2); % a multi-resolution grid for the Australian region.
meshdemo(3); % a uniform resolution spheroidal grid.
meshdemo(4); % a global grid with regional "patch".
meshdemo(5); % a global grid with multi-resolution grid-spacing constraints.
````

## `Licence`

This program may be freely redistributed under the condition that the copyright notices (including this entire header) are not removed, and no compensation is received through use of the software.  Private, research, and institutional use is free.  You may distribute modified versions of this code `UNDER THE CONDITION THAT THIS CODE AND ANY MODIFICATIONS MADE TO IT IN THE SAME FILE REMAIN UNDER COPYRIGHT OF THE ORIGINAL AUTHOR, BOTH SOURCE AND OBJECT CODE ARE MADE FREELY AVAILABLE WITHOUT CHARGE, AND CLEAR NOTICE IS GIVEN OF THE MODIFICATIONS`. Distribution of this code as part of a commercial system is permissible `ONLY BY DIRECT ARRANGEMENT WITH THE AUTHOR`. (If you are not directly supplying this code to a customer, and you are instead telling them how they can obtain it for free, then you are not required to make any arrangement with me.) 

Disclaimer:  Neither I nor: Columbia University, The Massachusetts Institute of Technology, The University of Sydney, nor the National Aeronautics and Space Administration warrant this code in any way whatsoever.  This code is provided "as-is" to be 
used at your own risk.

## `References!`

If you make use of `JIGSAW(GEO)` please include a reference to the following. Additional information and references regarding the formulation of the underlying `JIGSAW` mesh-generator can also be found <a href="https://github.com/dengwirda/jigsaw-matlab">here</a>.

`[1]` - Darren Engwirda: JIGSAW-GEO (1.0): locally orthogonal staggered unstructured grid generation for general circulation modelling on the sphere, Geosci. Model Dev., 10, 2117-2140, https://doi.org/10.5194/gmd-10-2117-2017, 2017.

`[2]` - Darren Engwirda, Multi-resolution unstructured grid-generation for geophysical applications on the sphere, Research note, Proceedings of the 24th International Meshing Roundtable, (https://arxiv.org/abs/1512.00307), 2015.

