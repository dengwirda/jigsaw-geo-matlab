## `AABB-Tree: Spatial Indexing in MATLAB`

A d-dimensional `aabb-tree` implementation in <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a>.

The `AABB-TREE` toolbox provides d-dimensional `aabb-tree` construction and search for arbitrary collections of spatial objects. These tree-based indexing structures are useful when seeking to implement efficient spatial queries, reducing the complexity of intersection tests between collections of objects. Specifically, given two "well-distributed" collections `P` and `Q`, use of `aabb`-type acceleration allows the set of intersections to be computed in `O(|P|*log(|Q|))`, which is typically a significant improvement over the `O(|P|*|Q|)` operations required by "brute-force" methods. 

Given a collection of objects, an `aabb-tree` partitions the axis-aligned bounding-boxes (`AABB`'s) associated with the elements in the collection into a (binary) "tree" -- a hierarchy of "nodes" (hyper-rectangles) that each store a subset of the collection. In contrast to other geometric tree types (`quadtrees`, `kd-trees`, etc), `aabb-trees` are applicable to collections of general objects, rather than just points. 

<p align="center">
  <img src = "github.com/dengwirda/aabb-tree/master/test-data/aabb-tree-1-small.png">
  <br>
  <br>
  <img src = "github.com/dengwirda/aabb-tree/master/test-data/aabb-tree-2-small.png">
</p>

## `Starting Out`

After downloading and unzipping the current <a href="https://github.com/dengwirda/aabb-tree/archive/master.zip">repository</a>, navigate to the installation directory within <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> and run the set of examples contained in `aabbdemo.m`:
````
aabbdemo(1); % build a tree for a 2-dimensional triangulation.
aabbdemo(2); % build a tree for a 3-dimensional triangulation.
aabbdemo(3); % compare a "fast" "aabb-accelerated" search with a "slow" brute-force computation.
````
## `Attribution!`

`AABB-TREE` is used extensively in the grid-generator <a href="https://github.com/dengwirda/mesh2d">`MESH2D`</a>. The tree-construction and search methods employed in the `AABB-TREE` library are described in further detail here: 

`[1]` - Darren Engwirda, <a href="http://hdl.handle.net/2123/13148">Locally-optimal Delaunay-refinement and optimisation-based mesh generation</a>, Ph.D. Thesis, School of Mathematics and Statistics, The University of Sydney, September 2014.
