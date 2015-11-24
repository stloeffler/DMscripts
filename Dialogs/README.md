This folder contains scripts that provide dialogs, palette windows and similar UI elements.

# Array Mask Editor

An editor for array masks (usually used for masking lattice spots in diffraction patterns). To use, select an array mask and click "Assign". It will give you three circles. Move the green one to change the center of the mask (this changes the calibration offset of the image). Use the red and blue circles to fine-position the mask. Use the "Order" buttons in the dialog window to change the diffraction order to which the red and blue circles correspond (e.g., change it to 2 or 3 to move the circle to the second or third order reflection, e.g., from the (111) spot to the (222) or the (333) spot for increased accuracy). Also displayed are the lengths and angles of the reciprocal lattice vectors, as well as their length ratio and the angle between them to aid the indexing of diffraction patterns.

# Math Palette

Provides a palette window to quickly perform simple mathematical operations on open images. Includes most operations that are available from the Process > Simple Math menu command, but also several operations on complex images (such as extracting real and imaginary part, the absolute value, or the phase) and allows cropping of images. It also enabled quick access to basic information about the image (such as minimum, maximum, mean value, etc.) and therefore brings operations such as "subtract minimum" or "divide by maximum" down to two clicks.

The image drop-down lists are always kept up to date with the current image order, with "a" being the front-most image and "b" being the one directly behind in the image order. This means that by clicking on images, you can quickly change on which images the operations work.

To install, click File > Install Script File..., select MathPalette.s, choose "Library", and click "OK". You can subsequently access the palette from Window > Floating Windows > Math.

