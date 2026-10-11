extends Control

const SLOTS := 32
const R_BASE := 90.0
const R_STEP := 50.0
const PANEL_W := 340.0
const A0_PM := 52.9
const MAX_RESULTS := 6
# spellings that differ from the names stored in DATA
const ALIASES := {"aluminum": "al", "cesium": "cs", "sulphur": "s"}

const ZOOM_MIN := 0.7
const ZOOM_MAX := 6.0
const DRAG_THRESHOLD := 5.0
const MAX_COMPOUNDS := 4
const HOVER_GRACE := 0.16   # seconds a hover lingers when crossing gaps

# Measured covalent radii in pm (Cordero et al., 2008), indexed by Z-1.
# Mn/Fe/Co use the low-spin values. Z > 96 has no published value.
const COV_RADII := [
	31, 28, 128, 96, 84, 76, 71, 66, 57, 58,
	166, 141, 121, 111, 107, 105, 102, 106, 203, 176,
	170, 160, 153, 139, 139, 132, 126, 124, 132, 122,
	122, 120, 119, 120, 120, 116, 220, 195, 190, 175,
	164, 154, 147, 146, 142, 139, 145, 144, 142, 139,
	139, 138, 139, 140, 244, 215, 207, 204, 203, 201,
	199, 198, 198, 196, 194, 192, 192, 189, 190, 187,
	187, 175, 170, 162, 151, 144, 141, 136, 136, 132,
	145, 146, 148, 140, 150, 150, 260, 221, 215, 206,
	200, 196, 190, 187, 180, 169,
]

# Common oxidation states, most common first (negative = typical anion charge)
const OXIDATION := {
	1: [1, -1], 2: [], 3: [1], 4: [2], 5: [3], 6: [4, -4, 2], 7: [-3, 3, 5, 2, 4],
	8: [-2, -1], 9: [-1], 10: [], 11: [1], 12: [2], 13: [3], 14: [4, -4],
	15: [-3, 3, 5], 16: [-2, 4, 6], 17: [-1, 1, 3, 5, 7], 18: [], 19: [1], 20: [2],
	21: [3], 22: [4, 3, 2], 23: [5, 4, 3, 2], 24: [3, 6, 2], 25: [2, 4, 7, 3, 6],
	26: [3, 2], 27: [2, 3], 28: [2, 3], 29: [2, 1], 30: [2], 31: [3], 32: [4, 2],
	33: [-3, 3, 5], 34: [-2, 4, 6], 35: [-1, 1, 3, 5, 7], 36: [2], 37: [1], 38: [2],
	39: [3], 40: [4], 41: [5, 3], 42: [6, 4, 3], 43: [7, 4], 44: [3, 4, 8], 45: [3],
	46: [2, 4], 47: [1], 48: [2], 49: [3], 50: [4, 2], 51: [-3, 3, 5], 52: [-2, 4, 6],
	53: [-1, 1, 5, 7], 54: [2, 4, 6], 55: [1], 56: [2], 57: [3], 58: [3, 4], 59: [3],
	60: [3], 61: [3], 62: [3, 2], 63: [3, 2], 64: [3], 65: [3], 66: [3], 67: [3],
	68: [3], 69: [3], 70: [3, 2], 71: [3], 72: [4], 73: [5], 74: [6, 4], 75: [7, 4, 6],
	76: [4, 8], 77: [3, 4], 78: [2, 4], 79: [3, 1], 80: [2, 1], 81: [1, 3], 82: [2, 4],
	83: [3, 5], 84: [4, 2], 85: [-1, 1], 86: [], 87: [1], 88: [2], 89: [3], 90: [4],
	91: [5, 4], 92: [6, 4, 3, 5], 93: [5, 4, 6, 3], 94: [4, 3, 6, 5], 95: [3, 4, 5, 6],
	96: [3], 97: [3, 4], 98: [3], 99: [3], 100: [3], 101: [3, 2], 102: [2, 3], 103: [3],
}

const BLOCK_COLORS := {
	"s": Color("ff6b57"),
	"p": Color("38c9a0"),
	"d": Color("4895ef"),
	"f": Color("f4b942"),
}
const BLOCK_RANGES := {"s": [0, 2], "f": [2, 16], "d": [16, 26], "p": [26, 32]}

const REL_COLORS := {
	"group": Color("ffffff"),
	"diagonal": Color("ffd23f"),
	"twin": Color("3ddc84"),
	"opposite": Color("ff4d4d"),
}
const DIAGONALS := [[3, 12], [4, 13], [5, 14]]  # Li-Mg, Be-Al, B-Si

# Slater effective principal quantum numbers
const N_STAR := {1: 1.0, 2: 2.0, 3: 3.0, 4: 3.7, 5: 4.0, 6: 4.2, 7: 4.3}

const PERIOD_START := [1, 3, 11, 19, 37, 55, 87]

# Madelung (n + l) filling order
const ORBITALS := ["1s", "2s", "2p", "3s", "3p", "4s", "3d", "4p", "5s", "4d",
	"5p", "6s", "4f", "5d", "6p", "7s", "5f", "6d", "7p"]
const CAP := {"s": 2, "p": 6, "d": 10, "f": 14}
# [Z, symbol, number of ORBITALS covered by the core]
const NOBLE_CORES := [[86, "Rn", 15], [54, "Xe", 11], [36, "Kr", 8],
	[18, "Ar", 5], [10, "Ne", 3], [2, "He", 1]]

# Ground-state exceptions to the Madelung rule
const EXCEPTIONS := {
	24: {"4s": 1, "3d": 5}, 29: {"4s": 1, "3d": 10},
	41: {"5s": 1, "4d": 4}, 42: {"5s": 1, "4d": 5}, 44: {"5s": 1, "4d": 7},
	45: {"5s": 1, "4d": 8}, 46: {"5s": 0, "4d": 10}, 47: {"5s": 1, "4d": 10},
	57: {"4f": 0, "5d": 1}, 58: {"4f": 1, "5d": 1}, 64: {"4f": 7, "5d": 1},
	78: {"6s": 1, "5d": 9}, 79: {"6s": 1, "5d": 10},
	89: {"5f": 0, "6d": 1}, 90: {"5f": 0, "6d": 2}, 91: {"5f": 2, "6d": 1},
	92: {"5f": 3, "6d": 1}, 93: {"5f": 4, "6d": 1}, 96: {"5f": 7, "6d": 1},
	103: {"6d": 0, "7p": 1},
}

