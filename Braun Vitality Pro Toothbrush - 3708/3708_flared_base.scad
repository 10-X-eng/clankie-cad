// Toothbrush flared stabilizer charging boot
// Units: millimeters (mm)
//
// Revision: direct press-fit bottom target, 40 mm footprint, 20 mm height.
//
// What changed in this revision:
// - The older cumulative/axial seating-offset stack was removed.  It made the
//   file harder to understand and did not get the physical fit all the way there.
// - The bottom hole is now controlled by one direct, named target diameter:
//   bottom_socket_target_diameter_mm.
// - The latest real fit test says the toothbrush is still 0.67 mm from perfect
//   bottom alignment.  Pure taper math would only shrink the diameter by about
//   0.035 mm for that last 0.67 mm of seating correction.  The user clarified
//   that this must be a press-on stay-put fit, so this revision doubles that
//   extra reduction to about 0.070 mm.
// - Result: the bottom opening moves from the last-tested ~25.11 mm to about
//   25.04 mm.  No hidden positive clearance is added.
//
// Design intent:
// - The boot presses onto the tapered bottom of a toothbrush handle.
// - The toothbrush bottom must end flush with the boot bottom plane.  If the
//   toothbrush protrudes below the boot, the contact patch is not flat and the
//   assembly can still rock/tip.
// - The center bore is open from bottom to top so the toothbrush can still charge.
// - Four open-top slots give the sleeve enough compliance to press on while the
//   continuous lower ring keeps the stabilizing foot stiff.
// - The outside stays small: 40 mm diameter by 20 mm tall.
//
// Mechanical design gate / assumptions:
// 1) Function: stabilize a toothbrush standing vertically while preserving bottom
//    charging access.  Critical interfaces are the tapered inner socket and the
//    flat bottom plane.
// 2) Environment: bathroom counter, moisture/toothpaste residue, light hand loads.
// 3) Load path: tipping loads enter through the toothbrush taper, transfer into
//    the sleeve wall, then spread into the 40 mm circular foot.  The bottom ring
//    remains un-slotted to keep that load path continuous.
// 4) Material/process: assumed FDM plastic such as PLA/PETG, printed upright on
//    the flat bottom.  Minimum wall is kept above typical 3-perimeter FDM needs.
// 5) Tolerance/fit: user explicitly requested tight, zero-positive-clearance,
//    press-on behavior.  Therefore the printed socket is intentionally smaller
//    than the measured nominal toothbrush taper.  The measured nominal is still
//    kept as a separate source datum so the intentional interference is visible.

// ---------- Print/detail settings ----------
// A high facet count makes the revolved circular surfaces look round in STL.
facet_count = 160;
$fn = facet_count;

// Tiny overlap used only so boolean cutouts pass fully through faces.  This is
// not a clearance or fit allowance.
epsilon_mm = 0.02;

// Named constants keep the geometry readable and avoid hidden magic numbers.
full_circle_degrees = 360;
origin_mm = 0;
dimension_assert_tolerance_mm = 0.001;

// ---------- User measurement source data ----------
// Heights are measured upward from the very bottom of the toothbrush handle.
// Diameters are full outside diameters of the toothbrush taper.
measured_bottom_height_mm = 0.0;
measured_bottom_diameter_mm = 25.20;       // Earlier best-effort reading; history only.
nominal_bottom_taper_diameter_mm = 25.25;  // User-required nominal bottom taper datum.
measured_lower_height_mm = 5.0;
measured_lower_diameter_mm = 25.45;
measured_mid_height_mm = 15.0;
measured_mid_diameter_mm = 26.15;
measured_upper_height_mm = 25.0;
measured_upper_diameter_mm = 26.50;

// ---------- Nominal taper model ----------
// The toothbrush taper is represented as a straight diameter line:
//
//     nominal_diameter_at_z = nominal_bottom_taper_diameter + taper_slope * z
//
// The bottom datum is locked to the user-specified 25.25 mm.  Only the slope is
// fitted from the higher 5/15/25 mm measurements.  This keeps the measured bottom
// requirement sacred while smoothing the hand measurements into one usable taper.
fit_z2_sum_mm2 = (measured_lower_height_mm * measured_lower_height_mm)
               + (measured_mid_height_mm * measured_mid_height_mm)
               + (measured_upper_height_mm * measured_upper_height_mm);
fit_zd_delta_sum_mm2 = measured_lower_height_mm * (measured_lower_diameter_mm - nominal_bottom_taper_diameter_mm)
                     + measured_mid_height_mm * (measured_mid_diameter_mm - nominal_bottom_taper_diameter_mm)
                     + measured_upper_height_mm * (measured_upper_diameter_mm - nominal_bottom_taper_diameter_mm);

