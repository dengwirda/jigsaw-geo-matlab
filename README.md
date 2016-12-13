# `JIGSAW-GEO: Grid-generation for geophysics`

<p align="center">
  <img src = "../master/jigsaw-geo/img/earth-topo-VORO-7-Y-small.jpg">
</p>

<a href="https://sites.google.com/site/dengwirda/jigsaw">`JIGSAW-GEO`</a> is an algorithm for the generation of non-uniform, locally-orthogonal staggered unstructured grids for geophysical modelling on the sphere. Typical applications include large-scale atmospheric simulation, ocean-modelling and numerical weather predicition. `JIGSAW-GEO` is designed to generate high-quality staggered Voronoi/Delaunay dual meshes using a combination of Frontal-Delaunay refinement and hill-climbing type mesh optimisation. 

`JIGSAW-GEO` is a stand-alone mesh generator written in `C++`, based on the general-purpose meshing package <a href="https://github.com/dengwirda/jigsaw-matlab">`JIGSAW`</a>. This toolbox provides a <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> based scripting interface, including file I/O, mesh visualisation and post-processing facilities. 

`JIGSAW-GEO` is currently available for `64-bit` `Windows` and `Linux` platforms.

# `Installation`

`JIGSAW-GEO` itself is a fully self-contained executable, without dependencies on third-party libraries or run-time packages. To make use of `JIGSAW-GEO`'s  scripting interface, users are required to have access to a working <a href="http://www.mathworks.com">`MATLAB`</a> and/or <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> installation.

# `Starting Out`

After downloading and unzipping the current <a href="https://github.com/dengwirda/jigsaw-geo-matlab/archive/master.zip">repository</a>, navigate to the installation directory within <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> and run the set of examples contained in `meshdemo.m`:
````
meshdemo(1); % a uniform resolution global grid
meshdemo(2); % global grid with regional "patch"
````

# `Attribution!`

If you make use of `JIGSAW-GEO` it's appreciated if you reference appropriately. Additional information regarding the formulation of the underlying `JIGSAW` meshing algorithm can be found <a href="https://github.com/dengwirda/jigsaw-matlab">here</a>.

`[1]` - Darren Engwirda, Locally-orthogonal, unstructured grid-generation for general circulation modelling on the sphere, under review, (https://arxiv.org/abs/1611.08996), 2016.

`[2]` - Darren Engwirda, Multi-resolution unstructured grid-generation for geophysical applications on the sphere, Research note, Proceedings of the 24th International Meshing Roundtable, (https://arxiv.org/abs/1512.00307), 2015.