# Symbol, Name, Atomic mass, Electronegativity (Pauling, 0 = none/unknown)
const DATA := [
	"H,Hydrogen,1.008,2.20", "He,Helium,4.0026,0", "Li,Lithium,6.94,0.98",
	"Be,Beryllium,9.0122,1.57", "B,Boron,10.81,2.04", "C,Carbon,12.011,2.55",
	"N,Nitrogen,14.007,3.04", "O,Oxygen,15.999,3.44", "F,Fluorine,18.998,3.98",
	"Ne,Neon,20.180,0", "Na,Sodium,22.990,0.93", "Mg,Magnesium,24.305,1.31",
	"Al,Aluminium,26.982,1.61", "Si,Silicon,28.085,1.90", "P,Phosphorus,30.974,2.19",
	"S,Sulfur,32.06,2.58", "Cl,Chlorine,35.45,3.16", "Ar,Argon,39.948,0",
	"K,Potassium,39.098,0.82", "Ca,Calcium,40.078,1.00", "Sc,Scandium,44.956,1.36",
	"Ti,Titanium,47.867,1.54", "V,Vanadium,50.942,1.63", "Cr,Chromium,51.996,1.66",
	"Mn,Manganese,54.938,1.55", "Fe,Iron,55.845,1.83", "Co,Cobalt,58.933,1.88",
	"Ni,Nickel,58.693,1.91", "Cu,Copper,63.546,1.90", "Zn,Zinc,65.38,1.65",
	"Ga,Gallium,69.723,1.81", "Ge,Germanium,72.630,2.01", "As,Arsenic,74.922,2.18",
	"Se,Selenium,78.971,2.55", "Br,Bromine,79.904,2.96", "Kr,Krypton,83.798,3.00",
	"Rb,Rubidium,85.468,0.82", "Sr,Strontium,87.62,0.95", "Y,Yttrium,88.906,1.22",
	"Zr,Zirconium,91.224,1.33", "Nb,Niobium,92.906,1.6", "Mo,Molybdenum,95.95,2.16",
	"Tc,Technetium,98,1.9", "Ru,Ruthenium,101.07,2.2", "Rh,Rhodium,102.91,2.28",
	"Pd,Palladium,106.42,2.20", "Ag,Silver,107.87,1.93", "Cd,Cadmium,112.41,1.69",
	"In,Indium,114.82,1.78", "Sn,Tin,118.71,1.96", "Sb,Antimony,121.76,2.05",
	"Te,Tellurium,127.60,2.1", "I,Iodine,126.90,2.66", "Xe,Xenon,131.29,2.6",
	"Cs,Caesium,132.91,0.79", "Ba,Barium,137.33,0.89", "La,Lanthanum,138.91,1.10",
	"Ce,Cerium,140.12,1.12", "Pr,Praseodymium,140.91,1.13", "Nd,Neodymium,144.24,1.14",
	"Pm,Promethium,145,1.13", "Sm,Samarium,150.36,1.17", "Eu,Europium,151.96,1.2",
	"Gd,Gadolinium,157.25,1.2", "Tb,Terbium,158.93,1.1", "Dy,Dysprosium,162.50,1.22",
	"Ho,Holmium,164.93,1.23", "Er,Erbium,167.26,1.24", "Tm,Thulium,168.93,1.25",
	"Yb,Ytterbium,173.05,1.1", "Lu,Lutetium,174.97,1.27", "Hf,Hafnium,178.49,1.3",
	"Ta,Tantalum,180.95,1.5", "W,Tungsten,183.84,2.36", "Re,Rhenium,186.21,1.9",
	"Os,Osmium,190.23,2.2", "Ir,Iridium,192.22,2.20", "Pt,Platinum,195.08,2.28",
	"Au,Gold,196.97,2.54", "Hg,Mercury,200.59,2.00", "Tl,Thallium,204.38,1.62",
	"Pb,Lead,207.2,2.33", "Bi,Bismuth,208.98,2.02", "Po,Polonium,209,2.0",
	"At,Astatine,210,2.2", "Rn,Radon,222,2.2", "Fr,Francium,223,0.7",
	"Ra,Radium,226,0.9", "Ac,Actinium,227,1.1", "Th,Thorium,232.04,1.3",
	"Pa,Protactinium,231.04,1.5", "U,Uranium,238.03,1.38", "Np,Neptunium,237,1.36",
	"Pu,Plutonium,244,1.28", "Am,Americium,243,1.13", "Cm,Curium,247,1.28",
	"Bk,Berkelium,247,1.3", "Cf,Californium,251,1.3", "Es,Einsteinium,252,1.3",
	"Fm,Fermium,257,1.3", "Md,Mendelevium,258,1.3", "No,Nobelium,259,1.3",
	"Lr,Lawrencium,266,1.3", "Rf,Rutherfordium,267,0", "Db,Dubnium,268,0",
	"Sg,Seaborgium,269,0", "Bh,Bohrium,270,0", "Hs,Hassium,277,0",
	"Mt,Meitnerium,278,0", "Ds,Darmstadtium,281,0", "Rg,Roentgenium,282,0",
	"Cn,Copernicium,285,0", "Nh,Nihonium,286,0", "Fl,Flerovium,289,0",
	"Mc,Moscovium,290,0", "Lv,Livermorium,293,0", "Ts,Tennessine,294,0",
	"Og,Oganesson,294,0",
]

var elements: Array = []
var rel: Dictionary = {}    # element index -> relation kind
var hovered := -1
var selected := -1
var mode := 0               # 0 block, 1 EN, 2 Zeff, 3 radius
var t := 0.0
var font: Font

var center := Vector2.ZERO
var sc := 1.0
var _py := 0.0

var search: LineEdit
var search_hits: Array = []        # element indices matching the query
var search_idx := 0                # highlighted row in the results list
var _result_rects: Array = []      # Rect2 per visible result row

var z_min := 99.0
var z_max := 0.0
var r_min := 99999.0
var r_max := 0.0
var c_min := 99999.0        # measured covalent radius range
var c_max := 0.0
var radius_corr := 0.0      # Pearson r between Slater estimate and measured

# view transform (zoom / pan)
var zoom := 1.0
var pan := Vector2.ZERO
var base_sc := 1.0
var press_active := false
var press_pos := Vector2.ZERO
var drag_moved := false
var view_anim := 0          # 0 idle, 1 eased zoom about the cursor, 2 glide to a target view
var zoom_target := 1.0
var zoom_anchor := Vector2.ZERO
var pan_target := Vector2.ZERO
var pan_vel := Vector2.ZERO
var last_drag_ms := 0

# eased animation state (updated every frame in _process)
var alpha_cur := PackedFloat32Array()
var scale_cur := PackedFloat32Array()
var col_cur := PackedColorArray()
var intro_t := 0.0
var chord_t := 1.0          # 0 -> 1 after the focused element changes
var pair_t := 1.0           # 0 -> 1 after the bond partner changes
var detail_fade := 1.0
var hub_idx := -1
var hub_mix := 0.0
var hub_pop := 1.0
var hover_eff := -1         # hover with a short grace period
var hover_timer := 0.0
var tip_idx := -1
var tip_a := 0.0
var _last_active := -2
var _last_pair := -2
var _pa := 1.0              # alpha multiplier for the panel detail block


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	font = ThemeDB.fallback_font
	_build_elements()
	_build_search()


func _process(delta: float) -> void:
	t += delta
	intro_t += delta
	_update_hover(delta)
	_sync_focus()
	_update_anim(delta)
	_update_view(delta)
	_update_cursor()
	queue_redraw()


# ============================================================= data ======

func _build_elements() -> void:
	for i in DATA.size():
		var p: PackedStringArray = DATA[i].split(",")
		var z := i + 1
		var cr := _grid_pos(z)
		var slot := 0
		var period := cr.y
		var block := "p"
		var col := cr.x
		if cr.y >= 9:                    # f-block rows
			slot = cr.x - 1
			period = cr.y - 3
			block = "f"
			col = 0
		elif cr.x <= 2:
			slot = cr.x - 1
			block = "s"
		elif cr.x <= 12:
			slot = 13 + cr.x
			block = "d"
		else:
			slot = 13 + cr.x
			block = "p"

		var cfg := _config(z)
		var shells := _shells(cfg)
		var zr := _zeff(z, cfg)
		var zeff: float = zr.x
		var n_top: int = int(zr.y)
		var ns: float = N_STAR[n_top]
		var radius: float = A0_PM * ns * ns / zeff

		var val := -1
		match block:
			"s": val = slot + 1
			"d": val = slot - 13
			"p": val = slot - 23
		if z == 2:
			val = 2

		z_min = minf(z_min, zeff)
		z_max = maxf(z_max, zeff)
		r_min = minf(r_min, radius)
		r_max = maxf(r_max, radius)

		var cov := 0.0
		if i < COV_RADII.size():
			cov = float(COV_RADII[i])
		if cov > 0.0:
			c_min = minf(c_min, cov)
			c_max = maxf(c_max, cov)

		elements.append({
			"z": z, "sym": p[0], "name": p[1], "mass": float(p[2]),
			"en": float(p[3]), "cat": _category(z),
			"slot": slot, "period": period, "block": block, "col": col,
			"cfg": cfg, "cfg_str": _config_string(z, cfg), "shells": shells,
			"zeff": zeff, "radius": radius, "val": val,
			"cov": cov, "ox": OXIDATION.get(z, []),
		})

	_calc_radius_corr()
	_init_anim()


# Long-form layout helper: returns (column, row); rows 9/10 are the f-block
func _grid_pos(z: int) -> Vector2i:
	if z == 1:
		return Vector2i(1, 1)
	if z == 2:
		return Vector2i(18, 1)
	var period := 1
	for i in PERIOD_START.size():
		if z >= PERIOD_START[i]:
			period = i + 1
	var n: int = z - PERIOD_START[period - 1]
	if period == 2 or period == 3:
		return Vector2i(n + 1 if n < 2 else n + 11, period)
	if period == 4 or period == 5:
		return Vector2i(n + 1, period)
	if n < 2:
		return Vector2i(n + 1, period)
	if n < 16:
		return Vector2i(n + 1, 9 if period == 6 else 10)
	if n == 16:
		return Vector2i(3, period)
	return Vector2i(n - 13, period)


