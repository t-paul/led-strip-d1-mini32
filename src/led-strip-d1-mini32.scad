// Wemos D1 Mini ESP32 box with button
//
// V1: will need lots of hot glue :-)
//
// Torsten Paul <Torsten.Paul@gmx.de>, October 2022
// CC BY-SA 4.0
// https://creativecommons.org/licenses/by-sa/4.0/

part = "assembly"; // [ "assembly", "box", "lid" ]

tolerance = 0.3;

wall = 1.6;

box_width = 50;
box_length = 75;
box_height = 25;
box_rounding = 4;

d1_mini_esp32_width = 31.4;
d1_mini_esp32_length = 38.6;
d1_mini_esp32_thickness = 1;
d1_mini_esp32_standoff = 3;

pcb_width = 20;
pcb_length = 50.6;
pcb_thickness = 1.7;

button_dia = 13.2;

usb_mini_h = 1.3;

module pcb() {
	w2 = pcb_width / 2;
	color("burlywood") translate([-w2, 0, 0])
		cube([pcb_width, pcb_length, pcb_thickness]);
	color("white") translate([-5, 1, pcb_thickness - eps])
		cube([10, 5.5, 7 + eps]);
	color("black") translate([0, 8, 5 + pcb_thickness - eps])
		rotate([-90, 0, 0]) cylinder(d = 10, h = 13);
}

module d1_mini_esp32(alpha = 1) {
	w2  = d1_mini_esp32_width / 2;
	color("green", alpha = alpha) render() difference() {
		translate([-w2, 0, 0])
			cube([d1_mini_esp32_width, d1_mini_esp32_length, d1_mini_esp32_thickness]);
		// reset button cutout
		translate([-w2, 0])
			cube([2 * 2.54, 14, 3], center = true);
		translate([-w2 - 1, d1_mini_esp32_length - 3, -1])
			rotate(45)
				cube([8, 8, 3]);
		translate([w2 + 1, d1_mini_esp32_length - 3, -1])
			rotate(45)
				cube([8, 8, 3]);
	}
	color("silver", alpha = alpha) translate([-7.5, 14, d1_mini_esp32_thickness - eps])
		cube([15, 17, 3.2]);
	color("black", alpha = alpha) translate([-9, 13.5, d1_mini_esp32_thickness - eps])
		cube([18, 25, 0.7]);
	color("silver", alpha = alpha) translate([-5, -1, d1_mini_esp32_thickness - eps])
		cube([10, 8, 2]);
}

module usb_micro_cutout(h = 10) {
	rotate([-90, 0, 0])
		translate([0, 0, -0.2])
			linear_extrude(h + 0.2)
				offset(1) offset(-1) square([12, 8], center = true);
}

module box_shape() {
	w2 = box_width / 2;
	offset(box_rounding)
		offset(-box_rounding)
			translate([-w2, 0])
				square([box_width, box_length]);
}

module pilar(d = 3) {
	h = box_height - wall - tolerance;
	f = function(a) (d / 2 + tolerance * sin(8 * a)) * [sin(a), cos(a)];
	difference() {
		cylinder(r = box_rounding, h = h);
		translate([0, 0, wall + eps])
			linear_extrude(h - wall)
				polygon([for (a = [0:$fa:359]) f(a)]);
	}
}

*lid();
module lid() {
	difference() {
		union() {
			linear_extrude(wall)
				offset(wall) box_shape();
			linear_extrude(2 * wall)
				offset(-tolerance) box_shape();
		}
		pilar_pos()
			cylinder(d = 3.2, h = 5 * wall, center = true);

		d = 5.2 + tolerance;
		pilar_pos(-eps)
			cylinder(d1 = d + 2 * tolerance, d2 = d, h = wall + eps);

		button_dia = 18;
		button_ring = 13.3 + tolerance;
		button_hole = 11.8 + 2 * tolerance;
		translate([0, box_length - 1 * button_dia, 0]) {
			cylinder(d = button_hole, h = 5 * wall, center = true);
			cylinder(d = button_ring, h = 2, center = true);
			translate([0, 0, 1]) cylinder(d1 = button_ring, d2 = button_hole, h = 1);
			translate([0, 0, 3]) cylinder(d = button_dia, h = 5 * wall);
		}
	}
}

module pilar_pos(z = 0) {
	translate([-box_width / 2 + box_rounding - tolerance, box_rounding + tolerance, z])
		children();
	translate([box_width / 2 - box_rounding + tolerance, box_rounding + tolerance, z])
		children();
	translate([-box_width / 2 + box_rounding - tolerance, box_length - box_rounding + tolerance, z])
		children();
	translate([box_width / 2 - box_rounding + tolerance, box_length - box_rounding + tolerance, z])
		children();
}

module box() {
	difference() {
		union() {
			linear_extrude(wall)
				box_shape();
			linear_extrude(box_height + wall, convexity = 3) difference() {
				offset(wall) box_shape();
				box_shape();
			}
		}
		
		translate([0, -wall, wall + usb_mini_h + d1_mini_esp32_thickness + d1_mini_esp32_standoff])
			usb_micro_cutout();
		// size works for the JST/XT 3-Pin too
		translate([0, box_length, wall + usb_mini_h + d1_mini_esp32_thickness + d1_mini_esp32_standoff])
			usb_micro_cutout();
	}
	w2 = d1_mini_esp32_width / 2;
	translate([-wall/2 - w2, 0, wall - eps])
		cube([wall, d1_mini_esp32_length, d1_mini_esp32_standoff + eps]);
	translate([-wall/2 + w2, 0, wall - eps])
		cube([wall, d1_mini_esp32_length, d1_mini_esp32_standoff + eps]);
	translate([-wall - w2, 0, wall - eps])
		cube([wall, d1_mini_esp32_length, d1_mini_esp32_standoff + wall]);
	translate([w2, 0, wall - eps])
		cube([wall, d1_mini_esp32_length, d1_mini_esp32_standoff + wall]);
	translate([-d1_mini_esp32_width / 4, d1_mini_esp32_length + tolerance, wall - eps])
		cube([d1_mini_esp32_width / 2, 2 * wall, d1_mini_esp32_standoff + 2 * wall]);
	pilar_pos(wall - eps) pilar();
}

intersection() {
	if (part == "box") {
		box();
	} else if (part == "lid") {
		lid();
	} else {
		box();
		translate([0, 0, 70]) rotate([0, 180, 0]) lid();
		%translate([0, 0, wall + d1_mini_esp32_standoff]) d1_mini_esp32();
		%translate([-20, 65, pcb_width / 2 + wall]) rotate([180, 270, 0]) pcb();
	}
}

$fa = 4; $fs = 0.2;
eps = 0.01;
