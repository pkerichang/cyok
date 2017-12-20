import os
from distutils.core import setup, Extension
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(Extension('cyok',
                                    sources=['src/cyok.pyx'],
                                    language='c++',
                                    include_dirs=['include'],
                                    libraries=['okFrontPanel'],
                                    library_dirs=['lib'],
                                    )
    )
)
