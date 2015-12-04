#!/bin/bash

name="openmpi"
# vers="1.6.5"
# vers="1.7.3"
# vers="1.8.1"
# vers="1.8.4"
# vers="1.8.8"
# vers="1.10.0"
# vers="1.10.1rc1"
vers="1.10.1"


. conf.sh
. funs.sh

#sfx=("intel/15.0.4/o" "intel/15.0.4/d" "intel/16.0.0/o" "intel/16.0.0/d"  "gcc/5.2.0/o" "gcc/5.2.0/d")
#sfx=("intel/15.0.4/o" "intel/15.0.4/d")
sfx=("intel/14.0.1/o" "intel/14.0.1/d" "intel/15.0.4/o" "intel/15.0.4/d" "intel/16.0.0/o"  "intel/16.0.0/d" "gcc/5.2.0/o" "gcc/5.2.0/d" "gcc/5.3.0/o" "gcc/5.3.0/d")

declare -A confflags
confflags['d']="--enable-debug --enable-mem-debug --enable-mem-profile --enable-memchecker"

dnlifnh http://www.open-mpi.org/software/ompi/v${vers%.*}/downloads/openmpi-${vers}.tar.bz2

rm -rf $bldrt
mkdir -p $bldrt
pushd $bldrt
tar -xf ${cwd}/${name}-${vers}.tar.bz2
pushd ${name}-${vers}


module load debug

for i in  0 1 2 3 4 5 6 7 8 9
do
    echo

    # compiler
    co=${sfx[i]%%/*}

    # compiler version
    cv=${sfx[i]#${co}/}
    cv=${cv%%/*}

    # style: o or d
    st=${sfx[i]#${co}/${cv}}
    st=${st#/}

    cs="${co}/${st}"

    mname="${name}/${vers}/${co}/${cv}"
    prefx="${dst}/${mname}/${st}"
    mpath="${mds}/${st}/${mname}"


    echo co $co
    echo cv $cv
    echo st $st

    echo mname $mname
    echo prefx $prefx
    echo mpath $mpath

    mkdir -p $(dirname $mpath)


    echo "#%Module -*- tcl -*-
##
## modulefile
##

proc ModulesHelp { } {
  global describe
  puts stderr describe
}

set describe \"${stil[$st]} ${name} v${vers} compiled with $co v${cv}\"

module-whatis     \$describe

conflict          $name
conflict          mpich
conflict          mpich2
conflict          mvapich
conflict          mvapich2
conflict          impi

conflict          d/$name
conflict          d/mpich
conflict          d/mpich2
conflict          d/mvapich
conflict          d/mvapich2
conflict          d/impi


module load $co/$cv

set               main_root            $prefx

prepend-path      PATH                 \$main_root/bin
prepend-path      PATH                 \$main_root/sbin

prepend-path      INCLUDE              \$main_root/include

prepend-path      MANPATH              \$main_root/share/man

prepend-path      LIBRARY_PATH         \$main_root/lib
prepend-path      LD_LIBRARY_PATH      \$main_root/lib
prepend-path      LD_RUN_PATH          \$main_root/lib

prepend-path      LIBRARY_PATH         \$main_root/lib64
prepend-path      LD_LIBRARY_PATH      \$main_root/lib64
prepend-path      LD_RUN_PATH          \$main_root/lib64
" > $mpath

    module load $co/$cv ${mpref[$st]}$mname

    bld=${sfx[i]}
    rm -rf $bld
    mkdir -p $bld
    pushd $bld


    echo ${bldrt}/${name}-${vers}/configure --prefix=$prefx  \
        --disable-vt --without-pmi --enable-mpi-interface-warning --disable-wrapper-rpath \
        --enable-static --disable-java --enable-mpi-ext=all ${confflags[${st}]} \
        CC="${cc[$co]}"   CFLAGS="${flags[$cs]}" \
        CXX="${cxx[$co]}" CXXFLAGS="${flags[$cs]}" \
        FC="${fc[$co]}"   FCFLAGS="${flags[$cs]}"

    ${bldrt}/${name}-${vers}/configure --prefix=$prefx  \
        --disable-vt --without-pmi --enable-mpi-interface-warning --disable-wrapper-rpath \
        --enable-static --disable-java --enable-mpi-ext=all ${confflags[${st}]} \
        CC="${cc[$co]}"   CFLAGS="${flags[$cs]}" \
        CXX="${cxx[$co]}" CXXFLAGS="${flags[$cs]}" \
        FC="${fc[$co]}"   FCFLAGS="${flags[$cs]}"


    make -j$j
    make install

# --with-cuda=${CUDADIR}
# --enable-mpi-interface-warning --enable-debug --enable-mem-debug --enable-mem-profile


    module unload $co/$cv ${mpref[$st]}$mname

    popd
    rm -rf $bld
done


wait

module unload debug

echo "All done! Remember to clean up ${bldrt} yourself.."