func _category(z: int) -> String:
	if z in [3, 11, 19, 37, 55, 87]: return "Alkali metal"
	if z in [4, 12, 20, 38, 56, 88]: return "Alkaline earth"
	if z >= 57 and z <= 71: return "Lanthanide"
	if z >= 89 and z <= 103: return "Actinide"
	if z in [9, 17, 35, 53, 85, 117]: return "Halogen"
	if z in [2, 10, 18, 36, 54, 86, 118]: return "Noble gas"
	if z in [5, 14, 32, 33, 51, 52]: return "Metalloid"
	if z in [1, 6, 7, 8, 15, 16, 34]: return "Nonmetal"
	if z in [13, 31, 49, 50, 81, 82, 83, 84, 113, 114, 115, 116]: return "Post-transition"
	return "Transition metal"


# ====================================================== calculations =====

func _config(z: int) -> Dictionary:
	var cfg := {}
	var left := z
	for orb in ORBITALS:
		var cap: int = CAP[String(orb).substr(1, 1)]
		var c := mini(left, cap)
		cfg[orb] = c
		left -= c
	if EXCEPTIONS.has(z):
		var ex: Dictionary = EXCEPTIONS[z]
		for orb in ex:
			cfg[orb] = ex[orb]
	return cfg


func _shells(cfg: Dictionary) -> Array:
	var sh := [0, 0, 0, 0, 0, 0, 0, 0]   # index 1..7 used
	for orb in cfg:
		sh[int(String(orb).substr(0, 1))] += int(cfg[orb])
	return sh


func _config_string(z: int, cfg: Dictionary) -> String:
	var start := 0
	var core := ""
	for nc in NOBLE_CORES:
		if z > nc[0]:
			core = nc[1]
			start = nc[2]
			break
	var parts: PackedStringArray = []
	if core != "":
		parts.append("[%s]" % core)
	for i in range(start, ORBITALS.size()):
		var c: int = cfg[ORBITALS[i]]
		if c > 0:
			parts.append("%s%d" % [ORBITALS[i], c])
	return " ".join(parts)


# Slater group key: n*10 + (0 = s/p, 1 = d, 2 = f)
func _group_key(orb: String) -> int:
	var n := int(orb.substr(0, 1))
	var l := orb.substr(1, 1)
	var typ := 0
	if l == "d":
		typ = 1
	elif l == "f":
		typ = 2
	return n * 10 + typ


# Returns Vector2(Zeff, n) for the outermost electron (Slater's rules)
func _zeff(z: int, cfg: Dictionary) -> Vector2:
	var groups := {}
	for orb in cfg:
		var k := _group_key(orb)
		groups[k] = int(groups.get(k, 0)) + int(cfg[orb])
	var top := 0
	for k in groups:
		if int(groups[k]) > 0 and int(k) > top:
			top = int(k)
	var n: int = floori(top / 10.0)
	var typ: int = top % 10
	var n_top: int = int(groups[top])
	var same := 0.30 if n == 1 else 0.35
	var s: float = same * (n_top - 1)
	for k in groups:
		var kk: int = int(k)
		if kk == top:
			continue
		var cnt: int = int(groups[k])
		var kn: int = floori(kk / 10.0)
		if typ == 0:
			if kn == n - 1:
				s += 0.85 * cnt
			elif kn < n - 1:
				s += 1.0 * cnt
		elif kk < top:
			s += 1.0 * cnt
	return Vector2(z - s, n)


func _is_metal(e: Dictionary) -> bool:
	return e.cat in ["Alkali metal", "Alkaline earth", "Transition metal",
		"Post-transition", "Lanthanide", "Actinide"]


func _cation_charge(e: Dictionary) -> int:
	if e.z == 1:
		return 0
	if e.block == "s":
		return e.val
	if e.block == "p" and e.col == 13:
		return 3
	if e.block == "d":
		return 2          # typical; transition metals are variable
	return 0


func _anion_charge(e: Dictionary) -> int:
	if e.block == "p" and e.col in [15, 16, 17]:
		return 18 - int(e.col)
	return 0


func _bond_cap(e: Dictionary) -> int:
	if e.z == 1:
		return 1
	if e.block == "p" and e.col >= 13 and e.col <= 17:
		if e.col == 13:
			return 3
		if e.col == 14:
			return 4
		return 18 - int(e.col)
	return 0


func _gcd(a: int, b: int) -> int:
	while b != 0:
		var tmp := b
		b = a % b
		a = tmp
	return a


func _predict_formula(a: Dictionary, b: Dictionary, ionic: bool) -> String:
	var lo: Dictionary = a if a.en <= b.en else b
	var hi: Dictionary = b if a.en <= b.en else a
	var x := 0
	var y := 0
	if ionic:
		x = _cation_charge(lo)
		y = _anion_charge(hi)
	else:
		x = _bond_cap(lo)
		y = _bond_cap(hi)
		# conventional writing order: CH4, NH3, PH3 instead of H4C ...
		if lo.sym == "H" and hi.col >= 13 and hi.col <= 15:
			var swap := lo
			lo = hi
			hi = swap
			var sw := x
			x = y
			y = sw
	if x <= 0 or y <= 0:
		return ""
	var g := _gcd(x, y)
	var n_lo: int = floori(y / float(g))
	var n_hi: int = floori(x / float(g))
	return "%s%s%s%s" % [lo.sym, str(n_lo) if n_lo > 1 else "",
		hi.sym, str(n_hi) if n_hi > 1 else ""]


func _bond_info(a: Dictionary, b: Dictionary) -> Dictionary:
	var info := {"type": "", "color": Color.WHITE, "den": 0.0, "ionic": 0.0,
		"formula": "", "compounds": []}
	if _is_metal(a) and _is_metal(b):
		info.type = "Metallic (delocalised electrons)"
		info.color = Color("b8c0d0")
		return info
	if a.en <= 0.0 or b.en <= 0.0:
		info.type = "No electronegativity data"
		info.color = Color("6b7186")
		return info
	var den: float = absf(a.en - b.en)
	info.den = den
	info.ionic = (1.0 - exp(-0.25 * den * den)) * 100.0
	if den >= 1.7:
		info.type = "Ionic"
		info.color = Color("ff7a45")
	elif den >= 0.4:
		info.type = "Polar covalent"
		info.color = Color("ffd23f")
	else:
		info.type = "Nonpolar covalent"
		info.color = Color("3ddc84")
	var comps := _predict_compounds(a, b)
	if comps.is_empty():
		var f := _predict_formula(a, b, den >= 1.7)
		if f != "":
			comps.append({"formula": f, "note": "valence rule"})
	info.compounds = comps
	return info


# ======================================================= relations =======

func _active() -> int:
	return selected if selected != -1 else hover_eff


func _pair() -> int:
	if selected != -1 and hover_eff != -1 and hover_eff != selected:
		return hover_eff
	return -1


func _refresh() -> void:
	rel.clear()
	var i := _active()
	if i == -1:
		return
	var e: Dictionary = elements[i]
	# Same spoke = same group
	for j in elements.size():
		if j != i and elements[j].slot == e.slot:
			rel[j] = "group"
	# Diagonal relationships
	for pair in DIAGONALS:
		if e.z == pair[0]:
			rel[pair[1] - 1] = "diagonal"
		elif e.z == pair[1]:
			rel[pair[0] - 1] = "diagonal"
	# Electronegativity twins / opposites
	if e.en > 0.0:
		var cands: Array = []
		for j in elements.size():
			if j == i or rel.has(j) or elements[j].en <= 0.0:
				continue
			cands.append([absf(elements[j].en - e.en), j])
		cands.sort_custom(func(a, b): return a[0] < b[0])
		for k in mini(3, cands.size()):
			rel[cands[k][1]] = "twin"
		cands.sort_custom(func(a, b): return a[0] > b[0])
		var added := 0
		for c in cands:
			if added >= 3:
				break
			if not rel.has(c[1]):
				rel[c[1]] = "opposite"
				added += 1
	var pr := _pair()
	if pr != -1:
		rel[pr] = "pair"


