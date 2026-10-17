extends RefCounted
# Dữ liệu cá (12 loại, 4 bậc) + cần câu + tỷ lệ câu.

const FISH := [
	# ---- Phổ thông (mới chơi / dễ câu) ----
	{"id": "ro_dong", "name": "Cá Rô Đồng", "tier": "common", "price": 15, "color": "8d9b6a",
		"desc": "Phổ biến ở kênh rạch, đồng ruộng. Giá trị thấp, cá khởi đầu."},
	{"id": "chep", "name": "Cá Chép", "tier": "common", "price": 25, "color": "c98f4e",
		"desc": "Cá quen thuộc, làm nguyên liệu nấu ăn hoặc nuôi ao."},
	{"id": "me", "name": "Cá Mè", "tier": "common", "price": 35, "color": "b8c4c9",
		"desc": "Kích thước vừa và lớn, thường ở sông/hồ lớn quanh nông trại."},
	{"id": "tram", "name": "Cá Trắm", "tier": "common", "price": 40, "color": "7a5230",
		"desc": "Dễ nuôi trong hồ, thích hợp nhiệm vụ giao nộp nông sản."},
	# ---- Trung cấp (giá trị khá / cần kỹ năng) ----
	{"id": "loc", "name": "Cá Lóc (Cá Quả)", "tier": "mid", "price": 70, "color": "5e8c3e",
		"desc": "Cá săn mồi ở vùng nhiều bèo/cỏ nước. Giá bán tốt hơn."},
	{"id": "lang", "name": "Cá Lăng", "tier": "mid", "price": 85, "color": "9aa7b0",
		"desc": "Sống ở vùng nước sâu hoặc lòng sông, món cao cấp."},
	{"id": "bong", "name": "Cá Bống", "tier": "mid", "price": 60, "color": "a3a380",
		"desc": "Nhỏ, di chuyển nhanh — cần căn thời gian giật cần chính xác."},
	{"id": "dieu_hong", "name": "Cá Diêu Hồng", "tier": "mid", "price": 90, "color": "e08f5a",
		"desc": "Cá ao nuôi thương mại, bán lợi nhuận tốt để nâng cấp trang trại."},
	# ---- Hiếm / cao cấp ----
	{"id": "tre_vang", "name": "Cá Trê Vàng", "tier": "rare", "price": 200, "color": "e8c34a",
		"desc": "Chỉ xuất hiện khi trời mưa hoặc vào BAN ĐÊM."},
	{"id": "hoi", "name": "Cá Hồi Nước Ngọt", "tier": "rare", "price": 240, "color": "e89aa0",
		"desc": "Chỉ ở suối nước chảy xiết hoặc vùng núi cao."},
	{"id": "tai_tuong", "name": "Cá Tai Tượng", "tier": "rare", "price": 300, "color": "6b7f8e",
		"desc": "Cá cỡ lớn, cắn câu lâu và kéo dai dẳng — thử thách."},
	{"id": "chien", "name": "Cá Chiên (Huyền thoại)", "tier": "legend", "price": 1000, "color": "d4af37",
		"desc": "\"Chúa tể dòng sông\" — chỉ ở điểm câu ẩn, tỉ lệ cực thấp."},
]

const RODS := [
	{"tier": "basic", "name": "Cần câu sơ cấp", "casts": 10, "price": 100, "color": "9aa0a6"},
	{"tier": "mid", "name": "Cần câu trung cấp", "casts": 20, "price": 500, "color": "66bb6a"},
	{"tier": "high", "name": "Cần câu cao cấp", "casts": 30, "price": 1200, "color": "ffd54f"},
]

