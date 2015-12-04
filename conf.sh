
j=$(lscpu -p | grep -v '#' | wc -l)

dst='/opt'
mds="${dst}/modules"
tmp='/tmp'

declare -A sp
sp['d']='.d/'

declare -A cc cxx fc flags
cc['intel']='icc'
cxx['intel']='icpc'
fc['intel']='ifort'
flags['intel/o']='-O3 -xHost'
# flags['intel/o']='-O3 -xAVX'
flags['intel/d']='-O0 -g'

cc['gcc']='gcc'
cxx['gcc']='g++'
fc['gcc']='gfortran'
flags['gcc/o']='-O3 -march=native'
flags['gcc/d']='-O0 -g'

declare -A stil
stil['o']='optimised'
stil['d']='debugging'

declare -A mpref
mpref['o']=''
mpref['d']='d/'


cwd=$(pwd)

mname="${name}/${vers}"
prefx="${dst}/${mname}"
mpath="${mds}/${mname}"
bldrt="${tmp}/${mname}"
