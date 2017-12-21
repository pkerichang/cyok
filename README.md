# cyok
This is a Python wrapper to the C++ API of Opal Kelly FrontPanel SDK, written with Cython.

This project started because at the time of development Opal Kelly does not support Python 3 on Macs,
so I decide to write my own Python wrapper.

## Disclaimer
This project is not compatible with the Opal Kelly Python API, and I do not intended to change that,
as how data trasfer between Python and C++ is done is fundamentally different.  This is
also not a complete wrapper in the sense that not all features are implemented, and I will only add
more support if I need them.  I'm just a graduate student trying to make a paper deadline.
However, Cython is very simple, so feel free to fork and play with it, then submit pull requests if
you want to contribute.

## Installation Requirements
1. Any version of Python that supports the following Cython version.
2. Cython 0.26.1 or later (This is what comes with Anaconda.
   It should theoretically work for 0.20 or later).
3. A C++ compiler (I use clang on Mac).

## Installation Instructions
1. clone the repo.

2. put file/symlink to okFrontPanelDLL.h in include folder.

3. put file/symlink to okFrontPanel dynamic library file
   (libokFrontPanel.dylib/libokFrontPanel.so/okFrontPanel.dll, depending on operating system)
   in lib folder.

4. run:

   ${PYTHON} setup.py build

   where ${PYTHON} is the Python executable that contains the Cython installation.  This will
   generate the wrapper .cpp file and create a shared object file in build folder.


## Testing
1. In your working directory, put a symlink to the built shared object file and the okFrontPanel
   dynamic library file.

2. copy test/test_cyok.py to your working directory, and edit the FPGA bit file location.

3. run the script, hopefully it works.


