extends Control

const SLOTS := 32
const R_BASE := 90.0
const R_STEP := 50.0
const PANEL_W := 340.0
const A0_PM := 52.9

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

var z_min := 99.0
var z_max := 0.0
var r_min := 99999.0
var r_max := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	font = ThemeDB.fallback_font
	_build_elements()


func _process(delta: float) -> void:
	t += delta
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

		elements.append({
			"z": z, "sym": p[0], "name": p[1], "mass": float(p[2]),
			"en": float(p[3]), "cat": _category(z),
			"slot": slot, "period": period, "block": block, "col": col,
			"cfg": cfg, "cfg_str": _config_string(z, cfg), "shells": shells,
			"zeff": zeff, "radius": radius, "val": val,
		})


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
	var info := {"type": "", "color": Color.WHITE, "den": 0.0, "ionic": 0.0, "formula": ""}
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
	info.formula = _predict_formula(a, b, den >= 1.7)
	return info


# ======================================================= relations =======

func _active() -> int:
	return selected if selected != -1 else hovered


func _pair() -> int:
	if selected != -1 and hovered != -1 and hovered != selected:
		return hovered
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
	sc = clampf(minf(avail.x, avail.y) / 980.0, 0.3, 2.0)
	center = Vector2(PANEL_W + avail.x * 0.5, size.y * 0.5)


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
		var h := _pick(event.position)
		if h != hovered:
			hovered = h
			_refresh()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var h := _pick(event.position)
			selected = -1 if h == selected else h
			_refresh()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			selected = -1
			_refresh()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: mode = 0
			KEY_2: mode = 1
			KEY_3: mode = 2
			KEY_4: mode = 3


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
		# period ring
		draw_arc(center, _ring_r(e.period) * sc, 0.0, TAU, 160,
			Color(hcol, 0.55), 2.0 * sc, true)
		# group spoke
		var dir := Vector2.from_angle(_slot_angle(e.slot + 0.5))
		draw_line(center + dir * (R_BASE - 16.0) * sc, center + dir * r_out,
			Color(1, 1, 1, 0.35), 1.5 * sc, true)


func _draw_hub(active: int) -> void:
	var hr := 74.0 * sc
	draw_circle(center, hr, Color("10142a"))
	draw_arc(center, hr, 0.0, TAU, 96, Color(1, 1, 1, 0.15), 1.5, true)
	if active == -1:
		var pulse := 0.5 + 0.5 * sin(t * 1.5)
		draw_arc(center, hr * (0.45 + 0.2 * pulse), 0.0, TAU, 64,
			Color(1, 1, 1, 0.08), 1.0, true)
		_ctext("PERIODIC", center + Vector2(0, -8.0 * sc), int(14.0 * sc), Color(1, 1, 1, 0.85))
		_ctext("ORBITALS", center + Vector2(0, 10.0 * sc), int(14.0 * sc), Color(1, 1, 1, 0.85))
		return
	var e: Dictionary = elements[active]
	var shells: Array = e.shells
	var top := 1
	for n in range(1, 8):
		if shells[n] > 0:
			top = n
	for n in range(1, 8):
		var cnt: int = shells[n]
		if cnt == 0:
			continue
		var rr := (14.0 + 8.2 * n) * sc
		draw_arc(center, rr, 0.0, TAU, 64, Color(1, 1, 1, 0.12), 1.0, true)
		var spd := 1.6 / pow(float(n), 0.9) * (1.0 if n % 2 == 0 else -1.0)
		for k in cnt:
			var ang := t * spd + TAU * k / cnt
			var pos := center + Vector2.from_angle(ang) * rr
			if n == top:
				draw_circle(pos, 2.6 * sc, Color("ffd23f"))
			else:
				draw_circle(pos, 1.7 * sc, Color(1, 1, 1, 0.85))
	draw_circle(center, 10.0 * sc, _node_color(e).darkened(0.2))
	_ctext(e.sym, center, int(12.0 * sc), Color.WHITE)


func _draw_chords(active: int) -> void:
	var a_p := _node_pos(elements[active])
	for j in rel:
		var kind: String = rel[j]
		if kind == "group" or kind == "pair":
			continue
		var pts := _chord(a_p, _node_pos(elements[j]))
		var col: Color = REL_COLORS[kind]
		draw_polyline(pts, Color(col, 0.6), 2.0 * sc + 0.5, true)


func _draw_dots(active: int) -> void:
	var a_p := _node_pos(elements[active])
	for j in rel:
		var kind: String = rel[j]
		if kind == "group" or kind == "pair":
			continue
		var pts := _chord(a_p, _node_pos(elements[j]))
		var col: Color = REL_COLORS[kind]
		var k := fmod(t * 0.5 + float(j) * 0.13, 1.0)
		draw_circle(pts[int(k * (pts.size() - 1))], 4.0 * sc, col)


