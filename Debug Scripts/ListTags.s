/******************************************************************************
	List Tags

	This script lists either all global tags (also accessible from the File menu)
	or all tags of the front-most image (also accessible from the context menu).

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

		// NB: For tag groups, type should be 0. However, TagGroupGetTagType()
		// does not always return the correct value. Hence we assume that if
		// TagGroupGetTagAsTagGroup() succeeds, the given tag must be a TagGroup
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
		// NB: type == 20 && type1 == 4 identifies both strings and entries of the form
		// TagGroupSetTagAsArray(tg, "tst", IntegerImage("", 2, 0, 12));
		// Since strings are by far the more common, we assume they are strings here
		else {
			string val = "";
			tg.TagGroupGetTagAsString(label, val);
			retVal += val;
		}

		retVal += "\n";
	}

	return retVal;
}

string GetAllTagsAsString(TagGroup tg) {
	return GetAllTagsAsString(tg, "");
}


if (TwoButtonDialog("Export global or image tags?", "Global", "Image") == 1) {
	result("=== Global Tags ===\n\n");
	result(GetPersistentTagGroup().GetAllTagsAsString() + "\n");
}
else {
	image img := GetFrontImage();
	result("=== Image Tags of " + img.ImageGetLabel() + ": " + img.ImageGetName() + " ===\n\n");
	result(img.ImageGetTagGroup().GetAllTagsAsString() + "\n");
}

