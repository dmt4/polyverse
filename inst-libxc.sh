#!/bin/bash

name="libxc"
# vers="svn-r11695"
vers="2.2.2"

. conf.sh
. funs.sh

sfx=("intel/14.0.1/o" "intel/14.0.1/d" "intel/15.0.4/o" "intel/15.0.4/d" "intel/16.0.0/o" "intel/16.0.0/d"  "gcc/5.2.0/o" "gcc/5.2.0/d" "gcc/5.3.0/o" "gcc/5.3.0/d")

dnlifnh "http://www.tddft.org/programs/octopus/down.php?file=libxc/libxc-${vers}.tar.gz"
# [ -d $name ] || svn co http://www.tddft.org/svn/octopus/trunk/libxc


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
conflict          d/$name

module load $co/$cv

set               main_root            $prefx
setenv            LIBXCPATH            \$main_root

prepend-path      INCLUDE              \$main_root/include

prepend-path      LIBRARY_PATH         \$main_root/lib
prepend-path      LD_LIBRARY_PATH      \$main_root/lib
prepend-path      LD_RUN_PATH          \$main_root/lib

prepend-path      LIBRARY_PATH         \$main_root/lib64
prepend-path      LD_LIBRARY_PATH      \$main_root/lib64
prepend-path      LD_RUN_PATH          \$main_root/lib64
" > $mpath

    module load $co/$cv ${mpref[$st]}$mname

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

    module unload $co/$cv ${mpref[$st]}$mname
    popd
done


wait

module unload debug

echo "All done! Remember to clean up ${bldrt} yourself.."


