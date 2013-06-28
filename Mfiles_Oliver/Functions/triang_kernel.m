%triangle_kernel function
%function triang_vec=triang_kernel(sigma)
function triang_vec=triang_kernel(sigma)

time_vec=(-sqrt(6)*sigma):(sqrt(6)*sigma);

triang_vec=1/(6*sigma^2)*(sqrt(6)*sigma-abs(time_vec));