# ========================================================== input ========

func _layout() -> void:
	var avail := Vector2(size.x - PANEL_W, size.y)
	# full wheel incl. rim labels is ~935 units across; 980 leaves a margin
	base_sc = clampf(minf(avail.x, avail.y) / 980.0, 0.3, 2.0)
	sc = base_sc * zoom
	center = Vector2(PANEL_W + avail.x * 0.5, size.y * 0.5) + pan


func _slot_angle(slot: float) -> float:
	return -PI / 2.0 + slot / SLOTS * TAU


func _ring_r(period: int) -> float:
	return R_BASE + R_STEP * (period - 1)


func _node_pos(e: Dictionary) -> Vector2:
	return center + Vector2.from_angle(_slot_angle(e.slot + 0.5)) * _ring_r(e.period) * sc


func _node_r(e: Dictionary) -> float:
	var spacing := TAU * _ring_r(e.period) / SLOTS
	return clampf(spacing * 0.46, 8.0, 22.0) * sc


func _pick(pos: Vector2) -> int:
	if pos.x < PANEL_W:
		return -1
	var best := -1
	var best_d := 1e9
	for i in elements.size():
		var d := pos.distance_to(_node_pos(elements[i]))
		if d <= _node_r(elements[i]) + 3.0 and d < best_d:
			best = i
			best_d = d
	return best


func _gui_input(event: InputEvent) -> void:
	_layout()
	if event is InputEventMouseMotion:
		if press_active and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if not drag_moved and event.position.distance_to(press_pos) > DRAG_THRESHOLD:
				drag_moved = true
				view_anim = 0
			if drag_moved:
				# track velocity so the view keeps gliding after release
				var now := Time.get_ticks_msec()
				var dt := maxf(float(now - last_drag_ms) / 1000.0, 0.001)
				pan_vel = pan_vel.lerp(event.relative / dt, 0.4).limit_length(4000.0)
				last_drag_ms = now
				pan = (pan + event.relative).limit_length(460.0 * sc)
				return
		var k := _row_at(event.position)
		var h := -1
		if k != -1:
			search_idx = k
			h = search_hits[k]
		else:
			h = _pick(event.position)
		if h != hovered:
			hovered = h
			_refresh()
	elif event is InputEventMouseButton:
		var bi: int = event.button_index
		if bi == MOUSE_BUTTON_WHEEL_UP or bi == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed and event.position.x >= PANEL_W:
				_zoom_at(event.position, 1.15 if bi == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15)
				var hw := _pick(event.position)
				if hw != hovered:
					hovered = hw
					_refresh()
		elif bi == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var kr := _row_at(event.position)
				if kr != -1:
					search_idx = kr
					_commit_search()
					return
				if search.has_focus():
					search.release_focus()
				press_active = event.position.x >= PANEL_W
				press_pos = event.position
				drag_moved = false
				pan_vel = Vector2.ZERO
				last_drag_ms = Time.get_ticks_msec()
			else:
				# a click (no drag) selects; a drag only pans
				if Time.get_ticks_msec() - last_drag_ms > 90:
					pan_vel = Vector2.ZERO   # held still before release: no glide
				if press_active and not drag_moved:
					var hc := _pick(event.position)
					selected = -1 if hc == selected else hc
					_refresh()
				press_active = false
				drag_moved = false
		elif bi == MOUSE_BUTTON_RIGHT and event.pressed:
			selected = -1
			_refresh()
		elif bi == MOUSE_BUTTON_MIDDLE and event.pressed:
			_reset_view()
	elif event is InputEventMagnifyGesture:      # trackpad pinch
		_zoom_at(event.position, event.factor)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F and event.is_command_or_control_pressed():
			search.grab_focus.call_deferred()
			get_viewport().set_input_as_handled()
			return
		match event.keycode:
			KEY_SLASH:
				search.grab_focus.call_deferred()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				selected = -1
				_refresh()
			KEY_1: mode = 0
			KEY_2: mode = 1
			KEY_3: mode = 2
			KEY_4: mode = 3
			KEY_5: mode = 4
			KEY_EQUAL, KEY_KP_ADD:
				_zoom_at(center, 1.25)
			KEY_MINUS, KEY_KP_SUBTRACT:
				_zoom_at(center, 1.0 / 1.25)
			KEY_R, KEY_HOME:
				_reset_view()


# ========================================================= drawing =======

func _ramp(u: float) -> Color:
	return Color.from_hsv(lerpf(0.72, 0.06, clampf(u, 0.0, 1.0)), 0.8, 0.95)


func _node_color(e: Dictionary) -> Color:
	match mode:
		0:
			return BLOCK_COLORS[e.block]
		1:
			if e.en <= 0.0:
				return Color("4a4f63")
			return _ramp(e.en / 4.0)
		2:
			return _ramp((e.zeff - z_min) / (z_max - z_min))
		3:
			if e.cov <= 0.0:
				return Color("4a4f63")
			return _ramp((e.cov - c_min) / (c_max - c_min))
	return _ramp((e.radius - r_min) / (r_max - r_min))


func _ctext(txt: String, pos: Vector2, fs: int, color: Color) -> void:
	fs = maxi(fs, 6)
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, pos + Vector2(-w * 0.5, fs * 0.35), txt,
		HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)


func _chord(a: Vector2, b: Vector2) -> PackedVector2Array:
	# curves bend toward the hub, like a chord diagram
	var mid := (a + b) * 0.5
	var ctrl := center + (mid - center) * 0.2
	var pts := PackedVector2Array()
	for s in 41:
		var u := s / 40.0
		pts.append(a.lerp(ctrl, u).lerp(ctrl.lerp(b, u), u))
	return pts


func _draw() -> void:
	_layout()
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b0e1a"))
	for k in 7:
		draw_circle(center, (460.0 - k * 55.0) * sc, Color(0.25, 0.35, 0.75, 0.018))

	var active := _active()
	var pair := _pair()

	_draw_geometry(active)
	_draw_hub(active)
	if active != -1:
		_draw_chords(active)
	if active != -1 and pair != -1:
		_draw_pair_line(active, pair)
	_draw_nodes(active)
	if active != -1:
		_draw_dots(active)
	_draw_tooltip()
	_draw_panel(active, pair)


func _draw_geometry(active: int) -> void:
	var r_out := (R_BASE + 6.0 * R_STEP + 30.0) * sc
	# slot spokes (block boundaries are brighter)
	for s in SLOTS:
		var strong := s in [0, 2, 16, 26]
		var dir := Vector2.from_angle(_slot_angle(float(s)))
		draw_line(center + dir * (R_BASE - 16.0) * sc, center + dir * r_out,
			Color(1, 1, 1, 0.16 if strong else 0.04), 1.0)
	# period rings
	for p in range(1, 8):
		draw_arc(center, _ring_r(p) * sc, 0.0, TAU, 160, Color(1, 1, 1, 0.07), 1.0, true)
	# block arcs on the rim
	var band_r := (R_BASE + 6.0 * R_STEP + 38.0) * sc
	for b in BLOCK_RANGES:
		var rng: Array = BLOCK_RANGES[b]
		var s0: int = rng[0]
		var s1: int = rng[1]
		var bcol: Color = BLOCK_COLORS[b]
		draw_arc(center, band_r, _slot_angle(s0 + 0.1), _slot_angle(s1 - 0.1),
			48, bcol, 9.0 * sc, true)
		var mid := (s0 + s1) * 0.5
		var lp := center + Vector2.from_angle(_slot_angle(mid)) * (band_r + 26.0 * sc)
		_ctext("%s  x%d" % [b, s1 - s0], lp, int(13.0 * sc), bcol)

	if active != -1:
		var e: Dictionary = elements[active]
		var hcol: Color = BLOCK_COLORS[e.block]
		var fade := 0.3 + 0.7 * _ease_out_cubic(chord_t)
		# period ring
		draw_arc(center, _ring_r(e.period) * sc, 0.0, TAU, 160,
			Color(hcol, 0.55 * fade), 2.0 * sc, true)
		# group spoke
		var dir := Vector2.from_angle(_slot_angle(e.slot + 0.5))
		draw_line(center + dir * (R_BASE - 16.0) * sc, center + dir * r_out,
			Color(1, 1, 1, 0.35 * fade), 1.5 * sc, true)


