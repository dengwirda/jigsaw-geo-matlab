from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension("jigsaw", ["./jigsaw-python/jigsaw.pyx"],
        include_dirs = ['/Users/rpa/Code/jigsaw-geo-matlab/jigsaw/inc'],
        libraries = ['jigsaw64r'],
        library_dirs = ['/Users/rpa/Code/jigsaw-geo-matlab/jigsaw/lib/MAC-64'])
]
setup(
    name = "jigsaw",
    ext_modules = cythonize(extensions),
)
