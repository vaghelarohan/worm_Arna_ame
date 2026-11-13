extends Control

@onready var wheel_node: Control = $HBox/WheelArea/Wheel
@onready var spin_btn: Button = $HBox/RightCol/SpinBtn
@onready var win_lbl: Label = $HBox/RightCol/WinLabel
@onready var spins_lbl: Label = $HBox/RightCol/SpinsPill/SpinsLabel
@onready var countdown_lbl: Label = $HBox/RightCol/CountdownLabel

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
	GameManager.check_wheel_daily_refresh()
	_update_ui()

func _process(_delta: float) -> void:
	if not _spinning:
		_update_countdown()

func _update_ui() -> void:
	var spins: int = GameManager.wheel_spins_available
	spins_lbl.text = "SPINS AVAILABLE: %d" % spins
	
	if spins > 0:
		spin_btn.disabled = false
		spin_btn.text = "SPIN! (%d LEFT)" % spins
		countdown_lbl.text = "Daily free spins active"
	else:
		spin_btn.disabled = true
		spin_btn.text = "OUT OF SPINS"
		_update_countdown()

func _update_countdown() -> void:
	var spins: int = GameManager.wheel_spins_available
	if spins > 0:
		return
	
	var rem: int = GameManager.get_wheel_cooldown_remaining()
	if rem <= 0:
		GameManager.check_wheel_daily_refresh()
		_update_ui()
		return
	
	var hrs: int = rem / 3600
	var mins: int = (rem % 3600) / 60
	var secs: int = rem % 60
	countdown_lbl.text = "Next free spins in %02d:%02d:%02d" % [hrs, mins, secs]

func _on_spin_pressed() -> void:
	if _spinning:
		return
	
	# Consume spin persistently before spinning to prevent reload exploits
	if not GameManager.consume_wheel_spin():
		_update_ui()
		return
	
	_spinning = true
	spin_btn.disabled = true
	spin_btn.text = "SPINNING…"
	win_lbl.visible = false
	_update_ui()
	
	var prize_idx: int = randi() % GameManager.wheel_prizes.size()
	var seg_deg: float = 360.0 / float(GameManager.wheel_prizes.size())
	
	# Target rotation with 5 full spins
	var target_deg: float = _rot + 360.0 * 5.0 + (360.0 - fmod(_rot, 360.0)) - float(prize_idx) * seg_deg - seg_deg / 2.0
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(wheel_node, "rotation_degrees", target_deg, 4.2)
	
	await tween.finished
	_rot = target_deg
	_spinning = false
	
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
	_update_ui()
