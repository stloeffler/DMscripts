/******************************************************************************
	Math Palette

	Provides a palette window to quickly perform simple mathematical operations
	on open images. Includes most operations that are available from the
	Process > Simple Math menu command, but also several operations on complex
	images (such as extracting real and imaginary part, the absolute value, or
	the phase) and allows cropping of images. It also enabled quick access to
	basic information about the image (such as minimum, maximum, mean value,
	etc.) and therefore brings operations such as "subtract minimum" or "divide
	by maximum" down to two clicks.
	
	To install, click File > Install Script File..., select MathPalette.s,
	choose "Library", and click "OK". You can subsequently access the palette
	from Window > Floating Windows > Math.

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

void CopyMetaData(Image & src, Image & dest) {
	dest.ImageGetTagGroup().TagGroupCopyTagsFrom(src.ImageGetTagGroup());
	dest.ImageCopyCalibrationFrom(src);
}

TagGroup CreateButton(string label, string id) {
	return DLGCreatePushButton(label, "on" + id).DLGIdentifier("btn" + id).DLGFill("X").DLGExpand("X");
}

class MathPalette : uiframe
{
	number imageOrderListener;

	void populateImagesPopup(object self, string id, number selectedIdx) {
		TagGroup popup = self.LookupElement(id);
		TagGroup items;
		number i, j;
		ImageDocument doc;

		// Delete existing popup items
		popup.TagGroupGetTagAsTagGroup("Items", items);
		items.TagGroupDeleteAllTags();

		// Add all image displays to the popup list
		for (i = 0; i < CountImageDisplays(); i++) {
			ImageDisplay disp = GetNthImageDisplay(i, doc);
			for (j = 0; j < disp.ImageDisplayCountSlices(); j++) {
				string label = disp.ImageDisplayGetFullSliceLabelById(disp.ImageDisplayGetSliceIdByIndex(j));
				label += ": " + doc.ImageDocumentGetName();
				popup.DLGAddPopupItemEntry(label);
			}
		}

		// Make sure the popup is updated (especially if all images were closed)
		popup.DLGInvalid(1);
		if (selectedIdx > CountImageDisplays())
			selectedIdx = CountImageDisplays();
		popup.DLGValue(selectedIdx);
	}

	ImageDisplay getFirstImageDisplay(object self) {
		number idx = self.LookupElement("imgA").DLGGetValue() - 1;
		return GetNthImageDisplay(idx);
	}

	number getFirstImage(object self, image & img) {
		ImageDisplay disp = self.GetFirstImageDisplay();
		if (!disp.ImageDisplayIsValid()) return 0;
		img := disp.ImageDisplayGetImage();
		return 1;
	}

	number getSecondImage(object self, image & img) {
		number idx = self.LookupElement("imgB").DLGGetValue() - 1;
		ImageDisplay disp = GetNthImageDisplay(idx);
		if (!disp.ImageDisplayIsValid()) return 0;
		img := disp.ImageDisplayGetImage();
		return 1;
	}

	void enableButtons(object self) {
		image a;
		number hasA = self.getFirstImage(a);
		number hasB = 1;

		if (self.LookupElement("bRadio").DLGGetValue() == 0) {
			Image b;
			hasB = self.getSecondImage(b);
		}

		self.SetElementIsEnabled("btnUnaryMinus", hasA);
		self.SetElementIsEnabled("btnReciprocal", hasA);
		self.SetElementIsEnabled("btnCrop", hasA);

		self.SetElementIsEnabled("btnAbs", hasA);
		self.SetElementIsEnabled("btnAbs2", hasA);
		self.SetElementIsEnabled("btnArg", hasA);

		self.SetElementIsEnabled("btnRe", hasA);
		self.SetElementIsEnabled("btnIm", hasA);
		self.SetElementIsEnabled("btnConj", hasA);

		self.SetElementIsEnabled("btnSqrt", hasA);
		self.SetElementIsEnabled("btnExp", hasA);
		self.SetElementIsEnabled("btnLn", hasA);

		self.SetElementIsEnabled("btnSin", hasA);
		self.SetElementIsEnabled("btnCos", hasA);
		self.SetElementIsEnabled("btnTan", hasA);

		self.SetElementIsEnabled("btnAsin", hasA);
		self.SetElementIsEnabled("btnAcos", hasA);
		self.SetElementIsEnabled("btnAtan", hasA);

		self.SetElementIsEnabled("btnPlus", hasA && hasB);
		self.SetElementIsEnabled("btnMinus", hasA && hasB);
		self.SetElementIsEnabled("btnTimes", hasA && hasB);

		self.SetElementIsEnabled("btnDivide", hasA && hasB);
		self.SetElementIsEnabled("btnModulo", hasA && hasB);
		self.SetElementIsEnabled("btnPower", hasA && hasB);

		self.SetElementIsEnabled("btnInfoMin", hasA);
		self.SetElementIsEnabled("btnInfoMax", hasA);
		self.SetElementIsEnabled("btnInfoSum", hasA);

		self.SetElementIsEnabled("btnInfoMean", hasA);
		self.SetElementIsEnabled("btnInfoSigma", hasA);
		self.SetElementIsEnabled("btnInfoRMS", hasA);
	}

	void unaryOp(object self, string op) {
		Image src;
		Image retVal;

		if (!self.getFirstImage(src)) {
			OKDialog("No image selected");
			return;
		}

		if (op == "-") retVal = -src;
		else if (op == "1/") retVal = 1/src;
		else if (op == "||") retVal = modulus(src);
		else if (op == "||^2") retVal = norm(src);
		else if (op == "arg") retVal = phase(src);
		else if (op == "conj") retVal = conjugate(src);
		else if (op == "Re") retVal = real(src);
		else if (op == "Im") retVal = imaginary(src);
		else if (op == "sqrt") retVal = sqrt(src);
		else if (op == "exp") retVal = exp(src);
		else if (op == "ln") retVal = log(src);
		else if (op == "sin") retVal = sin(src);
		else if (op == "cos") retVal = cos(src);
		else if (op == "tan") retVal = tan(src);
		else if (op == "asin") retVal = asin(src);
		else if (op == "acos") retVal = acos(src);
		else if (op == "atan") retVal = atan(src);
		else {
			OKDialog("Unsupported unary operation " + op);
			return;
		}

		src.CopyMetaData(retVal);
		retVal.ShowImage();
	}

	void binaryOp(object self, string op) {
		Image a;
		Image retVal;

		if (!self.getFirstImage(a)) {
			OKDialog("No image selected");
			return;
		}

		if (self.LookupElement("bRadio").DLGGetValue() == 0) {
			Image b;

			if (!self.getSecondImage(b)) {
				OKDialog("No image selected");
				return;
			}
			if (op == "+") retVal = a + b;
			else if (op == "-") retVal = a - b;
			else if (op == "*") retVal = a * b;
			else if (op == "/") retVal = a / b;
			else if (op == "%") retVal = mod(a, b);
			else if (op == "^") retVal = a ** b;
			else {
				OKDialog("Unsupported binary operation " + op);
				return;
			}
		}
		else {
			number b = self.LookupElement("numberB").DLGGetValue();
			if (op == "+") retVal = a + b;
			else if (op == "-") retVal = a - b;
			else if (op == "*") retVal = a * b;
			else if (op == "/") retVal = a / b;
			else if (op == "%") retVal = mod(a, b);
			else if (op == "^") retVal = a ** b;
			else {
				OKDialog("Unsupported binary operation " + op);
				return;
			}
		}
		a.CopyMetaData(retVal);
		retVal.ShowImage();
	}

	void infoOp(object self, string op) {
		Image a;
		number b, x, y;

		if (!self.getFirstImage(a)) {
			OKDialog("No image selected");
			return;
		}

		if (op == "min") {
			b = a.min(x, y);
			result("[" + a.GetLabel() + ": " + a.GetName() + "] Minimum: " + b + " @ (" + x + "," + y + ")\n");
		}
		else if (op == "max") {
			b = a.max(x, y);
			result("[" + a.GetLabel() + ": " + a.GetName() + "] Maximum: " + b + " @ (" + x + "," + y + ")\n");
		}
		else if (op == "sum") {
			b = sum(a);
			result("[" + a.GetLabel() + ": " + a.GetName() + "] Sum: " + b + "\n");
		}
		else if (op == "mean") {
			b = mean(a);
			result("[" + a.GetLabel() + ": " + a.GetName() + "] Mean: " + b + "\n");
		}
		else if (op == "sigma") {
			a.GetSize(x, y);
			b = sqrt((x * y) / (x * y - 1) * (RMS(a)**2 - mean(a)**2));
			//b = sqrt((x * y) / (x * y - 1) * mean((a - mean(a))**2));
			result("[" + a.GetLabel() + ": " + a.GetName() + "] Std. Dev.: " + b + "\n");
		}
		else if (op == "RMS") {
			b = RMS(a);
			result("[" + a.GetLabel() + ": " + a.GetName() + "] RMS: " + b + "\n");
		}
		else {
			OKDialog("Unsupported information " + op);
			return;
		}

		self.LookupElement("numberB").DLGValue(b);
	}

	void onUnaryMinus(object self) { self.unaryOp("-"); }
	void onReciprocal(object self) { self.unaryOp("1/"); }
	void onAbs(object self) { self.unaryOp("||"); }
	void onAbs2(object self) { self.unaryOp("||^2"); }
	void onArg(object self) { self.unaryOp("arg"); }
	void onConj(object self) { self.unaryOp("conj"); }
	void onRe(object self) { self.unaryOp("Re"); }
	void onIm(object self) { self.unaryOp("Im"); }
	void onSqrt(object self) { self.unaryOp("sqrt"); }
	void onExp(object self) { self.unaryOp("exp"); }
	void onLn(object self) { self.unaryOp("ln"); }
	void onSin(object self) { self.unaryOp("sin"); }
	void onCos(object self) { self.unaryOp("cos"); }
	void onTan(object self) { self.unaryOp("tan"); }
	void onAsin(object self) { self.unaryOp("asin"); }
	void onAcos(object self) { self.unaryOp("acos"); }
	void onAtan(object self) { self.unaryOp("atan"); }

	void onPlus(object self) { self.binaryOp("+"); }
	void onMinus(object self) { self.binaryOp("-"); }
	void onTimes(object self) { self.binaryOp("*"); }
	void onDivide(object self) { self.binaryOp("/"); }
	void onModulo(object self) { self.binaryOp("%"); }
	void onPower(object self) { self.binaryOp("^"); }

	void onInfoMin(object self) { self.infoOp("min"); }
	void onInfoMax(object self) { self.infoOp("max"); }
	void onInfoSum(object self) { self.infoOp("sum"); }
	void onInfoMean(object self) { self.infoOp("mean"); }
	void onInfoSigma(object self) { self.infoOp("sigma"); }
	void onInfoRMS(object self) { self.infoOp("RMS"); }

	void onCrop(object self) {
		ImageDisplay disp = self.GetFirstImageDisplay();

		if (!disp.ImageDisplayIsValid()) {
			OKDialog("No image selected");
			return;
		}

		Image src := disp.ImageDisplayGetImage();
		Image retVal = src[]; // For 2D images, this succeeds only for rectangular ROIs!
		src.CopyMetaData(retVal);

		ROI selection = disp.ImageDisplayGetROI(0);
		if (selection.ROIIsValid()) {
			number t, l, b, r;
			number dx, x0;

			if (src.ImageGetNumDimensions() == 1) {
				selection.ROIGetRange(l, r);
				dx = src.ImageGetDimensionScale(0);
				x0 = src.ImageGetDimensionOrigin(0);
				retVal.ImageSetDimensionOrigin(0, x0 + dx * l);
			}
			else {
				selection.ROIGetRectangle(t, l, b, r);
				dx = src.ImageGetDimensionScale(0);
				x0 = src.ImageGetDimensionOrigin(0);
				retVal.ImageSetDimensionOrigin(0, x0 + dx * l);

				dx = src.ImageGetDimensionScale(1);
				x0 = src.ImageGetDimensionOrigin(1);
				retVal.ImageSetDimensionOrigin(1, x0 + dx * t);
			}
		}

		retVal.ShowImage();
	}

	object init(object self) {
		TagGroup dialog_items, items, subitems;
		TagGroup dialog_tags = DLGCreateDialog("Math Palette", dialog_items);

		dialog_tags.DLGTableLayout(1, 4, 0);

		dialog_items.DLGAddElement(DLGCreateBox("Images", subitems).DLGTableLayout(3, 3, 0).DLGFill("X"));
		subitems.DLGAddElement(DLGCreateLabel("a"));
		subitems.DLGAddElement(DLGCreateLabel(""));
		subitems.DLGAddElement(DLGCreatePopup().DLGIdentifier("imgA").DLGFill("X"));

		subitems.DLGAddElement(DLGCreateLabel("b"));
		subitems.DLGAddElement(DLGCreateRadioList(items, 0).DLGIdentifier("bRadio"));
		items.DLGAddRadioItem("", 0).DLGInternalPadding(0, 5);
		items.DLGAddRadioItem("", 1).DLGInternalPadding(0, 0);

		subitems.DLGAddElement(DLGCreatePanel(items).DLGTableLayout(1, 2, 0));
		items.DLGAddElement(DLGCreatePopup().DLGIdentifier("imgB").DLGFill("X"));
		items.DLGAddElement(DLGCreateRealField(0, 24, 0).DLGIdentifier("numberB"));

		dialog_items.DLGAddElement(DLGCreateBox("Operations", subitems).DLGTableLayout(3, 8, 0).DLGFill("X"));
		subitems.DLGAddElement(CreateButton("-a", "UnaryMinus"));
		subitems.DLGAddElement(CreateButton("1/a", "Reciprocal"));
		subitems.DLGAddElement(CreateButton("crop a", "Crop"));

		subitems.DLGAddElement(CreateButton("|a|", "Abs"));
		subitems.DLGAddElement(CreateButton("|a|²", "Abs2"));
		subitems.DLGAddElement(CreateButton("arg a", "Arg"));

		subitems.DLGAddElement(CreateButton("Re a", "Re"));
		subitems.DLGAddElement(CreateButton("Im a", "Im"));
		subitems.DLGAddElement(CreateButton("a*", "Conj"));

		subitems.DLGAddElement(CreateButton("sqrt(a)", "Sqrt"));
		subitems.DLGAddElement(CreateButton("exp(a)", "Exp"));
		subitems.DLGAddElement(CreateButton("ln(a)", "Ln"));

		subitems.DLGAddElement(CreateButton("sin(a)", "Sin"));
		subitems.DLGAddElement(CreateButton("cos(a)", "Cos"));
		subitems.DLGAddElement(CreateButton("tan(a)", "Tan"));

		subitems.DLGAddElement(CreateButton("asin(a)", "Asin"));
		subitems.DLGAddElement(CreateButton("acos(a)", "Acos"));
		subitems.DLGAddElement(CreateButton("atan(a)", "Atan"));

		subitems.DLGAddElement(CreateButton("a + b", "Plus"));
		subitems.DLGAddElement(CreateButton("a - b", "Minus"));
		subitems.DLGAddElement(CreateButton("a x b", "Times"));

		subitems.DLGAddElement(CreateButton("a / b", "Divide"));
		subitems.DLGAddElement(CreateButton("a % b", "Modulo"));
		subitems.DLGAddElement(CreateButton("a ^ b", "Power"));

		dialog_items.DLGAddElement(DLGCreateBox("Information", subitems).DLGTableLayout(2, 3, 1).DLGFill("X"));

		subitems.DLGAddElement(CreateButton("min(a)", "InfoMin"));
		subitems.DLGAddElement(CreateButton("max(a)", "InfoMax"));
		subitems.DLGAddElement(CreateButton("sum(a)", "InfoSum"));

		subitems.DLGAddElement(CreateButton("mean(a)", "InfoMean"));
		subitems.DLGAddElement(CreateButton("sigma(a)", "InfoSigma"));
		subitems.DLGAddElement(CreateButton("RMS(a)", "InfoRMS"));

		imageOrderListener = self.ApplicationAddEventListener("image_order_changed:onImageOrderChanged");

		// For script palettes
		TagGroup position = DLGBuildPositionFromApplication();
		position.TagGroupSetTagAsString("Width", "Medium");
		DLGSide(position, "Right");
		DLGPosition(dialog_tags, position);

		return self.init(dialog_tags);
	}

	// For dialogs only
	void AboutToCloseDocument(object self) {
		ApplicationRemoveEventListener(imageOrderListener);
	}

	~MathPalette(object self) {
		ApplicationRemoveEventListener(imageOrderListener);
	}

	void onImageOrderChanged(object self, number app_event_flags, object application) {
		self.populateImagesPopup("imgA", 1);
		self.populateImagesPopup("imgB", 2);
		self.enableButtons();
	}

}

Object dialog = alloc(MathPalette).init();
RegisterScriptPalette(dialog, "", "Math");
//dialog.display("Math Palette");

dialog.populateImagesPopup("imgA", 1);
dialog.populateImagesPopup("imgB", 2);
dialog.enableButtons();

