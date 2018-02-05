from libc.stdint cimport int32_t
ctypedef double real_t
ctypedef int32_t indx_t

# constants
DEF JIGSAW_NULL_FLAG = -100
DEF JIGSAW_HFUN_RELATIVE = 300
DEF JIGSAW_HFUN_ABSOLUTE = 301
DEF JIGSAW_KERN_DELFRONT = 400
DEF JIGSAW_KERN_DELAUNAY = 401
DEF JIGSAW_EUCLIDEAN_MESH = 100
DEF JIGSAW_EUCLIDEAN_GRID = 101
DEF JIGSAW_EUCLIDEAN_DUAL = 102
DEF JIGSAW_ELLIPSOID_MESH = 200
DEF JIGSAW_ELLIPSOID_GRID = 201
DEF JIGSAW_ELLIPSOID_DUAL = 202

# lib_jigsaw.h has the following includes
#   include "jigsaw_jig_t.h"
#   include "jigsaw_msh_t.h"
# Does the preprocessor run before cython includes the code

cdef extern from "../jigsaw/inc/lib_jigsaw.h":

#cdef extern from '../jigsaw/inc/jigsaw_jig_t.h':
    ctypedef struct jigsaw_jig_t:
        # is this necessary? or can I just put `pass`
        # http://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html
        indx_t _verbosity
        indx_t _geom_seed
        indx_t _geom_feat
        real_t _geom_eta1
        real_t _geom_eta2
        real_t _hfun_hmax
        real_t _hfun_hmin
        indx_t _mesh_dims
        indx_t _mesh_kern
        indx_t _mesh_iter
        indx_t _mesh_top1
        indx_t _mesh_top2
        real_t _mesh_rad2
        real_t _mesh_rad3
        real_t _mesh_off2
        real_t _mesh_off3
        real_t _mesh_snk2
        real_t _mesh_snk3
        real_t _mesh_eps1
        real_t _mesh_eps2
        real_t _mesh_vol3
        indx_t _optm_iter
        real_t _optm_qtol
        real_t _optm_qlim
        indx_t _optm_tria
        indx_t _optm_dual
        indx_t _optm_zip_
        indx_t _optm_div_


#cdef extern from '../jigsaw/inc/jigsaw_msh_t.h':
    ctypedef struct jigsaw_VERT2_t:
        real_t _ppos[2]
        real_t _vpwr
        indx_t _itag

    ctypedef struct jigsaw_VERT3_t:
        real_t _ppos[3]
        real_t _vpwr
        indx_t _itag

    ctypedef struct jigsaw_EDGE2_t:
        indx_t _node[2]
        indx_t _itag

    ctypedef struct jigsaw_TRIA3_t:
        indx_t _node[3]
        indx_t _itag

    ctypedef struct jigsaw_TRIA4_t:
        indx_t _node[4]
        indx_t _itag

    ctypedef struct jigsaw_VERT2_array_t:
        indx_t _size
        jigsaw_VERT2_t *_data

    ctypedef struct jigsaw_VERT3_array_t:
        indx_t _size
        jigsaw_VERT3_t *_data

    ctypedef struct jigsaw_EDGE2_array_t:
        indx_t _size
        jigsaw_EDGE2_t *_data

    ctypedef struct jigsaw_TRIA3_array_t:
        indx_t _size
        jigsaw_TRIA3_t *_data

    ctypedef struct jigsaw_TRIA4_array_t:
        indx_t _size
        jigsaw_TRIA4_t *_data

    ctypedef struct jigsaw_REALS_array_t:
        indx_t _size
        real_t *_data

    ctypedef struct jigsaw_msh_t:
        indx_t _flags

        # if (_flags == EUCLIDEAN_MESH)
        jigsaw_VERT2_array_t _vert2
        jigsaw_VERT3_array_t _vert3
        jigsaw_EDGE2_array_t _edge2
        jigsaw_TRIA3_array_t _tria3
        jigsaw_TRIA4_array_t _tria4

        # if (_flags == ELLIPSOID_MESH)
        jigsaw_REALS_array_t _radii

        # if (_flags == EUCLIDEAN_GRID)
        jigsaw_REALS_array_t _xgrid
        jigsaw_REALS_array_t _ygrid
        jigsaw_REALS_array_t _zgrid

        # if (_flags == EUCLIDEAN_MESH)
        # OR (_flags == EUCLIDEAN_GRID)
        jigsaw_REALS_array_t _value


    indx_t jigsaw_make_mesh (
        jigsaw_jig_t *_jcfg,
        jigsaw_msh_t *_geom,
        jigsaw_msh_t *_hfun,
        jigsaw_msh_t *_mesh
        )

    void jigsaw_alloc_vert2 (
      jigsaw_VERT2_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_alloc_vert3 (
      jigsaw_VERT3_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_alloc_edge2 (
      jigsaw_EDGE2_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_alloc_tria3 (
      jigsaw_TRIA3_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_alloc_tria4 (
      jigsaw_TRIA4_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_alloc_reals (
      jigsaw_REALS_array_t *_xsrc ,
      indx_t _size
      )

    void jigsaw_free_msh_t (
      jigsaw_msh_t *_mesh
      )

    void jigsaw_init_msh_t (
      jigsaw_msh_t *_mesh
      )

    void jigsaw_init_jig_t (
      jigsaw_jig_t *_jjig
      )
