from distutils.core import setup
from Cython.Build import cythonize

setup(
    name = "twinbent_cython",
    ext_modules = cythonize('twinbent_cython.pyx'),
)