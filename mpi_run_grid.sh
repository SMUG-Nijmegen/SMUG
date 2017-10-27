# call:  mpi_run_grid.sh rate pp cores divisions_outer letter branch_name
# call:  mpi_run_grid.sh $1   $2 $3    $4              $5	  $6
# eg: sh mpi_run_grid.sh 646 999 2 13 a fixed_cq_gradients

directory=/data/corpora/sge2/pol/joerod/plat/results/$6_$4_$5/$1_$2


echo $directory

mkdir -p $directory
cd $directory

git clone --recursive -b $6 git@github.com:joerodd/DBS_CQ.git
cd DBS_CQ
commit="$(git rev-parse --short=8 HEAD)"
cd ..

python3 DBS_CQ/platypus_test.py $1 $2 $3 $4 $5 $commit
