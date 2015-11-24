This folder contains scripts for processing data.

# Center of Gravity

Prints the center of gravity (COG) of the front-most image. By default, it prints the center of gravity in calibrated coordinates (if available). If you switch off the display of the calibration, output will be in pixels. If you have a rectangular ROI, the COG will be calculated only within the ROI (but still will be printed in image coordinates).

Currently only works for 1D and 2D data-sets.

# Find Maxima

Identifies peaks in the front-most image based on a maximum filter (i.e. it currently does not perform local peak fitting). Returns a mask image that is 1 for pixels that are maximal in their surrounding and 0 otherwise.

Currently only works for 1D and 2D data-sets. Does not work properly for images that contain constant areas (they will all be identified as maxima).

# Gaussian filter

Applies a Gaussian filter with specified x and y radius to the front-most image. Filtering is performed in Fourier space.

Currently only works for 1D and 2D data-sets and not for the data-type complex.