const BAITS := [
	{"id": "worm", "name": "Mồi Trùn Quế", "price": 10, "color": "e57373",
		"desc": "Mồi giun quế tự nhiên. Hụt gốc -5%, Phổ thông +5%."},
	{"id": "caterpillar", "name": "Mồi Sâu Bọ", "price": 15, "color": "81c784",
		"desc": "Mồi sâu bọ ruộng lúa. Hụt gốc -5%, Trung cấp +5%."},
	{"id": "paste", "name": "Thính Cám Thơm", "price": 25, "color": "ffb74d",
		"desc": "Hỗn hợp cám thơm ngào ngạt. Hụt gốc -5%, Hiếm +5%."},
]

const FISH_TIME := 15.0  # thả câu -> kéo: 15 giây
# Tỷ lệ gốc cần sơ cấp mặc định (tương thích ngược)
const ODDS_NOTHING := 0.30
const ODDS_COMMON := 0.40
const ODDS_MID := 0.20
const ODDS_RARE := 0.0999


static func get_fish(id: String) -> Dictionary:
	for f in FISH:
		if f.id == id:
			return f
	return {}


static func get_rod(tier: String) -> Dictionary:
	for r in RODS:
		if r.tier == tier:
			return r
	return {}


static func get_bait(id: String) -> Dictionary:
	for b in BAITS:
		if b.id == id:
			return b
	if id == "sau_bo":
		return get_bait("caterpillar")
	return {}


static func get_bait_name(id: String) -> String:
	var b := get_bait(id)
	return str(b.get("name", "Mồi câu")) if not b.is_empty() else ""


# Trả về bảng tỷ lệ (tổng = 1.0) theo loại cần câu và mồi gắn thêm
static func get_odds(tier: String = "basic", bait: String = "") -> Dictionary:
	var nothing: float = 0.30
	var common: float = 0.40
	var mid: float = 0.20
	var rare: float = 0.0999
	var legend: float = 0.0001

	match tier:
		"mid":
			nothing = 0.25
			common = 0.40
			mid = 0.25
			rare = 0.0999
			legend = 0.0001
		"high":
			nothing = 0.25
			common = 0.40
			mid = 0.20
			rare = 0.1499
			legend = 0.0001
		_: # "basic"
			nothing = 0.30
			common = 0.40
			mid = 0.20
			rare = 0.0999
			legend = 0.0001

	# Gắn mồi mỗi loại có tỷ lệ cố định khi gắn thêm:
	# - Trùn quế: Hụt gốc -5%, Phổ thông +5%
	# - Mồi sâu bọ: Hụt gốc -5%, Trung cấp +5%
	# - Thính cám thơm: Hụt gốc -5%, Hiếm +5%
	if bait != "":
		nothing = maxf(0.0, nothing - 0.05)
		if bait == "worm":
			common += 0.05
		elif bait == "caterpillar" or bait == "sau_bo":
			mid += 0.05
		elif bait == "paste":
			rare += 0.05

	return {
		"nothing": nothing,
		"common": common,
		"mid": mid,
		"rare": rare,
		"legend": legend,
	}


# Chọn con cá trong bậc; Cá Trê Vàng chỉ lên câu vào BAN ĐÊM (clock ngoài 7:00-19:00).
static func pick_fish(tier: String, night: bool) -> Dictionary:
	var pool: Array = []
	for f in FISH:
		if f.tier != tier:
			continue
		if f.id == "tre_vang" and not night:
			continue
		pool.append(f)
	if pool.is_empty():
		pool = FISH.filter(func(f): return f.tier == tier)
	return pool[randi() % pool.size()]


# Cuộn kết quả một lượt câu: "" = không cá (Hụt), ngược lại trả về Dictionary cá.
static func roll_cast(night: bool, rod_tier: String = "basic", bait: String = "") -> Dictionary:
	var odds := get_odds(rod_tier, bait)
	var r := randf()
	if r < odds.nothing:
		return {}
	var tier := "legend"
	if r < odds.nothing + odds.common:
		tier = "common"
	elif r < odds.nothing + odds.common + odds.mid:
		tier = "mid"
	elif r < odds.nothing + odds.common + odds.mid + odds.rare:
		tier = "rare"
	return pick_fish(tier, night)

