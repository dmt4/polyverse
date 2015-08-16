#!/bin/bash

name="openmpi"
# vers="1.6.5"
# vers="1.7.3"
# vers="1.8.1"
vers="1.8.8"

. conf.sh
. funs.sh

sfx=("intel/15.0.2/o" "intel/15.0.2/d" "gcc/5.2.0/o" "gcc/5.2.0/d")

declare -A confflags
confflags['d']="--enable-debug --enable-mem-debug --enable-mem-profile --enable-memchecker"

dnlifnh http://www.open-mpi.org/software/ompi/v${vers%.*}/downloads/openmpi-${vers}.tar.bz2

rm -rf $bldrt
mkdir -p $bldrt
pushd $bldrt
tar -xf ${cwd}/${name}-${vers}.tar.bz2
pushd ${name}-${vers}

for i in  0 1 2 3
do
    co=${sfx[i]%%/*}    # compiler
    cv=${sfx[i]%/*}     # compiler/version
    st=${sfx[i]#${cv}/} # style: o or d
    cs=${co}/${st}      # compiler/style

    mname="${name}/${vers}/${sfx[i]}"
    prefx="${dst}/${mname}"
    mpath="${mds}/${mname}"

    mkdir -p $(dirname $mpath)


    echo "#%Module -*- tcl -*-
##
## modulefile
##

proc ModulesHelp { } {
  global describe
  puts stderr describe
}

set describe \"${stil[$st]} ${name} v${vers} compiled with $co v${cv#${co}/}\"

module-whatis     \$describe

conflict          $name
conflict          mpich
conflict          mpich2
conflict          mvapich
conflict          mvapich2
conflict          intelmpi


if {![is-loaded $cv]} then {
  puts stderr \"loading prerequisite module $cv\"
  module load $cv
}

set               main_root            $prefx

prepend-path      PATH                 \$main_root/bin
prepend-path      PATH                 \$main_root/sbin

prepend-path      INCLUDE              \$main_root/include

prepend-path      MANPATH              \$main_root/share/man

prepend-path      LIBRARY_PATH         \$main_root/lib
prepend-path      LD_LIBRARY_PATH      \$main_root/lib
#prepend-path      LD_RUN_PATH          \$main_root/lib

prepend-path      LIBRARY_PATH         \$main_root/lib64
prepend-path      LD_LIBRARY_PATH      \$main_root/lib64
#prepend-path      LD_RUN_PATH          \$main_root/lib64
" > $mpath

    module load $cv $mname

    bld=${sfx[i]}
    rm -rf $bld
    mkdir -p $bld
    pushd $bld


    echo ${bldrt}/${name}-${vers}/configure --prefix=$prefx  \
        --disable-vt --with-pmi --enable-mpi-interface-warning \
        --enable-static --disable-java --enable-mpi-ext=all ${confflags[$st]} \
        CC="${cc[$co]}"   CFLAGS="${flags[$cs]}" \
        CXX="${cxx[$co]}" CXXFLAGS="${flags[$cs]}" \
        FC="${fc[$co]}"   FCFLAGS="${flags[$cs]}"

    ${bldrt}/${name}-${vers}/configure --prefix=$prefx  \
        --disable-vt --with-pmi --enable-mpi-interface-warning \
        --enable-static --disable-java --enable-mpi-ext=all ${confflags[$st]} \
        CC="${cc[$co]}"   CFLAGS="${flags[$cs]}" \
        CXX="${cxx[$co]}" CXXFLAGS="${flags[$cs]}" \
        FC="${fc[$co]}"   FCFLAGS="${flags[$cs]}"


    make -j$j
    make install



# --with-cuda=${CUDADIR}
# --enable-mpi-interface-warning --enable-debug --enable-mem-debug --enable-mem-profile


    module unload $cv $mname

    popd
    rm -rf $bld
done


wait


echo "All done! Remember to clean up ${bldrt} yourself.."