func _draw_hub(_idx: int) -> void:
	var hr := 74.0 * sc
	draw_circle(center, hr, Color("10142a"))
	draw_arc(center, hr, 0.0, TAU, 96, Color(1, 1, 1, 0.15), 1.5, true)
	# idle title fades out as the atom fades in
	var idle_a := 1.0 - hub_mix
	if idle_a > 0.01:
		var pulse := 0.5 + 0.5 * sin(t * 1.5)
		draw_arc(center, hr * (0.45 + 0.2 * pulse), 0.0, TAU, 64,
			Color(1, 1, 1, 0.08 * idle_a), 1.0, true)
		_ctext("PERIODIC", center + Vector2(0, -8.0 * sc), int(14.0 * sc), Color(1, 1, 1, 0.85 * idle_a))
		_ctext("ORBITALS", center + Vector2(0, 10.0 * sc), int(14.0 * sc), Color(1, 1, 1, 0.85 * idle_a))
	if hub_idx == -1 or hub_mix <= 0.01:
		return
	var e: Dictionary = elements[hub_idx]
	var pop := _ease_out_cubic(hub_pop)
	var am := hub_mix * (0.3 + 0.7 * pop)     # alpha
	var sm := 0.9 + 0.1 * pop                 # scale
	var shells: Array = e.shells
	var top := 1
	for n in range(1, 8):
		if shells[n] > 0:
			top = n
	for n in range(1, 8):
		var cnt: int = shells[n]
		if cnt == 0:
			continue
		var rr := (14.0 + 8.2 * n) * sc * sm
		draw_arc(center, rr, 0.0, TAU, 64, Color(1, 1, 1, 0.12 * am), 1.0, true)
		var spd := 1.6 / pow(float(n), 0.9) * (1.0 if n % 2 == 0 else -1.0)
		for k in cnt:
			var ang := t * spd + TAU * k / cnt
			var pos := center + Vector2.from_angle(ang) * rr
			if n == top:
				draw_circle(pos, 2.6 * sc, Color(1.0, 0.82, 0.25, am))
			else:
				draw_circle(pos, 1.7 * sc, Color(1, 1, 1, 0.85 * am))
	var nc := _node_color(e).darkened(0.2)
	nc.a = am
	draw_circle(center, 10.0 * sc * sm, nc)
	_ctext(e.sym, center, int(12.0 * sc), Color(1, 1, 1, am))


func _draw_chords(active: int) -> void:
	var a_p := _node_pos(elements[active])
	var prog := _ease_out_cubic(chord_t)
	for j in rel:
		var kind: String = rel[j]
		if kind == "group" or kind == "pair":
			continue
		var pts := _chord(a_p, _node_pos(elements[j]))
		# chords sweep outward from the focused element
		var count := clampi(int(prog * 40.0) + 1, 2, pts.size())
		var col: Color = REL_COLORS[kind]
		draw_polyline(pts.slice(0, count), Color(col, 0.6 * minf(1.0, prog * 2.0)),
			2.0 * sc + 0.5, true)


func _draw_dots(active: int) -> void:
	var prog := _ease_out_cubic(chord_t)
	if prog < 0.6:
		return
	var a_p := _node_pos(elements[active])
	for j in rel:
		var kind: String = rel[j]
		if kind == "group" or kind == "pair":
			continue
		var pts := _chord(a_p, _node_pos(elements[j]))
		var col: Color = REL_COLORS[kind]
		var k := fmod(t * 0.5 + float(j) * 0.13, 1.0)
		draw_circle(pts[int(k * (pts.size() - 1))], 4.0 * sc,
			Color(col, minf(1.0, (prog - 0.6) * 2.5)))


func _draw_pair_line(a_i: int, b_i: int) -> void:
	var a: Dictionary = elements[a_i]
	var b: Dictionary = elements[b_i]
	var info := _bond_info(a, b)
	var col: Color = info.color
	var den: float = info.den
	var ionic: float = info.ionic
	var lo: Dictionary = a if a.en <= b.en else b
	var hi: Dictionary = b if a.en <= b.en else a
	var prog := _ease_out_cubic(pair_t)
	var fade := minf(1.0, prog * 2.0)
	var pts := _chord(_node_pos(lo), _node_pos(hi))
	var count := clampi(int(prog * 40.0) + 1, 2, pts.size())
	var part := pts.slice(0, count)
	draw_polyline(part, Color(col, 0.25 * fade), (9.0 + ionic / 12.0) * sc, true)
	draw_polyline(part, Color(col, 0.95 * fade), (3.0 + ionic / 25.0) * sc, true)
	# electrons drift toward the more electronegative atom
	if prog > 0.5:
		for k in 5:
			var u := fmod(t * (0.25 + 0.3 * den) + k / 5.0, 1.0)
			draw_circle(pts[int(u * (count - 1))], 3.5 * sc, Color(1, 1, 1, fade))
	# angular separation arc around the hub sweeps open
	var ang_a := _slot_angle(a.slot + 0.5)
	var ang_b := _slot_angle(b.slot + 0.5)
	var dlt := wrapf(ang_b - ang_a, -PI, PI)
	draw_arc(center, 79.0 * sc, ang_a, ang_a + dlt * prog, 40, Color(col, 0.9), 3.0 * sc, true)


func _draw_nodes(active: int) -> void:
	var pair := _pair()
	var rf := _ease_out_cubic(chord_t)
	var pf := _ease_out_cubic(pair_t)
	for i in elements.size():
		if i != active and i != pair:
			_draw_node(i, active, pair, rf, pf)
	# focused nodes last, so the enlarged ones sit on top of their neighbours
	if pair != -1:
		_draw_node(pair, active, pair, rf, pf)
	if active != -1:
		_draw_node(active, active, pair, rf, pf)


func _draw_node(i: int, active: int, pair: int, rf: float, pf: float) -> void:
	var e: Dictionary = elements[i]
	var ip := _intro_progress(e)
	if ip <= 0.0:
		return
	var p := _node_pos(e)
	var r := _node_r(e) * scale_cur[i] * _ease_out_back(ip)
	var a: float = alpha_cur[i] * minf(1.0, ip * 2.0)
	var base: Color = col_cur[i]
	var rim: Color = BLOCK_COLORS[e.block]
	draw_circle(p, r, Color(0.06, 0.07, 0.125, minf(1.0, ip * 2.0)))
	draw_circle(p, r, Color(base.darkened(0.35), a))
	draw_arc(p, r, 0.0, TAU, 28, Color(rim, a), 1.5 * sc, true)
	_ctext(e.sym, p, int(clampf(r * 0.95, 7.0, 17.0 * maxf(zoom, 1.0) * 1.2)), Color(1, 1, 1, a))
	if r > 26.0:     # zoomed in: show atomic number and name as well
		_ctext(str(e.z), p + Vector2(0, -r * 0.58), int(r * 0.26), Color(1, 1, 1, a * 0.7))
		_ctext(e.name, p + Vector2(0, r * 0.6), int(r * 0.2), Color(1, 1, 1, a * 0.75))

	if i == active:
		var pr := fmod(t * 18.0, 14.0)
		draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color("ffd23f"), 2.5 * sc, true)
		draw_arc(p, r + (3.0 + pr) * sc, 0.0, TAU, 32,
			Color(1.0, 0.82, 0.25, 1.0 - pr / 14.0), 2.0 * sc, true)
	elif i == pair:
		draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color(1, 1, 1, pf), 2.5 * sc, true)
	elif rel.get(i, "") == "group":
		draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color(1, 1, 1, 0.9 * rf), 2.0 * sc, true)
	elif rel.has(i):
		var col: Color = REL_COLORS[rel[i]]
		draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color(col, 0.95 * rf), 2.0 * sc, true)
	if search_hits.has(i) and i != active:
		var sp := 0.5 + 0.5 * sin(t * 5.0)
		draw_arc(p, r + (3.0 + 2.0 * sp) * sc, 0.0, TAU, 32,
			Color(0.35, 0.9, 1.0, 0.9), 2.0 * sc, true)