func _draw_pair_line(a_i: int, b_i: int) -> void:
	var a: Dictionary = elements[a_i]
	var b: Dictionary = elements[b_i]
	var info := _bond_info(a, b)
	var col: Color = info.color
	var den: float = info.den
	var ionic: float = info.ionic
	var lo: Dictionary = a if a.en <= b.en else b
	var hi: Dictionary = b if a.en <= b.en else a
	var pts := _chord(_node_pos(lo), _node_pos(hi))
	draw_polyline(pts, Color(col, 0.25), (9.0 + ionic / 12.0) * sc, true)
	draw_polyline(pts, Color(col, 0.95), (3.0 + ionic / 25.0) * sc, true)
	# electrons drift toward the more electronegative atom
	for k in 5:
		var u := fmod(t * (0.25 + 0.3 * den) + k / 5.0, 1.0)
		draw_circle(pts[int(u * (pts.size() - 1))], 3.5 * sc, Color.WHITE)
	# angular separation arc around the hub
	var ang_a := _slot_angle(a.slot + 0.5)
	var ang_b := _slot_angle(b.slot + 0.5)
	var dlt := wrapf(ang_b - ang_a, -PI, PI)
	draw_arc(center, 79.0 * sc, ang_a, ang_a + dlt, 40, Color(col, 0.9), 3.0 * sc, true)


func _draw_nodes(active: int) -> void:
	var pair := _pair()
	for i in elements.size():
		var e: Dictionary = elements[i]
		var p := _node_pos(e)
		var r := _node_r(e)
		var a := 1.0
		if active != -1 and i != active and not rel.has(i):
			a = 0.5 if e.period == elements[active].period else 0.16
		var base := _node_color(e)
		var rim: Color = BLOCK_COLORS[e.block]
		draw_circle(p, r, Color("0f1220"))
		draw_circle(p, r, Color(base.darkened(0.35), a))
		draw_arc(p, r, 0.0, TAU, 28, Color(rim, a), 1.5 * sc, true)
		_ctext(e.sym, p, int(clampf(r * 0.95, 7.0, 17.0)), Color(1, 1, 1, a))

		if i == active:
			var pr := fmod(t * 18.0, 14.0)
			draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color("ffd23f"), 2.5 * sc, true)
			draw_arc(p, r + (3.0 + pr) * sc, 0.0, TAU, 32,
				Color(1.0, 0.82, 0.25, 1.0 - pr / 14.0), 2.0 * sc, true)
		elif i == pair:
			draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color.WHITE, 2.5 * sc, true)
		elif rel.get(i, "") == "group":
			draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color(1, 1, 1, 0.9), 2.0 * sc, true)
		elif rel.has(i):
			var col: Color = REL_COLORS[rel[i]]
			draw_arc(p, r + 2.0 * sc, 0.0, TAU, 32, Color(col, 0.95), 2.0 * sc, true)


func _draw_tooltip() -> void:
	if hovered == -1 or hovered == selected:
		return
	var e: Dictionary = elements[hovered]
	var p := _node_pos(e)
	var label := "%s  (%d)" % [e.name, e.z]
	var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var rect := Rect2(p + Vector2(-w * 0.5 - 6.0, -_node_r(e) - 28.0), Vector2(w + 12.0, 20.0))
	draw_rect(rect, Color(0, 0, 0, 0.8))
	draw_string(font, rect.position + Vector2(6, 14), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)


# ========================================================== panel ========

func _pline(txt: String, fs: int, color: Color = Color.WHITE, gap: float = 4.0) -> void:
	_py += fs + gap
	draw_string(font, Vector2(24.0, _py), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)


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
	_py = 14.0
	_pline("ORBITAL PERIODIC TABLE", 20, Color.WHITE, 4.0)
	_pline("rings = periods  |  angle = subshell slot", 11, dim, 10.0)

	var names := ["Block (s / p / d / f)", "Electronegativity",
		"Effective nuclear charge", "Orbital radius (est.)"]
	for m in 4:
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
			_legend_bar("%.0f pm" % r_min, "%.0f pm" % r_max)

	_py += 10.0
	if active == -1:
		_pline("Hover an element to reveal its", 13, dim, 2.0)
		_pline("relatives and live calculations.", 13, dim, 2.0)
	else:
		var e: Dictionary = elements[active]
		var ecol: Color = BLOCK_COLORS[e.block]
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
		_pline("Orbital radius ~ %.0f pm" % e.radius, 12, Color(1, 1, 1, 0.85), 3.0)

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
			var f: String = info.formula
			_pline("Predicted formula  %s" % (f if f != "" else "-"), 12, Color(1, 1, 1, 0.85), 3.0)
			var ds := absf(float(e.slot - o.slot))
			ds = minf(ds, SLOTS - ds)
			_pline("Angular gap %.1f deg   ring gap %d" % [ds * 360.0 / SLOTS,
				absi(e.period - o.period)], 12, Color(1, 1, 1, 0.85), 3.0)
			_pline("Zeff gap %.2f" % absf(e.zeff - o.zeff), 12, Color(1, 1, 1, 0.85), 3.0)

	# Legend + hints, pinned to the bottom of the panel
	var by := size.y - 118.0
	var items := [
		["group", "Same group (shares a spoke)"],
		["diagonal", "Diagonal relative"],
		["twin", "Twin: closest electronegativity"],
		["opposite", "Opposite: largest EN gap"],
	]
	for it in items:
		var col: Color = REL_COLORS[it[0]]
		draw_line(Vector2(24, by - 4), Vector2(50, by - 4), col, 3.0)
		draw_string(font, Vector2(60, by), it[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.8))
		by += 16.0
	by += 6.0
	draw_string(font, Vector2(24, by), "Hover inspect | Click lock | Right-click clear",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, dim)
	by += 14.0
	draw_string(font, Vector2(24, by), "Lock one, hover another = bond analysis",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, dim)
