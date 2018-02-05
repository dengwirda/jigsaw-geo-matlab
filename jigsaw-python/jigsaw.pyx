cimport cjigsaw

cdef jigsaw_init_jig():
    # initialie config
    cdef cjigsaw.jigsaw_jig_t jig
    cdef cjigsaw.jigsaw_jig_t* jig_ptr = &jig
    # fill with defaults
    #cjigsaw.jigsaw_init_jig_t(jig_ptr)
    return jig

def init_jig():
    return jigsaw_init_jig()
