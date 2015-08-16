#!/bin/bash

name="libxc"
# vers="svn-r11695"
vers="2.2.2"

. conf.sh
. funs.sh

sfx=("intel/15.0.2/o" "intel/15.0.2/d" "gcc/5.2.0/o" "gcc/5.2.0/d")

dnlifnh "http://www.tddft.org/programs/octopus/down.php?file=libxc/libxc-${vers}.tar.gz"
# [ -d $name ] || svn co http://www.tddft.org/svn/octopus/trunk/libxc

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

if {![is-loaded $cv]} then {
  puts stderr \"loading prerequisite module $cv\"
  module load $cv
}

set               main_root            $prefx
setenv            LIBXCPATH            \$main_root

prepend-path      INCLUDE              \$main_root/include

prepend-path      LIBRARY_PATH         \$main_root/lib
prepend-path      LD_LIBRARY_PATH      \$main_root/lib
#prepend-path      LD_RUN_PATH          \$main_root/lib

prepend-path      LIBRARY_PATH         \$main_root/lib64
prepend-path      LD_LIBRARY_PATH      \$main_root/lib64
#prepend-path      LD_RUN_PATH          \$main_root/lib64
" > $mpath

    module load $cv $mname

    bld=${bldrt}/${sfx[i]}
    rm -rf $bld
    mkdir -p $bld
    pushd $bld

    tar -xf ${cwd}/${name}-${vers}.tar.gz
    pushd ${name}-${vers}

#    cp -av ${cwd}/${name} ./
#    cd ${name}
#    autoreconf -i &&

    ./configure --prefix=$prefx  \
        CC="${cc[$co]}"   CFLAGS="${flags[$cs]}" \
        CXX="${cxx[$co]}" CXXFLAGS="${flags[$cs]}" \
        F77="${fc[$co]}"  FFLAGS="${flags[$cs]}" \
        FC="${fc[$co]}"   FCFLAGS="${flags[$cs]}" \
        && make -j$j && make install &

    module unload $cv $mname
    popd
done


wait

echo "All done! Remember to clean up ${bldrt} yourself.."