taper_diameter_slope_mm_per_mm = fit_zd_delta_sum_mm2 / fit_z2_sum_mm2;
taper_diameter_intercept_mm = nominal_bottom_taper_diameter_mm;

function nominal_toothbrush_diameter_at_z_mm(z_mm) = taper_diameter_intercept_mm + (taper_diameter_slope_mm_per_mm * z_mm);

// ---------- Direct press-fit calibration ----------
// The last tested CAD bottom opening was about 25.11 mm and was close, but the
// toothbrush still protruded 0.67 mm below the boot bottom.  To stop that last
// protrusion, the socket must catch the taper earlier, so the hole must get
// smaller.
//
// Pure taper correction:
//     diameter_change = taper_slope * remaining_axial_error
//
// Press-fit instruction from user:
//     double the reduction, because the boot should be pressed on and stay put.
//
// The result is intentionally a small but real diameter change:
//     25.11 - (taper_slope * 0.67 * 2) ~= 25.04 mm
//
// There are no old 1.61/1.08 mm cumulative seating offsets in this revision.
last_tested_bottom_socket_diameter_mm = 25.11;
latest_remaining_bottom_protrusion_mm = 0.67;
press_fit_reduction_multiplier = 2.0;
extra_bottom_diametral_reduction_mm = taper_diameter_slope_mm_per_mm
                                     * latest_remaining_bottom_protrusion_mm
                                     * press_fit_reduction_multiplier;
bottom_socket_target_diameter_mm = last_tested_bottom_socket_diameter_mm
                                  - extra_bottom_diametral_reduction_mm;

// This is the actual interference applied to the whole tapered socket.  Applying
// one constant diametral interference preserves the taper shape that already fit
// well, while shifting the socket smaller/tighter for bottom alignment.
socket_diametral_interference_mm = nominal_bottom_taper_diameter_mm
                                 - bottom_socket_target_diameter_mm;

function socket_diameter_at_z_mm(z_mm) = nominal_toothbrush_diameter_at_z_mm(z_mm)
                                       - socket_diametral_interference_mm;
function socket_radius_at_z_mm(z_mm) = socket_diameter_at_z_mm(z_mm) / 2;

// The actual modeled bottom opening.  This is the dimension to adjust next if a
// future physical test says it still needs more/less grip.  Lower number =
// smaller/tighter hole.  Higher number = looser hole.
actual_bottom_socket_diameter_mm = socket_diameter_at_z_mm(measured_bottom_height_mm);

// ---------- Stabilizing charging-boot envelope ----------
base_outer_diameter_mm = 40.0;             // Small footprint requested, still wider than toothbrush.
base_height_mm = 20.0;                     // Short sleeve height requested.
base_flat_foot_height_mm = 2.4;            // Continuous lower ring for stable bed/counter contact.
upper_straight_sleeve_height_mm = 5.0;     // Straight upper outside band after the flare.
minimum_top_wall_thickness_mm = 3.2;       // FDM-safe wall around the enlarged top lead-in.

base_outer_radius_mm = base_outer_diameter_mm / 2;
flare_start_z_mm = base_flat_foot_height_mm;
flare_end_z_mm = base_height_mm - upper_straight_sleeve_height_mm;

// ---------- Socket mouth and through-hole relief ----------
// The top lead-in helps start the tight press fit without scraping.  It is not
// the controlling fit feature; the bottom target diameter above is.
top_lead_in_depth_mm = 3.0;
top_lead_in_radial_extra_mm = 1.2;
top_lead_in_start_z_mm = base_height_mm - top_lead_in_depth_mm;
top_socket_mouth_radius_mm = socket_radius_at_z_mm(base_height_mm) + top_lead_in_radial_extra_mm;
top_socket_mouth_diameter_mm = top_socket_mouth_radius_mm * 2;

// Bottom of the socket is the flush-alignment datum.  It cuts all the way through
// the part so the toothbrush charger can contact the toothbrush bottom.
bottom_taper_anchor_z_mm = measured_bottom_height_mm;
bottom_taper_control_z_mm = base_flat_foot_height_mm;
bottom_socket_mouth_radius_mm = socket_radius_at_z_mm(bottom_taper_anchor_z_mm);
bottom_socket_mouth_diameter_mm = bottom_socket_mouth_radius_mm * 2;

