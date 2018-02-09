cimport cjigsaw

cdef jigsaw_init_jig():
    # initialie config
    cdef cjigsaw.jigsaw_jig_t jig
    cdef cjigsaw.jigsaw_jig_t* jig_ptr = &jig
    # fill with defaults
    cjigsaw.jigsaw_init_jig_t(jig_ptr)
    return jig

def init_jig():
    return jigsaw_init_jig()

cdef jigsaw_init_mesh():
    cdef cjigsaw.jigsaw_msh_t mesh
    cdef cjigsaw.jigsaw_msh_t* mesh_ptr = &mesh
    # fill with defaults
    cjigsaw.jigsaw_init_msh_t(mesh_ptr)
    return mesh._size

def init_mesh():
    mesh = jigsaw_init_mesh()
