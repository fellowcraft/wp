from scipy.stats import norm

# Process parameters

delta = 0.25
dt = 0.1

# Initial condition.
x = 0.0

# Number of iterations to compute.
n = 20

# Iterate to compute the steps of the Brownian motion.
for k in range(n):
	x = x + norm.rvs(scale=delta**2*dt)
	print x
