extends Control

@onready var wheel_node: Control = $HBox/WheelArea/Wheel
@onready var spin_btn: Button = $HBox/RightCol/SpinBtn
@onready var win_lbl: Label = $HBox/RightCol/WinLabel

var _spinning: bool = false
var _rot: float = 0.0

var wheel_colors = [
	Color("#ef4444"), # destructive
	Color("#fbbf24"), # gold
	Color("#84cc16"), # lime
	Color("#22d3ee"), # cyan
	Color("#1e293b"), # navy
	Color("#a855f7"), # purple
	Color("#d97706"), # gold-deep
	Color("#f43f5e")  # accent
]

func _ready() -> void:
	win_lbl.visible = false
	spin_btn.pressed.connect(_on_spin_pressed)

func _on_spin_pressed() -> void:
	if _spinning:
		return
	
	_spinning = true
	spin_btn.disabled = true
	spin_btn.text = "SPINNING…"
	win_lbl.visible = false
	
	var prize_idx: int = randi() % GameManager.wheel_prizes.size()
	var seg_deg: float = 360.0 / float(GameManager.wheel_prizes.size())
	
	# Target rotation with 5 full spins
	var target_deg: float = _rot + 360.0 * 5.0 + (360.0 - fmod(_rot, 360.0)) - float(prize_idx) * seg_deg - seg_deg / 2.0
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(wheel_node, "rotation_degrees", target_deg, 4.2)
	
	await tween.finished
	_rot = target_deg
	_spinning = false
	spin_btn.disabled = false
	spin_btn.text = "SPIN!"
	
	var prize: String = GameManager.wheel_prizes[prize_idx]
	win_lbl.text = "You won " + prize + "!"
	win_lbl.visible = true
	
	# Award reward
	if "Coins" in prize:
		var amount: int = prize.to_int()
		GameManager.add_coins(amount)
	elif "Gems" in prize:
		var amount: int = prize.to_int()
		GameManager.add_diamonds(amount)
	elif prize == "Speed":
		GameManager.buy_booster("Speed Rush", 0)
	elif prize == "Shield":
		GameManager.buy_booster("Shield", 0)
	elif prize == "Magnet":
		GameManager.buy_booster("Magnet", 0)
	
	SoundManager.play_click(990.0)

