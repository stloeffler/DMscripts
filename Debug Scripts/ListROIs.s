/******************************************************************************
	List ROIs

	This script lists all regions of interest (ROIs) in the front-most image,
	together with their properties, and prints them into the result window.

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

image img := GetFrontImage();
ImageDisplay disp = img.ImageGetImageDisplay(0);

number i;
number count = disp.ImageDisplayCountROIS();

result("=== ROIs in " + img.ImageGetLabel() + ": " + img.ImageGetName() + " ===\n\n");

for (i = 0; i < count; i++) {
	ROI r = disp.ImageDisplayGetROI(i);
	number red, green, blue;
	r.ROIGetColor(red, green, blue);

	result ("[" + i + "]");

	number x1, y1, x2, y2;
	result ("\tType: ");
	if (r.ROIIsLine()) {
		r.ROIGetLine(x1, y2, x2, y2);
		result("Line (" + x1 + "," + y1 + ")--(" + x2 + "," + y2 + ")\n");
	}
	else if (r.ROIIsPoint()) {
		r.ROIGetPoint(x1, y1);
		result("Point (" + x1 + "," + y1 + ")\n");
	}
	else if (r.ROIIsRectangle()) {
		r.ROIGetRectangle(x1, y2, x2, y2);
		result("Rectangle (" + x1 + "," + y1 + ")--(" + x2 + "," + y2 + ")\n");
	}
	else if (r.ROIIsRange()) {
		r.ROIGetRange(x1, x2);
		result("Range " + x1 + "--" + x2 + "\n");
	}
	else {
		result ("Polygon ");
		number j;
		for (j = 0; j < r.ROICountVertices(); j++) {
			r.ROIGetVertex(j, x1, y1);
			if (j > 0) result ("--");
			result("(" + x1 + "," + y1 + ")");
		}
		result ("\n");
	}

	result ("\tName: " + r.ROIGetName() + "\n");
	result ("\tLabel: " + r.ROIGetLabel() + "\n");
	result ("\tID: " + Decimal(r.ROIGetID()) + "\n");
	result ("\tColor: " + red + ", " + green + ", " + blue + "\n");
	result ("\tFlags: ");
	result ((!r.ROIIsValid() ? "not " : "") + "valid, ");
	result ((!r.ROIGetMoveable() ? "not " : "") + "movable, ");
	result ((!r.ROIGetDeletable() ? "not " : "") + "deletable, ");
	result ((!r.ROIGetResizable() ? "not " : "") + "resizable, ");
	result ((!r.ROIGetVolatile() ? "not " : "") + "volatile, ");
	result ((!r.ROIIsClosed() ? "not " : "") + "closed, ");
	result ((!disp.ImageDisplayIsROISelected(r) ? "not " : "") + "selected" + "\n");
}

result ("\n");

