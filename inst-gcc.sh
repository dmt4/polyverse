#!/bin/bash

name=gcc
vers=5.2.0


. conf.sh
. funs.sh

dnlifnh ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-${vers}/gcc-${vers}.tar.bz2
dnlifnh https://gmplib.org/download/gmp/gmp-6.0.0a.tar.bz2
dnlifnh http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.bz2
dnlifnh ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
dnlifnh http://isl.gforge.inria.fr/isl-0.14.tar.bz2 # isl 0.15 breaks gcc 5.2.0


mkdir -p $(dirname $mpath)

echo "#%Module -*- tcl -*-
##
## modulefile
##

proc ModulesHelp { } {
  global describe
  puts stderr describe
}

set describe \"$name v$vers\"

module-whatis    \$describe

conflict         $name

set              main_root            $prefx

prepend-path     PATH                 \$main_root/bin

prepend-path     LIBRARY_PATH         \$main_root/lib
prepend-path     LIBRARY_PATH         \$main_root/lib64

prepend-path     LD_LIBRARY_PATH      \$main_root/lib
prepend-path     LD_LIBRARY_PATH      \$main_root/lib64


#prepend-path     LD_RUN_PATH          \$main_root/lib
#prepend-path     LD_RUN_PATH          \$main_root/lib64

prepend-path      PKG_CONFIG_PATH      \$main_root/lib/pkgconfig
prepend-path      PKG_CONFIG_PATH      \$main_root/lib64/pkgconfig

prepend-path      INCLUDE              \$main_root/include

prepend-path      MANPATH              \$main_root/man
prepend-path      MANPATH              \$main_root/share/man
" > $mpath

module load $mname



rm -rf $bldrt
mkdir -p $bldrt
pushd $bldrt
tar -xf ${cwd}/gcc-${vers}.tar.bz2
pushd gcc-${vers}

# contrib/download_prerequisites
tar -xf ${cwd}/gmp-6.0.0a.tar.bz2 && ln -s gmp-6.0.0 gmp
tar -xf ${cwd}/mpfr-3.1.3.tar.bz2 && ln -s mpfr-3.1.3 mpfr
tar -xf ${cwd}/mpc-1.0.3.tar.gz && ln -s mpc-1.0.3 mpc
tar -xf ${cwd}/isl-0.14.tar.bz2 && ln -s isl-0.14 isl

function instlib {
    rm -rf bld && mkdir -p bld && pushd bld
    $*
    make -j$j && make install && popd
}

instlib ../gmp/configure --prefix=$prefx
instlib ../mpfr/configure --prefix=$prefx --with-gmp=$prefx
instlib ../mpc/configure --prefix=$prefx --with-gmp=$prefx --with-mpfr=$prefx
instlib ../isl/configure --prefix=$prefx --with-int=gmp --with-gmp-prefix=$prefx


rm -rf gmp* mpfr* mpc* isl*

rm -rf bld && mkdir -p bld && pushd bld
../configure --prefix=$prefx --enable-languages=c,c++,fortran  \
            --with-gmp=$prefx --with-mpfr=$prefx --with-mpc=$prefx --with-isl=$prefx \
            --enable-ssp --disable-libssp --disable-libvtv --disable-plugin --disable-nls --without-system-libunwind \
            --disable-multilib --disable-libgcj --disable-libstdcxx-pch --disable-libunwind-exceptions \
            --enable-libmpx --enable-lto --enable-__cxa_atexit --enable-libstdcxx-allocator=new \
            --enable-threads=posix --enable-linker-build-id --enable-linux-futex \
            --build=x86_64-dmt-linux --host=x86_64-dmt-linux --with-bugurl=https://github.com/dmt4 --with-pkgversion='DMT'


make BOOT_CFLAGS='-O' bootstrap -j$j
make install

module unload $mname


echo "All done! Remember to clean up ${bldrt} yourself.."


