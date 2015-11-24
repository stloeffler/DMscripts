/******************************************************************************
	ROI Editor

	This script provides a small dialog that allows to display and edit the
	properties of ROIs. To use, run the script, select a ROI in an image, and
	press "Assign ROI" in the dialog.

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

class ROIEditorDialog : uiframe
{
	number ROIId;
	ImageDisplay disp;
	number eventListener;

	void clearUI(object self) {
		self.LookupElement("ROIId").DLGTitle("");
		self.DLGValue("ROIName", "");
		self.DLGValue("ROILabel", "");
		self.DLGValue("ROIMovable", 0);
		self.DLGValue("ROIDeletable", 0);
		self.DLGValue("ROIResizable", 0);
		self.DLGValue("ROIVolatile", 0);
		self.DLGValue("ROIClosed", 0);
	}

	void updateUI(object self) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		self.LookupElement("ROIId").DLGTitle("" + Decimal(ROIId));
		self.DLGValue("ROIName", r.ROIGetName());
		self.DLGValue("ROILabel", r.ROIGetLabel());
		self.DLGValue("ROIMovable", r.ROIGetMoveable());
		self.DLGValue("ROIDeletable", r.ROIGetDeletable());
		self.DLGValue("ROIResizable", r.ROIGetResizable());
		self.DLGValue("ROIVolatile", r.ROIGetVolatile());
		self.DLGValue("ROIClosed", r.ROIIsClosed());
	}

	void detach(object self) {
		ROIId = 0;
		self.clearUI();

		if (disp.ImageDisplayIsValid() && eventListener)
			disp.ImageDisplayRemoveEventListener(eventListener);
		eventListener = 0;
	}

	void attach(object self) {
		number i;
		ROI r;

		if (disp && eventListener)
			self.detach();

		disp = GetFrontImage().ImageGetImageDisplay(0);

		// Find (first) selected ROI
		for (i = 0; i < disp.ImageDisplayCountROIs(); i++) {
			r = disp.ImageDisplayGetROI(i);
			if (disp.ImageDisplayIsROISelected(r))
				break;
		}
		if (i == disp.ImageDisplayCountROIs())
			return;

		ROIId = r.ROIGetID();
		self.updateUI();

		string eventmap = "roi_changed:ROIChanged";
		eventListener = disp.ImageDisplayAddEventListener(self, eventmap);
	}

	void AboutToCloseDocument(object self, number verify) {
		self.detach();
	}

	void ROIChanged(Object self, Number event_flags, ImageDisplay img_disp, Number roi_change_flags, Number roi_disp_change_flags, ROI r) {
		if (r.ROIGetID() != ROIId)
			return;
		self.updateUI();
	}

	void onChangeMovable(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetMoveable(origin.DLGGetValue());
	}

	void onChangeDeletable(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetDeletable(origin.DLGGetValue());
	}

	void onChangeResizable(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetResizable(origin.DLGGetValue());
	}

	void onChangeVolatile(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetVolatile(origin.DLGGetValue());
	}

	void onChangeClosed(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetIsClosed(origin.DLGGetValue());
	}

	void onChangeName(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetName(origin.DLGGetStringValue());
	}

	void onChangeLabel(object self, TagGroup origin) {
		ROI r = GetROIFromID(ROIId);
		if (!r) return;
		r.ROISetLabel(origin.DLGGetStringValue());
	}

	object init(object self) {
		ROIId = 0;
		eventListener = 0;

		TagGroup dialog_items, subitems;
		TagGroup dialog_tags = DLGCreateDialog("Unwrap Dialog", dialog_items);

		dialog_tags.DLGTableLayout(1, 3, 0);

		dialog_items.DLGAddElement(DLGCreatePushButton("Assign ROI", "attach").DLGIdentifier("Assign").DLGFill("X"));
		dialog_items.DLGAddElement(DLGCreatePushButton("Deassign ROI", "detach").DLGIdentifier("Assign").DLGFill("X"));

		dialog_items.DLGAddElement(DLGCreatePanel(subitems).DLGTableLayout(2, 8, 0));

		subitems.DLGAddElement(DLGCreateLabel("ID:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateLabel("           ").DLGIdentifier("ROIId").DLGFill("X").DLGAnchor("North"));

		subitems.DLGAddElement(DLGCreateLabel("Name:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateStringField("", 15, "onChangeName").DLGIdentifier("ROIName").DLGFill("X"));

		subitems.DLGAddElement(DLGCreateLabel("Label:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateStringField("", 15, "onChangeLabel").DLGIdentifier("ROILabel").DLGFill("X"));

		subitems.DLGAddElement(DLGCreateLabel("Movable:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateCheckBox("", 0, "onChangeMovable").DLGIdentifier("ROIMovable").DLGAnchor("West"));

		subitems.DLGAddElement(DLGCreateLabel("Deletable:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateCheckBox("", 0, "onChangeDeletable").DLGIdentifier("ROIDeletable").DLGAnchor("West"));

		subitems.DLGAddElement(DLGCreateLabel("Resizable:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateCheckBox("", 0, "onChangeResizable").DLGIdentifier("ROIResizable").DLGAnchor("West"));

		subitems.DLGAddElement(DLGCreateLabel("Volatile:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateCheckBox("", 0, "onChangeVolatile").DLGIdentifier("ROIVolatile").DLGAnchor("West"));

		subitems.DLGAddElement(DLGCreateLabel("Closed:").DLGAnchor("East"));
		subitems.DLGAddElement(DLGCreateCheckBox("", 0, "onChangeClosed").DLGIdentifier("ROIClosed").DLGAnchor("West"));

		return self.init(dialog_tags);
	}
}

Object dialog = alloc(ROIEditorDialog).init();
dialog.display("ROI Editor");

