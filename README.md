# gMultiwfn
*The (unofficial) gfortran port of Multiwfn*

## About
gMultiwfn is an unofficial and (maybe) enhanced gfortran port of the popular wavefunction analyzing software [Multiwfn](http://sobereva.com/multiwfn) developed by Tian Lu. This gfortran port is maintained by Xing Yin (stecue@gmail.com). Email Xing or [open an issue on the github](https://github.com/stecue/gMultiwfn/issues) (__*strongly preferred!*__) on the github if you find a bug or need a new additional feature.

## Installation
RPM builds for openSUSE, Fedora and CentOS will be released soon. Please follow the following steps to install from the source for now.

### Download the package
The source tarball can be found [here](https://github.com/stecue/gMultiwfn/releases). 

### Compile from source
`gMultiwfn` uses the standard [GNU Build System](https://en.wikipedia.org/wiki/GNU_Build_System). If you are familiar with `./configure` and `make && make install`, building gMultiwfn is very easy. The following steps sevre as a general guideline and you can make changes accordingly if you are an expert on GNU autotools or have special needs.

#### Requirements
* You can use either Intel Fortran Compiler (`ifort`) or `gfortran`.
* If you choose `ifort`, make sure Intel Math Kernel Library (Intel MKL) is installed. If not sure, you can just try to continue building first because MKL is usually bundled and installed with `ifort` by default.
* If you choose `gfortran`, make sure you have lapack/blas and their development files (usually named as `lapack-devel` and `blas-devel` *or* `lapack-dev` and `blas-dev` in your distro's repository) installed. The optimized LAPACK/BLAS implementations (see below) will not be searched and used by the `configure` script during building.

#### Basic build procedure
1. Open a terminal and go to the directory where the tarball is downloaded, or move the tarball to your current directory.
2. Unzip and extract files from the source tarball. If the name of the tarball is `gMultiwfn-3.3.9-1.tar.gz`, the command would be:
```
tar -xvzf gMultiwfn-3.3.9-0.tar.gz
```
The recommended way to build `gMultiwfn` is to use a separate source and build directory.
3. Make a separate build direcotry under the original "root" source directory:
```
cd gMultiwfn-3.3.9-0
mkdir build
```

## Switch to a faster lapack/blas implementation
`gMultiwfn` is dynamically linked to `lapack` and `blas` by default. The reference implementations of `lapack` and `blas` are usually the slowest and in a lot of cases they can be safely replaced by optimized implementations such as `OpenBLAS` and `ATLAS` using the steps descripted below. Note that installing OpenBLAS or ATLAS is beyond the scope of this document and please refer to your distro's manual on that information. It is also widely believed that the Intel MKL is the fastest LAPACK/BLAS implenmentation on Intel CPUs and you can switch to it for gMultiwfn in a similar way if it is available on your system.

### Use `update-alternatives` to make a system-wide change
### Use `LD_PRELOAD` to change just for `gMultiwfn`
`LD_PRELOAD` is the enviroment variable to force the dynamic linker in Linux to use a certain version of shared libraries (.so files).
`LD_PRELOAD=/path/to/libopenblas.so Multiwfn` and add the following line to your bash initialization file (usually `~/.bashrc`). `alias gMultiwfn=LD_PRELOAD=/path/to/libopenblas.so Multiwfn`

## (Must Read) Differences between Multiwfn and gMultiwfn