// The top outside diameter follows the enlarged top mouth so the rim wall stays
// thick enough after the lead-in is cut.
top_outer_diameter_mm = top_socket_mouth_diameter_mm + (2 * minimum_top_wall_thickness_mm);
top_outer_radius_mm = top_outer_diameter_mm / 2;

// ---------- Flex / water relief slots ----------
// Four open-top slots add compliance for the press-on fit and provide drainage.
// They stop above the bottom ring so the base remains flat, continuous, and stiff.
relief_slot_count = 4;
relief_slot_width_mm = 4.0;
relief_slot_bottom_z_mm = 10.0;
relief_slot_inner_overshoot_mm = 0.6;
relief_slot_outer_overshoot_mm = 1.0;
relief_slot_height_mm = base_height_mm - relief_slot_bottom_z_mm + epsilon_mm;
relief_slot_length_mm = base_outer_radius_mm + relief_slot_outer_overshoot_mm + relief_slot_inner_overshoot_mm;

// ---------- Safety checks ----------
assert(base_outer_radius_mm > top_outer_radius_mm, "Base outer diameter must be larger than the top outside diameter.");
assert(base_outer_radius_mm > bottom_socket_mouth_radius_mm + 1.2, "Bottom foot ring must retain at least 1.2 mm radial wall for FDM printing.");
assert(flare_end_z_mm > flare_start_z_mm, "Base height must allow room for the foot and upper sleeve.");
assert(bottom_taper_control_z_mm < top_lead_in_start_z_mm, "Bottom taper segment and top lead-in must not overlap.");
assert(abs(nominal_toothbrush_diameter_at_z_mm(bottom_taper_anchor_z_mm) - nominal_bottom_taper_diameter_mm) < dimension_assert_tolerance_mm, "Nominal bottom taper datum must remain exactly the user-specified 25.25 mm.");
assert(abs(actual_bottom_socket_diameter_mm - bottom_socket_target_diameter_mm) < dimension_assert_tolerance_mm, "Actual bottom socket must equal the direct target diameter.");
assert(bottom_socket_target_diameter_mm < nominal_bottom_taper_diameter_mm, "Press-fit target must be smaller than the nominal measured toothbrush bottom diameter.");
assert(socket_diameter_at_z_mm(base_height_mm) > socket_diameter_at_z_mm(bottom_taper_anchor_z_mm), "Socket should widen upward for this toothbrush taper.");

module outer_flared_body() {
    // Outside profile: flat wide foot, inward flare, short straight upper sleeve.
    // rotate_extrude spins this radius-vs-height polygon around the Z axis.
    rotate_extrude(convexity = 10, $fn = facet_count)
        polygon(points = [
            [origin_mm, origin_mm],
            [base_outer_radius_mm, origin_mm],
            [base_outer_radius_mm, flare_start_z_mm],
            [top_outer_radius_mm, flare_end_z_mm],
            [top_outer_radius_mm, base_height_mm],
            [origin_mm, base_height_mm]
        ]);
}

module tapered_open_socket_cutout() {
    // Negative shape removed from the body.  It starts below and ends above the
    // part by epsilon_mm so the through-hole is clean with no membrane.
    //
    // The first functional radius is bottom_socket_mouth_radius_mm, which equals
    // the direct press-fit target diameter / 2.
    rotate_extrude(convexity = 10, $fn = facet_count)
        polygon(points = [
            [origin_mm, -epsilon_mm],
            [bottom_socket_mouth_radius_mm, -epsilon_mm],
            [bottom_socket_mouth_radius_mm, bottom_taper_anchor_z_mm],
            [socket_radius_at_z_mm(bottom_taper_control_z_mm), bottom_taper_control_z_mm],
            [socket_radius_at_z_mm(top_lead_in_start_z_mm), top_lead_in_start_z_mm],
            [top_socket_mouth_radius_mm, base_height_mm + epsilon_mm],
            [origin_mm, base_height_mm + epsilon_mm]
        ]);
}

module open_top_relief_slots() {
    // Rectangular cutters are rotated around the centerline to make four equally
    // spaced open-top slots.  They do not cut the bottom ring.
    for (slot_index = [0 : relief_slot_count - 1]) {
        rotate([origin_mm, origin_mm, slot_index * full_circle_degrees / relief_slot_count])
            translate([-relief_slot_inner_overshoot_mm,
                       -relief_slot_width_mm / 2,
                       relief_slot_bottom_z_mm])
                cube([relief_slot_length_mm, relief_slot_width_mm, relief_slot_height_mm]);
    }
}

module toothbrush_flared_base() {
    difference() {
        outer_flared_body();
        tapered_open_socket_cutout();
        open_top_relief_slots();
    }
}

toothbrush_flared_base();
