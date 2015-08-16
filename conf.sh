
j=4

dst='/opt'
mds="${dst}/modules"
tmp='/tmp'

declare -A cc cxx fc flags
cc['intel']='icc'
cxx['intel']='icpc'
fc['intel']='ifort'
flags['intel/o']='-O3 -xHost'
flags['intel/d']='-O0 -g'

cc['gcc']='gcc'
cxx['gcc']='g++'
fc['gcc']='gfortran'
flags['gcc/o']='-O3 -march=native'
flags['gcc/d']='-O0 -g'

declare -A stil
stil['o']='optimised'
stil['d']='debugging'

cwd=$(pwd)

mname="${name}/${vers}"
prefx="${dst}/${mname}"
mpath="${mds}/${mname}"
bldrt="${tmp}/${mname}"
