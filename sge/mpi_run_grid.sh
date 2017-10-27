# call:  mpi_run_grid.sh rate pp cores divisions_outer letter branch_name
# call:  mpi_run_grid.sh $1   $2 $3    $4              $5	  $6
# eg: sh mpi_run_grid.sh 646 999 2 13 a fixed_cq_gradients

# pick a name for a directory somewhere on the cluster storage

directory=/data/corpora/sge2/pol/joerod/plat/results/$6_$4_$5/$1_$2

mkdir -p $directory # make the directory if it doesn't exist yet
cd $directory # go there

# clone the specified branch of the repository to that directory 
git clone --recursive -b $6 git@github.com:joerodd/DBS_CQ.git

cd DBS_CQ # enter the directory
commit="$(git rev-parse --short=8 HEAD)" # find out what the hash is of the commit that got cloned
cd .. # return to the directory above

python3 DBS_CQ/platypus_test.py $1 $2 $3 $4 $5 $commit # run the script and pass it arguments, including the hash of the commit so that this can be recoreded in the output
