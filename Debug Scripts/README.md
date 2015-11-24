This directory contains scripts I use for writing, debugging, and analyzing scripts and script outputs. They are probably not too useful for the "average user".

# List Annotations

This script lists all components (including what's called "Annotations" in the UI) of the front image document and prints them into the result window. Also printed are the properties of the respective components.

The term "components" includes information about the image document, the image displays, annotations (such as lines, text, scale markers, etc.) and masks (such as spot mask, array masks, etc.). It does not include images (i.e., the image data itself) or regions of interest - those are treated differently in DM.

ListAnnotations.s should work for GMS 2 and later and prints all properties of the components. ListAnnotations_1-6.s works in GMS 1.6 and only includes some properties.

# List ROIs

This script lists all regions of interest (ROIs) in the front-most image, together with their properties, and prints them into the result window.

# List Tags

This script lists either all global tags (also accessible from the File menu) or all tags of the front-most image (also accessible from the context menu).

# ROI Editor

This script provides a small dialog that allows to display and edit the properties of ROIs. To use, run the script, select a ROI in an image, and press "Assign ROI" in the dialog.

