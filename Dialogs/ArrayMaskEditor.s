/******************************************************************************
	Array Mask Editor

	An editor for array masks (usually used for masking lattice spots in
	diffraction patterns). To use, select an array mask and click "Assign". It
	will give you three circles. Move the green one to change the center of the
	mask (this changes the calibration offset of the image). Use the red and
	blue circles to fine-position the mask. Use the "Order" buttons in the
	dialog window to change the diffraction order to which the red and blue
	circles correspond (e.g., change it to 2 or 3 to move the circle to the
	second or third order reflection, e.g., from the (111) spot to the (222) or
	the (333) spot for increased accuracy). Also displayed are the lengths and
	angles of the reciprocal lattice vectors, as well as their length ratio and
	the angle between them to aid the indexing of diffraction patterns.

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

// GMS 1.6.0: RegisterScriptPalette throws mysterious error; use dialog.display instead at the bottom


class ArrayMaskEditor : uiframe
{
	number maskID, circle0ID, circle1ID, circle2ID;
	ImageDisplay disp;
	number dispListener, windowListener;

	number isAssigned(object self) {
		return self.LookupElement("btnAssign").DLGGetTitle() != "Assign";
	}

	number getWindow(object self, DocumentWindow & win) {
		if (!disp.ImageDisplayIsValid()) return 0;
		ImageDocument doc = disp.ComponentGetImageDocument();
		if (!doc.ImageDocumentIsValid()) return 0;
		win = doc.ImageDocumentGetWindow();
		return win.WindowIsValid();
	}

	void getImageCenter(object self, Image src, number & x, number & y) {
		number dx, dy;
		string unit;

		src.ImageGetDimensionCalibration(0, x, dx, unit, 1);
		src.ImageGetDimensionCalibration(1, y, dy, unit, 1);
	}

	Component getMask(object self) {
		Component invalid;
		if (!disp.ImageDisplayIsValid()) return invalid;
		return disp.ComponentGetChildByID(maskID);
	}

	Component getCircle(object self, number idx) {
		Component invalid;
		if (!disp.ImageDisplayIsValid()) return invalid;
		if (idx == 0) return disp.ComponentGetChildByID(circle0ID);
		if (idx == 1) return disp.ComponentGetChildByID(circle1ID);
		if (idx == 2) return disp.ComponentGetChildByID(circle2ID);
		return invalid;
	}

	void addListener(object self) {
		if (disp.ImageDisplayIsValid())
			dispListener = disp.ImageDisplayAddEventListener(self, "component_changed,component_removed:onComponentChanged");
		DocumentWindow win;
		if (self.getWindow(win))
			windowListener = WindowAddWindowListener(win, self, "window_closed:onWindowClosed");
	}

	void removeListener(object self) {
		if (disp.ImageDisplayIsValid() && dispListener)
				disp.ImageDisplayRemoveEventListener(dispListener);

		DocumentWindow win;
		if (self.getWindow(win) && windowListener)
			WindowRemoveWindowListener(win, windowListener);
	}


	number getCircleCoords(object self, number idx, number & x, number & y) {
		Component comp;
		ImageDisplay disp;
		image src;
		number x0, y0, dx, dy;
		string xunit, yunit;
		number x1, y1, x2, y2;

		comp = self.getCircle(idx);

		if (!comp.ComponentIsValid()) return 0;

		disp = comp.ComponentGetParentImageDisplay();
		if (!disp.ImageDisplayIsValid()) return 0;

		src := disp.ImageDisplayGetImage();
		src.ImageGetDimensionCalibration(0, x0, dx, xUnit, 1);
		src.ImageGetDimensionCalibration(1, y0, dy, yUnit, 1);

		comp.ComponentGetRect(y1, x1, y2, x2);
		x = (0.5 * (x1 + x2) - x0);
		y = (0.5 * (y1 + y2) - y0);
		return 1;
	}

	number getCalibratedCircleCoords(object self, number idx, number & x, number & y) {
		Component comp;
		image src;
		number x0, y0, dx, dy;
		string xunit, yunit;
		number x1, y1, x2, y2;

		comp = self.getCircle(idx);
		if (!comp.ComponentIsValid()) return 0;

		ImageDisplay disp = comp.ComponentGetParentImageDisplay();
		if (!disp.ImageDisplayIsValid()) return 0;

		src := disp.ImageDisplayGetImage();
		src.ImageGetDimensionCalibration(0, x0, dx, xUnit, 1);
		src.ImageGetDimensionCalibration(1, y0, dy, yUnit, 1);

		comp.ComponentGetRect(y1, x1, y2, x2);
		x = (0.5 * (x1 + x2) - x0) * dx;
		y = (0.5 * (y1 + y2) - y0) * dy;
		return 1;
	}

	number setCircleCoords(object self, number idx, number x, number y) {
		Component comp;
		image src;
		number x0, y0, dx, dy;
		string xunit, yunit;
		number x1, y1, x2, y2;
		number oldX, oldY;

		comp = self.getCircle(idx);
		if (!self.getCircleCoords(idx, oldX, oldY)) return 0;

		// Ensure we don't create an endless loop (circle changed > mask changed > circle changed > ...)
		// If the new coords are the same as the old ones, just bail out
		if (oldX == x && oldY == y) return 1;

		comp.ComponentPositionAroundPoint(x, y, 0.5, 0.5, 1, 1);

		return 1;
	}

	void updateInfo(object self) {
		number x1, y1, x2, y2;
		number l1, l2, l3, a1, a2;
		number order1, order2;
		string unit;

		if (!disp.ImageDisplayIsValid()) return;

		Image src := disp.ImageDisplayGetImage();

		unit = src.ImageGetDimensionUnitString(0);

		self.getCalibratedCircleCoords(1, x1, y1);
		order1 = self.LookupElement("order1").DLGGetTitle().val();
		x1 /= order1;
		y1 /= order1;
		l1 = sqrt(x1**2 + y1**2);
		a1 = atan2(-y1, x1) * 180 / Pi();
		self.LookupElement("length1").DLGTitle(l1 + " " + unit);
		self.LookupElement("angle1").DLGTitle(a1 + " °");

		self.getCalibratedCircleCoords(2, x2, y2);
		order2 = self.LookupElement("order2").DLGGetTitle().val();
		x2 /= order2;
		y2 /= order2;
		l2 = sqrt(x2**2 + y2**2);
		a2 = atan2(-y2, x2) * 180 / Pi();
		self.LookupElement("length2").DLGTitle(l2 + " " + unit);
		self.LookupElement("angle2").DLGTitle(a2 + " °");

		l3 = sqrt((x2 - x1)**2 + (y2 - y1)**2);

		self.LookupElement("ratio").DLGTitle("" + (l1 / l2));
		self.LookupElement("deltaAngle").DLGTitle((acos(-(l3 ** 2 - l2 ** 2 - l1 ** 2) / (2 * l1 * l2)) * 180 / Pi()) + " °");
	}

	void clearInfo(object self) {
		self.LookupElement("length1").DLGTitle("");
		self.LookupElement("angle1").DLGTitle("");
		self.LookupElement("length2").DLGTitle("");
		self.LookupElement("angle2").DLGTitle("");
		self.LookupElement("ratio").DLGTitle("");
		self.LookupElement("deltaAngle").DLGTitle("");
	}

	void onMaskChanged(object self) {
		number x0, y0, x, y, order;

		Component mask = self.getMask();
		if (!mask.ComponentIsValid()) return;

		ImageDisplay disp = mask.ComponentGetParentImageDisplay();
		if (!disp.ImageDisplayIsValid()) return;

		self.getImageCenter(disp.ImageDisplayGetImage(), x0, y0);

		order = self.LookupElement("order1").DLGGetTitle().val();
		mask.ComponentGetControlPoint(9, x, y);
		self.setCircleCoords(1, order * x + x0, order * y + y0);

		order = self.LookupElement("order2").DLGGetTitle().val();
		mask.ComponentGetControlPoint(10, x, y);
		self.setCircleCoords(2, order * x + x0, order * y + y0);
		self.updateInfo();
	}

	void onCircleChanged(object self, number idx) {
		number x0, y0, dx, dy;
		string xUnit, yUnit;
		number x1, x2, y1, y2, order;
		number x, y;
		Image src;
		Component mask;

		mask = self.getMask();

		if (!self.getCircleCoords(idx, x, y)) return;
		if (!mask.ComponentIsValid()) return;

		order = self.LookupElement("order" + idx).DLGGetTitle().val();

		mask.ComponentSetControlPoint((idx == 1 ? 9 : 10), x / order, y / order, 0);

		self.updateInfo();
	}

	void onOrder(object self, number idx) {
		number order = self.LookupElement("order" + idx).DLGGetTitle().val();
		number mode = TwoButtonDialog("Move circle (keep mask) or keep circle (move mask)?", "Move Circle", "Keep Circle");

		if (!GetNumber("New order:", order, order)) return;
		if (order == 0) return;

		self.LookupElement("order" + idx).DLGTitle("" + order);

		if (mode == 0) self.onCircleChanged(idx);
		else self.onMaskChanged();
	}

	void onOrder1(object self) { self.onOrder(1); }
	void onOrder2(object self) { self.onOrder(2); }

	Component getPrimaryMask(object self, ImageDisplay disp) {
		Component invalid;
		number n, i, iSel;

		n = disp.ComponentCountChildrenOfType(9);
		if (n == 0) return invalid;
		if (n == 1) return disp.ComponentGetNthChildOfType(9, 0);

		// If we get here we have more than one mask in the image
		// If exactly one is selected we return that
		iSel = -1;
		for (i = 0; i < n; i++) {
			if (!disp.ComponentGetNthChildOfType(9, i).ComponentIsSelected()) continue;
			if (iSel >= 0) return invalid;
			iSel = i;
		}
		if (iSel >= 0) return disp.ComponentGetNthChildOfType(9, iSel);
		return invalid;
	}

	void addCircles(object self) {
		number w, h, x, y, x0, y0;

		Component mask = self.getMask();
		if (!mask.ComponentIsValid()) return;

		ImageDisplay disp = mask.ComponentGetParentImageDisplay();
		if (!disp.ImageDisplayIsValid()) return;

		image src := disp.ImageDisplayGetImage();
		self.getImageCenter(src, x0, y0);

		mask.ComponentGetControlPoint(7, w, h);

		Component circle0 = NewOvalAnnotation(y0 - h, x0 - w, y0 + h, x0 + w);
		circle0.ComponentSetForegroundColor(0, .75, 0);
		circle0.ComponentSetFillMode(2);
		circle0.ComponentSetDrawingMode(2);
		circle0.ComponentSetDeletable(0);

		mask.ComponentGetControlPoint(9, x, y);
		Component circle1 = NewOvalAnnotation(y - h + y0, x - w + x0, y + h + y0, x + w + x0);
		circle1.ComponentSetForegroundColor(1, 0, 0);
		circle1.ComponentSetFillMode(2);
		circle1.ComponentSetDrawingMode(2);
		circle1.ComponentSetDeletable(0);

		mask.ComponentGetControlPoint(10, x, y);
		Component circle2 = NewOvalAnnotation(y - h + y0, x - w + x0, y + h + y0, x + w + x0);
		circle2.ComponentSetForegroundColor(0, 0, 1);
		circle2.ComponentSetFillMode(2);
		circle2.ComponentSetDrawingMode(2);
		circle2.ComponentSetDeletable(0);

		disp.ComponentAddChildAtBeginning(circle0);
		disp.ComponentAddChildAtBeginning(circle1);
		disp.ComponentAddChildAtBeginning(circle2);

		circle0ID = circle0.ComponentGetID();
		circle1ID = circle1.ComponentGetID();
		circle2ID = circle2.ComponentGetID();
	}

	void removeCircles(object self) {
		number i;
		for (i = 0; i < 3; i++) {
			Component comp = self.getCircle(i);
			if (comp.ComponentIsValid()) comp.ComponentRemoveFromParent();
		}
		circle0ID = circle1ID = circle2ID = 0;
	}

	void onAssign(object self) {
		if (self.LookupElement("btnAssign").DLGGetTitle() == "Assign") {
			string msg = "Please select one array mask";
			image src := FindFrontImage();
			if (!src.ImageIsValid()) {
				OKDialog(msg);
				return;
			}
			disp = src.ImageGetImageDisplay(0);
			if (!disp.ImageDisplayIsValid()) {
				OKDialog(msg);
				return;
			}
			Component c = self.getPrimaryMask(src.ImageGetImageDisplay(0));
			if (!c.ComponentIsValid()) {
				OKDialog(msg);
				return;
			}
			maskID = c.ComponentGetID();

			self.addCircles();
			self.addListener();
			self.updateInfo();
			self.SetElementIsEnabled("order1", 1);
			self.SetElementIsEnabled("order2", 1);

			self.LookupElement("btnAssign").DLGTitle("Deassign");
		}
		else {
			self.SetElementIsEnabled("order1", 0);
			self.SetElementIsEnabled("order2", 0);
			self.LookupElement("order1").DLGTitle("1");
			self.LookupElement("order2").DLGTitle("1");
			self.removeListener();
			self.removeCircles();
			self.clearInfo();
			circle0ID = circle1ID = circle2ID = maskID = 0;

			self.LookupElement("btnAssign").DLGTitle("Assign");
		}
	}

	void onComponentChanged(object self, number img_disp_event_flags, ImageDisplay img_disp, number comp_change_flags, number comp_disp_change_flags, Component comp) {
		if (img_disp_event_flags == 0x2000000) {
			// component was removed
			// if it was the mask (i.e., the mask is no longer available), sign off
			if (!self.getMask().ComponentIsValid()) self.onAssign();
			return;
		}
		else if (img_disp_event_flags == 0x30000000) {
			// Component was moved
			if (comp.ComponentGetID() == circle0ID) {
				// Update the origin
				number x1, y1, x2, y2, x, y, dx, dy;
				string xunit, yunit;
				image src := img_disp.ImageDisplayGetImage();

				src.ImageGetDimensionCalibration(0, x, dx, xunit, 1);
				src.ImageGetDimensionCalibration(1, y, dy, yunit, 1);

				comp.ComponentGetRect(y1, x1, y2, x2);
				x = 0.5 * (x1 + x2);
				y = 0.5 * (y1 + y2);

				src.ImageSetDimensionCalibration(0, x, dx, xunit, 1);
				src.ImageSetDimensionCalibration(1, y, dy, yunit, 1);
				self.onMaskChanged();
			}
			else if (comp.ComponentGetID() == circle1ID)
				self.onCircleChanged(1);
			else if (comp.ComponentGetID() == circle2ID)
				self.onCircleChanged(2);
			else if (comp.ComponentGetID() == maskID)
				self.onMaskChanged();
		}
	}

	void onWindowClosed(Object self, number event_mask, DocumentWindow wnd) {
		self.onAssign();
	}

	object init(object self) {
		TagGroup dialog_items, box, items, subitems;
		TagGroup dialog_tags = DLGCreateDialog("Array Mask Editor", dialog_items);

		dispListener = windowListener = 0;

		dialog_tags.DLGTableLayout(1, 4, 0);

		dialog_items.DLGAddElement(DLGCreatePushButton("Deassign", "onAssign").DLGIdentifier("btnAssign").DLGFill("X"));

		dialog_items.DLGAddElement(DLGCreateBox("Red Circle", subitems).DLGLayout(DLGCreateTableLayout(2, 3, 0)));

		subitems.DLGAddElement(DLGCreateLabel("Order:"));
		subitems.DLGAddElement(DLGCreatePushButton("1", "onOrder1").DLGIdentifier("order1").DLGInternalPadding(5, 0));

		subitems.DLGAddElement(DLGCreateLabel("Length:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("length1"));

		subitems.DLGAddElement(DLGCreateLabel("Angle:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("angle1"));

		dialog_items.DLGAddElement(DLGCreateBox("Blue Circle", subitems).DLGLayout(DLGCreateTableLayout(2, 3, 0)));

		subitems.DLGAddElement(DLGCreateLabel("Order:"));
		subitems.DLGAddElement(DLGCreatePushButton("1", "onOrder2").DLGIdentifier("order2").DLGInternalPadding(5, 0));

		subitems.DLGAddElement(DLGCreateLabel("Length:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("length2"));

		subitems.DLGAddElement(DLGCreateLabel("Angle:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("angle2"));

		dialog_items.DLGAddElement(DLGCreateBox("Info", subitems).DLGLayout(DLGCreateTableLayout(2, 2, 0)).DLGFill("X"));

		subitems.DLGAddElement(DLGCreateLabel("Ratio:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("ratio"));

		subitems.DLGAddElement(DLGCreateLabel("Angle:"));
		subitems.DLGAddElement(DLGCreateLabel("").DLGWidth(12).DLGIdentifier("deltaAngle"));

		return self.init(dialog_tags);
	}

	void AboutToCloseDocument(object self) {
		self.removeListener();
		self.removeCircles();
	}
}

Object dialog = alloc(ArrayMaskEditor).init();
//RegisterScriptPalette(dialog, "", "Array Mask Editor");
dialog.display("Array Mask Editor");
dialog.onAssign();

