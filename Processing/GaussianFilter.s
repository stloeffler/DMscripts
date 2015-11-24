/******************************************************************************
	Gaussian filter

	Applies a Gaussian filter with specified x and y radius to the front-most
	image. Filtering is performed in Fourier space.

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

// Currently only works for 1D and 2D data-sets and not for the data-type complex.

void ImageCopyMetaDataFrom(image & dest, image & src, string suffix) {
	dest.ImageGetTagGroup().TagGroupCopyTagsFrom(src.ImageGetTagGroup());
	dest.ImageCopyCalibrationFrom(src);
	if (suffix != "") {
		dest.ImageSetName(src.ImageGetName() + " " + suffix);
	}
}

// Return the smallest n such that 2**n >= orig
number powerOfTwo(number orig) {
	return 2 ** ceil(log2(orig));
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

number wOrig, hOrig, w, h; // width & height of the original image as well as the intermediate (padded) images
number rx = 5; // radius of horizontal blurring (in px)
number ry = 5; // radius of vertical blurring (in px)
number padL, padR, padT, padB;

compleximage fourier; // FFT of the image
image filter; // Gaussian filter to apply in Fourier space
image result; // image to produce

// Get the image to operate on
image src := GetFrontImage();

if (ImageDataTypeIsComplex(src.ImageGetDataType())) {
	OKDialog("Complex images are not supported");
	exit(1);
}

// Get the image size
src.GetSize(wOrig, hOrig);

// Ask the user how much to blur
if (!GetNumber("Number of pixels to blur horizontally:", 5, rx)) exit(0);
if (src.ImageGetNumDimensions() == 1) {
	// For 1D images, there is no point to ask for vertical blurring
	ry = 0;
}
else {
	if (!GetNumber("Number of pixels to blur vertically:", rx, ry)) exit(0);
}

// Calculate the size of the intermediate images
// They should be powers of two (to allow for a simple FFT) and have some padding to minimize boundary effects
w = powerOfTwo(wOrig + 2 * ceil(rx));
h = powerOfTwo(hOrig + 2 * ceil(ry));

// Calculate required padding
padL = floor((w - wOrig) / 2);
padR = ceil((w - wOrig) / 2);
padT = floor((h - hOrig) / 2);
padB = ceil((h - hOrig) / 2);

// Pad the image and fourier-transform it
fourier = src.ImagePadBy(padT, padL, padB, padR, 1, 0).RealFFT();

// Construct the Gaussian filter (in Fourier space)
if (src.ImageGetNumDimensions() == 1) {
	filter = ExprSize(w, exp(-((icol - w / 2)**2 * (2 * Pi() * rx / w) ** 2) / 2));
}
else {
	filter = ExprSize(w, h, exp(-((icol - w / 2)**2 * (2 * Pi() * rx / w) ** 2 + (irow - h / 2)**2 * (2 * Pi() * ry / h)**2) / 2));
}

// Apply the filter and transform the image back
result = real((filter * fourier).RealIFFT()[padT, padL, padT + hOrig, padL + wOrig]);
result.ImageCopyMetaDataFrom(src, "(Gauss filtered)");

// Describe what we did
TagGroup tg = result.ImageGetTagGroup().TagGroupGetOrCreateTagList("Processing").TagGroupCreateGroupTagAtEnd();
tg.TagGroupSetTagAsString("Operation", "Gaussian Blur");
tg.TagGroupSetTagAsString("Time", FormatTimeString(GetCurrentTime(), 17));
tg = tg.TagGroupGetOrCreateTagGroup("Parameters");
tg.TagGroupSetTagAsNumber("rx (px)", rx);
if (src.ImageGetNumDimensions() > 1)
	tg.TagGroupSetTagAsNumber("ry (px)", ry);

result.ShowImage();

