import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;
import controlP5.*;

ControlP5 cp5;
ColorPicker bgCp, fCp, sCp;
RadioButton radio;
CheckBox checkbox;

RFont font;
RShape[] shapes;

String characters,
	   currentShape = "Rect",
	   sampleText = "";
int fontSize,
	colNum;

color bgColor = color(0, 0, 255),
	  fillColor = color(0, 0, 0, 0),
	  strokeColor = color(0, 0, 0, 255);

float rotX, rotY, rotZ,
	  camX, camY, camZ,
	  sizeX, sizeY,
	  fluctuation,
	  fluctuationFrequency,
	  arcEnd;

boolean isFill = false,
		isStroke = true,
		animateRotation,
		animateFluctuation;

void setup() {
	size(displayWidth, displayHeight, OPENGL);

	RG.init(this);

	characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	shapes = new RShape[characters.length()];
	fontSize = 160;
	colNum = 6;

	font = new RFont("Brixton Medium.ttf", fontSize);

	for (int i = 0; i < characters.length(); i++) {
		shapes[i] = font.toShape(characters.charAt(i));
	}

	cp5 = new ControlP5(this);

	bgCp = cp5.addColorPicker("Background")
			  .setPosition(60, 60)
			  .setColorValue(color(255, 255, 255))
			  .setWidth(60)
			  .setColorLabel(color(0,0,0))
			  .setLabel("Background Color");
	fCp = cp5.addColorPicker("Fill")
			  .setPosition(60, 140)
			  .setColorValue(color(0, 0, 0, 0))
			  .setWidth(60)
			  .setColorLabel(color(0,0,0))
			  .setLabel("Fill Color");
	sCp = cp5.addColorPicker("Stroke")
			  .setPosition(60, 220)
			  .setColorValue(color(0, 0, 0, 255))
			  .setWidth(60)
			  .setColorLabel(color(0,0,0))
			  .setLabel("Stroke Color");

	cp5.addSlider("camX").setPosition(60,400).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));
	cp5.addSlider("camY").setPosition(60,420).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));
	cp5.addSlider("camZ").setPosition(60,440).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));	

	cp5.addSlider("rotX").setPosition(60,500).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));
	cp5.addSlider("rotY").setPosition(60,520).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));
	cp5.addSlider("rotZ").setPosition(60,540).setRange(0,360).setValue(0).setColorLabel(color(0,0,0));

	cp5.addSlider("sizeX").setPosition(60,580).setRange(1,50).setValue(2).setColorLabel(color(0,0,0));
	cp5.addSlider("sizeY").setPosition(60,600).setRange(1,50).setValue(2).setColorLabel(color(0,0,0));
	cp5.addSlider("arcEnd").setPosition(60,620).setRange(1,360).setValue(60).setColorLabel(color(0,0,0));

	cp5.addSlider("fluctuation").setPosition(60,660).setRange(1,5).setValue(2).setColorLabel(color(0,0,0));
	cp5.addSlider("fluctuationFrequency").setPosition(60,680).setRange(1,30).setValue(12).setColorLabel(color(0,0,0));

	radio = cp5.addRadioButton("shape")
		 .setNoneSelectedAllowed(false)
	     .setPosition(60, 320)
	     .setSize(10,10)
	     .setColorForeground(color(120))
	     .setColorActive(color(255))
	     .setColorLabel(color(0))
	     .setItemsPerRow(5)
	     .setSpacingColumn(50)
	     .addItem("Ellipse",1)
	     .addItem("Rect",2)
	     .addItem("Triangle",3)
	     .addItem("Arc",4)
	     .activate(2);

  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(60, 720)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(0))
                .setSize(10, 10)
                .setItemsPerRow(1)
                .setSpacingColumn(50)
                .setSpacingRow(10)
                .addItem("Fill Visible", 0)
                .addItem("Stroke Visible", 1)
                .addItem("Fluctuate Animation", 2)
                .addItem("Rotate Animation", 3);
    checkbox.activate(1);
}

void draw() {
	background(bgColor);

	stroke(strokeColor);
	fill(fillColor);

	if (!isFill) noFill();
	if (!isStroke) noStroke();

	int rotCount = 0;
	int fluctuationCount = 0;
	if (animateRotation) rotCount = frameCount;
	if (animateFluctuation) fluctuationCount = frameCount;

	rectMode(CENTER);

	pushMatrix();
	translate(500, fontSize * 1.7, 0);

	for (int i = 0; i < shapes.length; i++) {
		pushMatrix();
			
			translate(fontSize * (i%colNum), fontSize * int(i/colNum), 0);
			rotateX(map(camX, 0, 360, 0, TWO_PI));
			rotateY(map(camY, 0, 360, 0, TWO_PI));
			rotateZ(map(camZ, 0, 360, 0, TWO_PI));

			RPoint[] points = shapes[i].getPoints();
			for (int j = 0; j < points.length; ++j) {
				RPoint p = points[j];

				pushMatrix();
					translate(p.x, p.y, 0);
					rotateX(map(rotX, 0, 360, 0, TWO_PI));
					rotateY(map(rotY, 0, 360, 0, TWO_PI));
					rotateZ(map(rotZ + rotCount, 0, 360, 0, TWO_PI));
				
					float sX = sizeX + fluctuation * ((j + fluctuationCount)%fluctuationFrequency);
					float sY = sizeY + fluctuation * ((j + fluctuationCount)%fluctuationFrequency);
					
					if (currentShape == "Ellipse") {
						ellipse(0, 0, sX, sY);
					} else if (currentShape == "Rect") {
						rect(0, 0, sX, sY);
					} else if (currentShape == "Triangle") {
						triangle(cos(0) * sX, sin(0) * sY,
								 cos(radians(120)) * sX, sin(radians(120)) * sY,
								 cos(radians(240)) * sX, sin(radians(240)) * sY);
					} else if (currentShape == "Arc") {
						arc(0, 0, sX, sY, 0, radians(arcEnd));
					}

				popMatrix();
			}
		popMatrix();
	}
	popMatrix();
}

void keyPressed() {
	if (key == 's') {
		String fileName = hour() + "" + minute() + "" + second() + "" + frameCount + ".png";
		save(fileName);
	}
}

public void controlEvent(ControlEvent c) {
  if(c.isFrom(bgCp)) {
    int br = int(c.getArrayValue(0));
    int bg = int(c.getArrayValue(1));
    int bb = int(c.getArrayValue(2));
    bgColor = color(br,bg,bb);

  } else if (c.isFrom(fCp)) {
    int fr = int(c.getArrayValue(0));
    int fg = int(c.getArrayValue(1));
    int fb = int(c.getArrayValue(2));
    int fa = int(c.getArrayValue(3));
    fillColor = color(fr, fg, fb, fa);

  } else if (c.isFrom(sCp)) {
    int sr = int(c.getArrayValue(0));
    int sg = int(c.getArrayValue(1));
    int sb = int(c.getArrayValue(2));
    int sa = int(c.getArrayValue(3));
    strokeColor = color(sr, sg, sb, sa);

  }
}

public void shape(int i) {
	if (i == 1) currentShape = "Ellipse";
	if (i == 2) currentShape = "Rect";
	if (i == 3) currentShape = "Triangle";
	if (i == 4) currentShape = "Arc";
}

void checkBox(float[] a) {
	isFill = boolean((int)a[0]);
	isStroke = boolean((int)a[1]);
	animateRotation = boolean((int)a[2]);
	animateFluctuation = boolean((int)a[3]);
}
