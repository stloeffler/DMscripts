/******************************************************************************
	Find Maxima

	Identifies peaks in the front-most image based on a maximum filter (i.e. it
	currently does not perform local peak fitting). Returns a mask image that
	is 1 for pixels that are maximal in their surrounding and 0 otherwise.

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
// Does not work properly for images that contain constant areas (they will all be identified as maxima).

// Marks all pixels that are equal to the maximum of their local surrounding
// kernelType ... 0=horizontal, 1=vertical, 2=cross, 3=entire
image MaximumFilter(image & src, number kernelType, number size) {
	image retVal = src.ImageClone();

	// The largest size supported by the built-in routine is 5, corresponding to an 11x11 window
	// Since max(a, b, c) = max(a, max(b, c)) we can iterate the maximum filter until we get
	// to the requested size
	while (size > 5) {
		retVal = RankFilter(retVal, 2, kernelType, 5);
		size -= 5;
	}
	return RankFilter(retVal, 2, kernelType, size);
}

// Pad an image by the given numbers of pixels on each side
// mode = 0: pad with parameter val
// mode = 1: pad with closest pixel
image ImagePadBy(image src, number top, number left, number bottom, number right, number mode, number val) {
	number w, h;
	image retVal;

	src.GetSize(w, h);
	retVal = ExprSize(w + left + right, h + top + bottom, val);

	if (mode == 0)
		retVal[top, left, h + top, w + left] = src;
	if (mode == 1)
		retVal = src[clip(icol, left, left + w - 1) - left, clip(irow, top, top + h - 1) - top];

	return retVal;
}



image src := GetFrontImage();
image mask;
number lengthScale;

// Safety check
if (src.ImageGetNumDimensions() > 2) {
	OKDialog("Only 1D and 2D images are supported");
	exit(0);
}

// User input
if (!GetNumber("Minimal feature separation (px):", 5, lengthScale)) exit(0);


if (src.ImageGetNumDimensions() == 1) {
	// 0 ... only horizontal
	mask = (src == src.MaximumFilter(0, lengthScale));
	// The maximum filter does not affect the boundary pixels so we zero them manually
	mask = (icol < lengthScale || icol >= iwidth - lengthScale ? 0 : mask[icol, irow]);

	mask.ShowImage();
}
else {
	// In 2D, we assume the worst-case scenario: two features that are connected by a 45deg line
	// In the maximum norm used here, a the set of all equidistant points of a center form a square.
	// So we have to find the smallest (axis parallel) square that fits into the circle with radius = lengthScale
	lengthScale /= sqrt(2);

	// 3 ... entire surrounding
	mask = (src == src.MaximumFilter(3, lengthScale));
	// The maximum filter does not affect the boundary pixels so we zero them manually
	mask = (icol < lengthScale || irow < lengthScale || icol >= iwidth - lengthScale || irow >= iheight - lengthScale ? 0 : mask[icol, irow]);

	mask.ShowImage();

	// If only a few pixels are 1 (i.e. maxima), the default contrast limits will be such that we don't see the points
	// So we compensate for it manually, knowing the dynamic range of the image
	mask.ImageGetImageDisplay(0).ImageDisplaySetContrastLimits(0, 1);
}