func _draw_tooltip() -> void:
	if tip_idx == -1 or tip_a < 0.02:
		return
	var e: Dictionary = elements[tip_idx]
	var p := _node_pos(e)
	var label := "%s  (%d)" % [e.name, e.z]
	var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var rise := (1.0 - tip_a) * 5.0
	var rect := Rect2(p + Vector2(-w * 0.5 - 6.0, -_node_r(e) * 1.2 - 28.0 + rise),
		Vector2(w + 12.0, 20.0))
	draw_rect(rect, Color(0, 0, 0, 0.8 * tip_a))
	draw_string(font, rect.position + Vector2(6, 14), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, tip_a))


# ========================================================== panel ========

func _pline(txt: String, fs: int, color: Color = Color.WHITE, gap: float = 4.0) -> void:
	_py += fs + gap
	var c := Color(color.r, color.g, color.b, color.a * _pa)
	draw_string(font, Vector2(24.0, _py), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)


func _legend_bar(lo_txt: String, hi_txt: String) -> void:
	var x0 := 24.0
	var w := 220.0
	var y0 := _py + 6.0
	for k in 44:
		draw_rect(Rect2(x0 + k * w / 44.0, y0, w / 44.0 + 1.0, 8.0), _ramp(k / 43.0))
	_py += 26.0
	var dim := Color(1, 1, 1, 0.55)
	draw_string(font, Vector2(x0, _py), lo_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, dim)
	draw_string(font, Vector2(x0 + w - 48.0, _py), hi_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, dim)


func _draw_panel(active: int, pair: int) -> void:
	var dim := Color(1, 1, 1, 0.55)
	var gold := Color("ffd23f")
	# opaque backdrop so the zoomed wheel never runs under the text
	draw_rect(Rect2(0.0, 0.0, PANEL_W, size.y), Color("0b0e1a"))
	draw_line(Vector2(PANEL_W, 0.0), Vector2(PANEL_W, size.y), Color(1, 1, 1, 0.08), 1.0)
	_py = 14.0
	_pline("ORBITAL PERIODIC TABLE", 20, Color.WHITE, 4.0)
	_pline("rings = periods  |  angle = subshell slot", 11, dim, 10.0)
	_py += 40.0   # space for the search box

	var names := ["Block (s / p / d / f)", "Electronegativity",
		"Effective nuclear charge", "Atomic radius (measured)",
		"Orbital radius (Slater est.)"]
	for m in 5:
		_pline("[%d]  %s" % [m + 1, names[m]], 12, gold if m == mode else dim, 2.0)
	match mode:
		0:
			_py += 8.0
			var bx := 24.0
			for b in ["s", "p", "d", "f"]:
				var bc: Color = BLOCK_COLORS[b]
				draw_rect(Rect2(bx, _py, 10, 10), bc)
				draw_string(font, Vector2(bx + 14.0, _py + 9.0), b + "-block",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 11, dim)
				bx += 72.0
			_py += 12.0
		1:
			_legend_bar("0.7", "4.0 (Pauling)")
		2:
			_legend_bar("%.1f" % z_min, "%.1f" % z_max)
		3:
			_legend_bar("%.0f pm" % c_min, "%.0f pm" % c_max)
			_pline("gray = no data (Z > 96)   Slater vs measured r = %.2f" % radius_corr,
				10, dim, 2.0)
		4:
			_legend_bar("%.0f pm" % r_min, "%.0f pm" % r_max)
			_pline("Slater vs measured: Pearson r = %.2f" % radius_corr, 10, dim, 2.0)

	_py += 10.0
	if active == -1:
		_pline("Hover an element to reveal its", 13, dim, 2.0)
		_pline("relatives and live calculations.", 13, dim, 2.0)
	else:
		var e: Dictionary = elements[active]
		var ecol: Color = BLOCK_COLORS[e.block]
		_pa = detail_fade                          # details fade and slide in
		_py += (1.0 - detail_fade) * 10.0
		_pline("%s  (%s)" % [e.name, e.sym], 22, ecol.lightened(0.25), 4.0)
		_pline("Z %d   mass %.3f   %s" % [e.z, e.mass, e.cat], 12, Color(1, 1, 1, 0.85), 3.0)
		var grp: String = "f-block" if e.col == 0 else "group %d" % e.col
		_pline("period %d   %s   %s" % [e.period, grp, e.block + "-block"], 12, Color(1, 1, 1, 0.85), 3.0)
		_pline("slot %d / 32  (%.1f deg)" % [e.slot, (e.slot + 0.5) * 360.0 / SLOTS], 12, Color(1, 1, 1, 0.85), 8.0)

		_pline("Configuration", 10, dim, 1.0)
		_pline(e.cfg_str, 14, Color.WHITE, 4.0)
		var sh: PackedStringArray = []
		for n in range(1, 8):
			if e.shells[n] > 0:
				sh.append(str(e.shells[n]))
		_pline("Shells  " + " ".join(sh), 12, Color(1, 1, 1, 0.85), 3.0)
		_pline("Valence e-  %s" % (str(e.val) if e.val >= 0 else "variable (f-block)"),
			12, Color(1, 1, 1, 0.85), 3.0)
		var en_txt: String = "none" if e.en <= 0.0 else "%.2f" % e.en
		_pline("Electronegativity  %s" % en_txt, 12, Color(1, 1, 1, 0.85), 3.0)
		_pline("Zeff (Slater)  %.2f" % e.zeff, 12, Color(1, 1, 1, 0.85), 3.0)
		_pline("Oxidation states  %s" % _ox_string(e), 12, Color(1, 1, 1, 0.85), 3.0)
		var cov: float = e.cov
		var est: float = e.radius
		if cov > 0.0:
			var err := (est - cov) / cov * 100.0
			_pline("Radius  %.0f pm measured  |  %.0f pm Slater (%s%.0f%%)" % [cov, est,
				"+" if err >= 0.0 else "", err], 11, Color(1, 1, 1, 0.85), 3.0)
		else:
			_pline("Radius  no measured data  |  %.0f pm Slater" % est, 11,
				Color(1, 1, 1, 0.85), 3.0)
		if mode >= 3:
			_radius_bars(e)

		if pair != -1:
			var o: Dictionary = elements[pair]
			var info := _bond_info(e, o)
			var bcol: Color = info.color
			_py += 10.0
			_pline("PAIR   %s  +  %s" % [e.sym, o.sym], 15, gold, 4.0)
			_pline(info.type, 14, bcol, 3.0)
			if info.den > 0.0:
				_pline("EN gap %.2f   ionic character %.0f%%" % [info.den, info.ionic],
					12, Color(1, 1, 1, 0.85), 3.0)
				var lo: Dictionary = e if e.en <= o.en else o
				var hi: Dictionary = o if e.en <= o.en else e
				if info.den >= 0.4:
					_pline("Electrons drift toward %s" % hi.sym, 12, Color(1, 1, 1, 0.85), 3.0)
			var comps: Array = info.compounds
			if comps.is_empty():
				_pline("Likely compounds  -", 12, Color(1, 1, 1, 0.85), 3.0)
			else:
				_pline("Likely compounds", 11, dim, 2.0)
				for c in comps:
					var fstr: String = c.formula
					var note: String = c.note
					var wf := font.get_string_size(fstr, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
					_py += 17.0
					draw_string(font, Vector2(24.0, _py), fstr,
						HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, _pa))
					draw_string(font, Vector2(24.0 + wf + 10.0, _py), note,
						HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.55 * _pa))
			var ds := absf(float(e.slot - o.slot))
			ds = minf(ds, SLOTS - ds)
			_pline("Angular gap %.1f deg   ring gap %d" % [ds * 360.0 / SLOTS,
				absi(e.period - o.period)], 12, Color(1, 1, 1, 0.85), 3.0)
			_pline("Zeff gap %.2f" % absf(e.zeff - o.zeff), 12, Color(1, 1, 1, 0.85), 3.0)

	# Legend + hints, pinned to the bottom (skipped if the content needs the room)
	_pa = 1.0
	var by := size.y - 134.0
	if _py < by - 8.0:
		_draw_legend(by)
	_draw_search_results()


