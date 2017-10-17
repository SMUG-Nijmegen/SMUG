"""Python offers multiple ways of parallelizing operations, both built-in modules (threading, multiprocessing)
and external modules that extend the built-in modules or make them easier to use (e.g. joblib)
this little script demonstrates how to execute computations in parallel using the joblib module
if you do not have joblib installed, install it first by 'running pip install joblib --user'
"""

from joblib import Parallel, delayed  # import what we need from joblib
import numpy as np  # I always import numpy, because I always need it
from time import time  # import timer so we can check if parallelizing speeds up our computation

#numbers = np.random.random(1000000)  # generate a million random numbers to perform our computation on
numbers = range(1000000)  # generate a million sequential integers to perform our computation on

# specify a function we will parallelize with joblib
# you can make it do whatever you want, as long as you pass everything you need as function arguments
def f(x):
    return np.sqrt(x)  # return the square root of x


def f_parallel(x, n_workers):
    #x_parallel = np.reshape(x, (n_workers, -1))  # reshape our data into chunks, one for each worker
    n = len(x)
    x_parallel = [x[i:i + (n / 10)] for i in xrange(0, n, (n / 10))]
    results_parallel = Parallel(n_jobs=n_workers)(delayed(f)(chunk) for chunk in x_parallel)  # send jobs to workers
    # note that the n_jobs argument of Parallel() gives the number of processes that will be spawned
    # while delayed() takes the name of the function we want to apply as an argument
    # followed by whatever we want to pass as argument to that function (in our case, a chunk of the data)
    return np.vstack(results_parallel)  # stack the results back into a single numpy array and return them

t0 = time()
squares = f(numbers)  # execute the function 'normally'
t1 = time()
squares_parallel = f_parallel(numbers, 10)  # now execute it in parallel on 10 workers
t2 = time()
duration = t1 - t0
duration_parallel = t2 - t1

print('Are the parallel and serial sums the same: ' + str(np.sum(squares_parallel) == np.sum(squares)))
print('Computing normally took: ' + str(duration))
print('Computing in parallel took: ' + str(duration_parallel))
# checking which of the two methods is faster takes a bit more code, but it's really easy
