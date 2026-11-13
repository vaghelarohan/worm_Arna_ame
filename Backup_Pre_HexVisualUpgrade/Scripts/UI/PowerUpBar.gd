extends Control

signal power_used(id: String)

@onready var btn_magnet: Button = $HBox/BtnMagnet
@onready var btn_lightning: Button = $HBox/BtnLightning
@onready var btn_shield: Button = $HBox/BtnShield
@onready var btn_rocket: Button = $HBox/BtnRocket
@onready var btn_potion: Button = $HBox/BtnPotion

var power_mapping: Dictionary = {
	"BtnMagnet": "magnet",
	"BtnLightning": "speed",
	"BtnShield": "shield",
	"BtnRocket": "double",
	"BtnPotion": "xp"
}

func _ready() -> void:
	btn_magnet.pressed.connect(func(): _use("magnet"))
	btn_lightning.pressed.connect(func(): _use("speed"))
	btn_shield.pressed.connect(func(): _use("shield"))
	btn_rocket.pressed.connect(func(): _use("double"))
	btn_potion.pressed.connect(func(): _use("xp"))

func _use(id: String) -> void:
	power_used.emit(id)

func update_hud(data: Dictionary) -> void:
	_update_slot(btn_magnet, "magnet", data)
	_update_slot(btn_lightning, "speed", data)
	_update_slot(btn_shield, "shield", data)
	_update_slot(btn_rocket, "double", data)
	_update_slot(btn_potion, "xp", data)

func _update_slot(btn: Button, id: String, data: Dictionary) -> void:
	var counts: Dictionary = data.get("counts", {})
	var effects: Dictionary = data.get("effects", {})
	var count: int = counts.get(id, 0)
	var active_time: float = effects.get(id, 0.0)
	
	var count_lbl: Label = btn.get_node("CountBadge/Num")
	count_lbl.text = str(count)
	
	var dur_badge: Panel = btn.get_node("DurationBadge")
	var dur_lbl: Label = btn.get_node("DurationBadge/Num")
	if active_time > 0.0:
		dur_badge.visible = true
		dur_lbl.text = "%ds" % ceil(active_time)
	else:
		dur_badge.visible = false