# ========================================================= search ========

func _build_search() -> void:
	search = LineEdit.new()
	search.placeholder_text = "Search element...   ( / )"
	search.clear_button_enabled = true
	search.position = Vector2(24, 64)
	search.size = Vector2(PANEL_W - 48.0, 28)
	search.add_theme_font_size_override("font_size", 13)
	search.text_changed.connect(_on_search_changed)
	search.text_submitted.connect(_on_search_submitted)
	search.gui_input.connect(_on_search_gui_input)
	add_child(search)


# Matches name, symbol, atomic number, common alternate spellings, and
# (for 3+ letters) category names such as "halogen" or "lanthanide".
func _search(query: String) -> Array:
	var q := query.strip_edges().to_lower()
	var exact: Array = []
	var starts: Array = []
	var contains: Array = []
	var cats: Array = []
	if q == "":
		return exact
	for i in elements.size():
		var e: Dictionary = elements[i]
		var nm: String = e.name.to_lower()
		var sym: String = e.sym.to_lower()
		if sym == q or nm == q or str(e.z) == q or ALIASES.get(q, "") == sym:
			exact.append(i)
		elif nm.begins_with(q) or sym.begins_with(q):
			starts.append(i)
		elif q.length() >= 3 and nm.contains(q):
			contains.append(i)
		elif q.length() >= 3 and String(e.cat).to_lower().contains(q):
			cats.append(i)
	return exact + starts + contains + cats


func _on_search_changed(text: String) -> void:
	search_hits = _search(text)
	search_idx = 0


func _on_search_submitted(_text: String) -> void:
	_commit_search()


func _on_search_gui_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	var shown := mini(search_hits.size(), MAX_RESULTS)
	match event.keycode:
		KEY_ESCAPE:
			_close_search()
			search.accept_event()
		KEY_DOWN:
			if shown > 0:
				search_idx = mini(search_idx + 1, shown - 1)
				hovered = search_hits[search_idx]
				_refresh()
			search.accept_event()
		KEY_UP:
			if shown > 0:
				search_idx = maxi(search_idx - 1, 0)
				hovered = search_hits[search_idx]
				_refresh()
			search.accept_event()


# Lock the highlighted result and reset the search box
func _commit_search() -> void:
	var shown := mini(search_hits.size(), MAX_RESULTS)
	if shown > 0:
		selected = search_hits[clampi(search_idx, 0, shown - 1)]
		_focus_on(selected)
	_close_search()


func _close_search() -> void:
	search.clear()
	search_hits.clear()
	search_idx = 0
	search.release_focus()
	hovered = -1
	_refresh()


func _row_at(pos: Vector2) -> int:
	for k in _result_rects.size():
		if (_result_rects[k] as Rect2).has_point(pos):
			return k
	return -1


# Dropdown drawn on top of the panel so nothing else has to move
func _draw_search_results() -> void:
	_result_rects.clear()
	if search == null or search.text.strip_edges() == "":
		return
	var x := 24.0
	var y := 94.0
	var w := PANEL_W - 48.0
	var bg := Color(0.06, 0.08, 0.16, 0.97)
	var edge := Color(1, 1, 1, 0.18)
	if search_hits.is_empty():
		draw_rect(Rect2(x, y, w, 26.0), bg)
		draw_rect(Rect2(x, y, w, 26.0), edge, false, 1.0)
		draw_string(font, Vector2(x + 10.0, y + 18.0), "No matching element",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.55))
		return
	var shown := mini(search_hits.size(), MAX_RESULTS)
	var extra := search_hits.size() - shown
	var h := shown * 24.0 + 6.0 + (18.0 if extra > 0 else 0.0)
	draw_rect(Rect2(x, y, w, h), bg)
	draw_rect(Rect2(x, y, w, h), edge, false, 1.0)
	for k in shown:
		var e: Dictionary = elements[search_hits[k]]
		var row := Rect2(x + 3.0, y + 3.0 + k * 24.0, w - 6.0, 24.0)
		_result_rects.append(row)
		if k == search_idx:
			draw_rect(row, Color(1, 1, 1, 0.12))
		var bc: Color = BLOCK_COLORS[e.block]
		draw_circle(row.position + Vector2(12.0, 12.0), 5.0, bc)
		draw_string(font, row.position + Vector2(26.0, 17.0), e.sym,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		draw_string(font, row.position + Vector2(58.0, 17.0), e.name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.8))
		draw_string(font, row.position + Vector2(0.0, 17.0), "Z %d" % e.z,
			HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 8.0, 11, Color(1, 1, 1, 0.5))
	if extra > 0:
		draw_string(font, Vector2(x + 10.0, y + h - 6.0),
			"+%d more (pulsing on the wheel)" % extra,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.9, 1.0, 0.8))


# ======================================================== view / zoom =====

func _stop_view_tween() -> void:
	view_anim = 0


# Glide to a target zoom/pan (used by reset and by search focus)
func _animate_view(target_zoom: float, target_pan: Vector2) -> void:
	zoom_target = clampf(target_zoom, ZOOM_MIN, ZOOM_MAX)
	pan_target = target_pan
	pan_vel = Vector2.ZERO
	view_anim = 2


func _reset_view() -> void:
	_animate_view(1.0, Vector2.ZERO)


# Request a zoom about a screen point; _update_view eases toward it
func _zoom_at(anchor: Vector2, factor: float) -> void:
	var base := zoom_target if view_anim == 1 else zoom
	zoom_target = clampf(base * factor, ZOOM_MIN, ZOOM_MAX)
	zoom_anchor = anchor
	pan_vel = Vector2.ZERO
	view_anim = 1


# Apply a zoom level while keeping the point under `anchor` fixed
func _set_zoom_anchored(anchor: Vector2, new_zoom: float) -> void:
	_layout()
	var ratio := new_zoom / zoom
	var new_center := anchor + (center - anchor) * ratio
	pan = (new_center - (center - pan)).limit_length(460.0 * base_sc * new_zoom)
	zoom = new_zoom
	_layout()


# When zoomed in, glide the view so a chosen element sits mid-screen
func _focus_on(i: int) -> void:
	var z := zoom_target if view_anim == 1 else zoom
	if z <= 1.05:
		return
	var e: Dictionary = elements[i]
	var v := Vector2.from_angle(_slot_angle(e.slot + 0.5)) * _ring_r(e.period)
	_animate_view(z, -v * base_sc * z)


func _update_view(delta: float) -> void:
	var k := 1.0 - exp(-delta * 10.0)
	if view_anim == 1:
		var nz := lerpf(zoom, zoom_target, k)
		if absf(nz - zoom_target) < 0.003:
			nz = zoom_target
			view_anim = 0
		_set_zoom_anchored(zoom_anchor, nz)
	elif view_anim == 2:
		zoom = lerpf(zoom, zoom_target, k)
		pan = pan.lerp(pan_target, k)
		if absf(zoom - zoom_target) < 0.003 and pan.distance_to(pan_target) < 0.5:
			zoom = zoom_target
			pan = pan_target
			view_anim = 0
	elif not (press_active and drag_moved):
		# momentum after a drag
		if pan_vel.length() > 8.0:
			pan = (pan + pan_vel * delta).limit_length(460.0 * base_sc * zoom)
			pan_vel *= exp(-delta * 4.5)
		else:
			pan_vel = Vector2.ZERO
	if view_anim != 0 or pan_vel != Vector2.ZERO:
		_rehover()


# Nodes move under a still cursor while zooming or gliding: keep hover correct
func _rehover() -> void:
	var mp := get_local_mouse_position()
	if mp.x < 0.0 or mp.y < 0.0 or mp.x > size.x or mp.y > size.y:
		return
	if _row_at(mp) != -1 or (press_active and drag_moved):
		return
	_layout()
	hovered = _pick(mp)


# =================================================== radii / compounds ====

