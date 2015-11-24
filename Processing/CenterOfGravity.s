/******************************************************************************
	Center of Gravity

	Prints the center of gravity (COG) of the front-most image. By default, it
	prints the center of gravity in calibrated coordinates (if available). If
	you switch off the display of the calibration, output will be in pixels. If
	you have a rectangular ROI, the COG will be calculated only within the ROI
	(but still will be printed in image coordinates).

	Copyright (c) 2015  Stefan Löffler

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/

// Currently only works for 1D and 2D data-sets.

image src := GetFrontImage(); // image to operate on
number dim = src.ImageGetNumDimensions(); // number of dimensions of the image
number w, h; // width and height of the image
number x0, y0, dx, dy; // calibration info of the image
number x1, x2, y1, y2; // ROI coordinates
string xunit, yunit; // units
ROI r;

if (dim == 1) {
	// Get calibration info
	src.ImageGetDimensionCalibration(0, x0, dx, xunit, 1);

	// If the calibration display is switched off, we should work in pixels
	if (!src.ImageIsDimensionCalibrationDisplayed(0)) {
		x0 = 0;
		dx = 1;
		xunit = "";
	}

	// Pad unit string with a space on the left for nicer output
	if (xunit != "") xunit = " " + xunit;

	// Get the primary (i.e., single selected) ROI if it exists
	r = src.ImageGetImageDisplay(0).ImageDisplayGetPrimaryROI();
	if (r.ROIIsValid()) {
		if (r.ROIIsRange()) {
			// There is a valid range ROI, so we calculate the COG inside the ROI
			// This means we get values relative to the ROI's beginning, which we have to compensate for
			r.ROIGetRange(x1, x2);
			x0 -= x1;
			// Calculate the COG
			number norm = sum(src[]);
			result("Center of gravity for the ROI in \"" + src.ImageGetLabel() + ": " + src.ImageGetName() + "\": " + (sum(src[] * icol) / norm - x0) * dx + xunit + "\n");
			exit(0);
		}
	}

	number norm = sum(src);
	result("Center of gravity for \"" + src.ImageGetLabel() + ": " + src.ImageGetName() + "\": " + (sum(src * icol) / norm - x0) * dx + " " + xunit + "\n");
}
else if (dim == 2) {
	// Get calibration info
	src.ImageGetDimensionCalibration(0, x0, dx, xunit, 1);
	src.ImageGetDimensionCalibration(1, y0, dy, yunit, 1);

	// If the calibration display is switched off, we should work in pixels
	if (!src.ImageIsDimensionCalibrationDisplayed(0)) {
		x0 = 0;
		dx = 1;
		xunit = "";
	}
	if (!src.ImageIsDimensionCalibrationDisplayed(1)) {
		y0 = 0;
		dy = 1;
		yunit = "";
	}

	// Pad unit strings with a space on the left for nicer output
	if (xunit != "") xunit = " " + xunit;
	if (yunit != "") yunit = " " + yunit;

	// Get the primary (i.e., single selected) ROI if it exists
	r = src.ImageGetImageDisplay(0).ImageDisplayGetPrimaryROI();
	if (r.ROIIsValid()) {
		if (r.ROIIsRectangle()) {
			// There is a valid rectangle ROI, so we calculate the COG inside the ROI
			// This means we get values relative to the ROI's top-left corner, which we have to compensate for
			r.ROIGetRectangle(y1, x1, y2, x2);
			x0 -= x1;
			y0 -= y1;
			// Calculate the COG
			number norm = sum(src[]);
			result("Center of gravity for the ROI in \"" + src.ImageGetLabel() + ": " + src.ImageGetName() + "\": (" + (sum(src[] * icol) / norm - x0) * dx + xunit + ", " + (sum(src[] * irow) / norm - y0) * dy + yunit + ")\n");
			exit(0);
		}
	}

	number norm = sum(src);
	result("Center of gravity for \"" + src.ImageGetLabel() + ": " + src.ImageGetName() + "\": (" + (sum(src * icol) / norm - x0) * dx + xunit + ", " + (sum(src * irow) / norm - y0) * dy + yunit + ")\n");

}
else {
	OKDialog("" + dim + "D images are not supported");
}

