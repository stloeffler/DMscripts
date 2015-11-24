/******************************************************************************
	List Annotations

	This script lists all components (including what's called "Annotations"
	in the UI) of the front image document and prints them into the result
	window. Also printed are the properties of the respective components.

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

// This script does not work in GMS 1.6.0 - see ListAnnotations_1-6.s for that


string GetAllTagsAsString(TagGroup tg, string indent) {
	number i;
	number count = tg.TagGroupCountTags();
	string retVal = "";
	TagGroup sg;

	for (i = 0; i < count; i++) {
		string label = tg.TagGroupGetTagLabel(i);
		number type = tg.TagGroupGetTagType(i, 0);
		number type1 = tg.TagGroupGetTagType(i, 1);
		number type2 = tg.TagGroupGetTagType(i, 2);

		if (label == "")
			label = "[" + i + "]";

		retVal += indent + label + " = ";

		if (tg.TagGroupGetTagAsTagGroup(label, sg)) {
			retVal += "{\n";
			TagGroup sg;
			if (tg.TagGroupGetTagAsTagGroup(label, sg)) {
				retVal += sg.GetAllTagsAsString(indent + "\t");
			}
			retVal += indent + "}";
		}
		else if (type == 20 && type1 != 4) {
			retVal += "array(" + type2 + " elements)";
		}
		else {
			string val = "";
			tg.TagGroupGetTagAsString(label, val);
			retVal += val;
		}
		retVal += "\n";
	}

	return retVal;
}

string ComponentToString(Component comp, string indent, number idx) {
	string retVal = "";
	number j;

	number type = comp.ComponentGetType();
	retVal += indent + "[" + idx + "]";

	retVal += "\tType: ";
	if (type == 2) { retVal += "Line"; }
	else if (type == 3) { retVal += "Arrow"; }
	else if (type == 4) { retVal += "Double Arrow"; }
	else if (type == 5) { retVal += "Box"; }
	else if (type == 6) { retVal += "Oval"; }
	else if (type == 8) { retVal += "Spot Mask"; }
	else if (type == 9) { retVal += "Array Mask"; }
	else if (type == 12) { retVal += "Profile"; }
	else if (type == 13) { retVal += "Text"; }
	else if (type == 15) { retVal += "Bandpass Mask"; }
	else if (type == 17) { retVal += "Group"; }
	else if (type == 19) { retVal += "Wedge Mask"; }
	else if (type == 20) { retVal += "ImageDisplay"; }
	else if (type == 23) { retVal += "Rectangular ROI"; }
	else if (type == 24) { retVal += "ImageDocumentRoot"; }
	else if (type == 25) { retVal += "Line ROI"; }
	else if (type == 27) { retVal += "Point ROI"; }
	else if (type == 29) { retVal += "Polygon OI"; }
	else if (type == 31) { retVal += "Scale marker"; }
	else { retVal += "Unknown"; }
	retVal += " (" + type + ")\n";

	TagGroup tg = NewTagGroup();
	comp.ComponentExternalizeProperties(tg);
	retVal += tg.GetAllTagsAsString(indent + "\t");

	for (j = 0; j < comp.ComponentCountChildren(); j++) {
		retVal += comp.ComponentGetChild(j).ComponentToString(indent + "\t", j);
	}

	return retVal;
}

string ComponentToString(Component base) {
	return ComponentToString(base, "", 0);
}


image img := GetFrontImage();

result("=== Annotations in " + img.ImageGetLabel() + ": " + img.ImageGetName() + " ===\n\n");
result(GetFrontImageDocument().ImageDocumentGetRootComponent().ComponentToString());
result("\n");