func _calc_radius_corr() -> void:
	var xs: Array = []
	var ys: Array = []
	for e in elements:
		if e.cov > 0.0:
			xs.append(e.radius)
			ys.append(e.cov)
	var n := xs.size()
	if n < 2:
		return
	var mx := 0.0
	var my := 0.0
	for k in n:
		mx += xs[k]
		my += ys[k]
	mx /= n
	my /= n
	var sxy := 0.0
	var sxx := 0.0
	var syy := 0.0
	for k in n:
		var dx: float = xs[k] - mx
		var dy: float = ys[k] - my
		sxy += dx * dy
		sxx += dx * dx
		syy += dy * dy
	radius_corr = sxy / sqrt(sxx * syy)


func _ox_string(e: Dictionary) -> String:
	var ox: Array = e.ox
	if ox.is_empty():
		return "none / unknown"
	var parts: PackedStringArray = []
	for st in ox:
		parts.append(("+%d" % st) if st > 0 else ("%d" % st))
	return ", ".join(parts)


func _fmt_formula(lo: Dictionary, n_lo: int, hi: Dictionary, n_hi: int) -> String:
	var first: Dictionary = lo
	var second: Dictionary = hi
	var n_first := n_lo
	var n_second := n_hi
	# conventional order: CH4, NH3, SiH4 rather than H4C, H3N, H4Si
	if lo.sym == "H" and hi.col >= 13 and hi.col <= 15:
		first = hi
		second = lo
		n_first = n_hi
		n_second = n_lo
	return "%s%s%s%s" % [first.sym, str(n_first) if n_first > 1 else "",
		second.sym, str(n_second) if n_second > 1 else ""]


# Cross-multiply every common positive state of the less electronegative atom
# with the main negative state of the other one (Fe + O -> Fe2O3, FeO ...)
func _predict_compounds(a: Dictionary, b: Dictionary) -> Array:
	var lo: Dictionary = a if a.en <= b.en else b
	var hi: Dictionary = b if a.en <= b.en else a
	var out: Array = []
	var neg := 0
	for st in hi.ox:
		if st < 0:
			neg = -int(st)
			break
	if neg == 0:
		return out
	for st in lo.ox:
		var c := int(st)
		if c <= 0:
			continue
		var g := _gcd(c, neg)
		var n_lo: int = floori(neg / float(g))
		var n_hi: int = floori(c / float(g))
		out.append({
			"formula": _fmt_formula(lo, n_lo, hi, n_hi),
			"note": "%s +%d, %s -%d" % [lo.sym, c, hi.sym, neg],
		})
		if out.size() >= MAX_COMPOUNDS:
			break
	return out


# Two bars: Slater estimate vs measured covalent radius, on a shared scale
func _radius_bars(e: Dictionary) -> void:
	var x0 := 24.0
	var w := 230.0
	var mx := maxf(c_max, r_max)
	var est: float = e.radius
	var meas: float = e.cov
	var pink := Color("ff8fa3")
	var green := Color("7bd88f")
	_py += 4.0
	draw_rect(Rect2(x0, _py, w * est / mx, 5.0), pink)
	draw_string(font, Vector2(x0 + w + 8.0, _py + 6.0), "Slater",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, pink)
	_py += 9.0
	if meas > 0.0:
		draw_rect(Rect2(x0, _py, w * meas / mx, 5.0), green)
		draw_string(font, Vector2(x0 + w + 8.0, _py + 6.0), "measured",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, green)
	_py += 8.0


func _draw_legend(by_start: float) -> void:
	var dim := Color(1, 1, 1, 0.55)
	var by := by_start
	var items := [
		["group", "Same group (shares a spoke)"],
		["diagonal", "Diagonal relative"],
		["twin", "Twin: closest electronegativity"],
		["opposite", "Opposite: largest EN gap"],
	]
	for it in items:
		var col: Color = REL_COLORS[it[0]]
		draw_line(Vector2(24, by - 4), Vector2(50, by - 4), col, 3.0)
		draw_string(font, Vector2(60, by), it[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
			Color(1, 1, 1, 0.8))
		by += 16.0
	by += 6.0
	var hints := [
		"Hover inspect | Click lock | Right-click clear",
		"Lock one, hover another = bond analysis",
		"Wheel zoom (%.1fx) | Drag pan | R reset" % zoom,
		"/ or Ctrl+F = search   Esc = clear",
	]
	for h in hints:
		draw_string(font, Vector2(24, by), h, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, dim)
		by += 14.0


# ========================================================= animation ======

func _ease_out_cubic(x: float) -> float:
	var u := 1.0 - clampf(x, 0.0, 1.0)
	return 1.0 - u * u * u


func _ease_out_back(x: float) -> float:
	var c1 := 1.70158
	var c3 := c1 + 1.0
	var u := clampf(x, 0.0, 1.0) - 1.0
	return 1.0 + c3 * u * u * u + c1 * u * u


func _init_anim() -> void:
	var n := elements.size()
	alpha_cur.resize(n)
	alpha_cur.fill(1.0)
	scale_cur.resize(n)
	scale_cur.fill(1.0)
	col_cur.resize(n)
	for i in n:
		col_cur[i] = _node_color(elements[i])


# Nodes pop in ring by ring when the app starts
func _intro_progress(e: Dictionary) -> float:
	if intro_t > 1.6:
		return 1.0
	var delay: float = e.period * 0.09 + e.slot * 0.006
	return clampf((intro_t - delay) / 0.5, 0.0, 1.0)


# Hover keeps its target briefly when the cursor crosses the gap between nodes
func _update_hover(delta: float) -> void:
	if hovered != -1:
		hover_eff = hovered
		hover_timer = 0.0
	elif hover_eff != -1:
		hover_timer += delta
		if hover_timer >= HOVER_GRACE:
			hover_eff = -1


# Recompute relations and restart the entrance animations when focus changes
func _sync_focus() -> void:
	var act := _active()
	var pr := _pair()
	if act != _last_active:
		chord_t = 0.0
		detail_fade = 0.35
	if pr != _last_pair:
		pair_t = 0.0
	if act != _last_active or pr != _last_pair:
		_last_active = act
		_last_pair = pr
		_refresh()


func _target_alpha(i: int, active: int) -> float:
	var e: Dictionary = elements[i]
	if active != -1:
		if i == active or rel.has(i):
			return 1.0
		return 0.5 if e.period == elements[active].period else 0.16
	if not search_hits.is_empty() and not search_hits.has(i):
		return 0.14
	return 1.0


func _update_anim(delta: float) -> void:
	var active := _active()
	var pair := _pair()
	var ka := 1.0 - exp(-delta * 14.0)
	var ks := 1.0 - exp(-delta * 16.0)
	var kc := 1.0 - exp(-delta * 8.0)
	for i in elements.size():
		alpha_cur[i] = lerpf(alpha_cur[i], _target_alpha(i, active), ka)
		var ts := 1.0
		if i == active:
			ts = 1.2
		elif i == pair:
			ts = 1.12
		scale_cur[i] = lerpf(scale_cur[i], ts, ks)
		col_cur[i] = col_cur[i].lerp(_node_color(elements[i]), kc)   # smooth mode switch
	chord_t = minf(1.0, chord_t + delta / 0.5)
	pair_t = minf(1.0, pair_t + delta / 0.5)
	detail_fade = minf(1.0, detail_fade + delta * 6.0)
	hub_pop = minf(1.0, hub_pop + delta * 4.5)
	if active != -1:
		if active != hub_idx:
			hub_idx = active
			hub_pop = 0.0
		hub_mix = minf(1.0, hub_mix + delta * 7.0)
	else:
		hub_mix = maxf(0.0, hub_mix - delta * 5.0)
	if hover_eff != -1 and hover_eff != selected:
		tip_idx = hover_eff
		tip_a = minf(1.0, tip_a + delta * 10.0)
	else:
		tip_a = maxf(0.0, tip_a - delta * 8.0)


func _update_cursor() -> void:
	var shape: Control.CursorShape = Control.CURSOR_ARROW
	if drag_moved and press_active:
		shape = Control.CURSOR_DRAG
	elif hovered != -1 or _row_at(get_local_mouse_position()) != -1:
		shape = Control.CURSOR_POINTING_HAND
	mouse_default_cursor_shape = shape
