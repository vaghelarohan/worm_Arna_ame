extends Control

@onready var btn_2: GameButton = $VBox/DurationRow/Btn2
@onready var btn_5: GameButton = $VBox/DurationRow/Btn5
@onready var btn_10: GameButton = $VBox/DurationRow/Btn10
@onready var start_btn: GameButton = $VBox/StartBtn
@onready var finding_box: Control = $FindingBox
@onready var finding_label: Label = $FindingBox/FindingText
@onready var finding_sub: Label = $FindingBox/SubText
@onready var vbox: Control = $VBox

var selected_min: int = 5
var _is_starting: bool = false
var _finding_tween: Tween

func get_modal_size() -> Vector2:
	return Vector2(780, 500)

func _ready() -> void:
	finding_box.visible = false
	vbox.visible = true
	_is_starting = false
	
	_update_buttons()
	
	btn_2.pressed.connect(func(): _select_duration(2))
	btn_5.pressed.connect(func(): _select_duration(5))
	btn_10.pressed.connect(func(): _select_duration(10))
	
	start_btn.pressed.connect(_on_start_pressed)

func _select_duration(d: int) -> void:
	if _is_starting or selected_min == d:
		return
	selected_min = d
	_update_buttons()

func _update_buttons() -> void:
	btn_2.is_selected = (selected_min == 2)
	btn_5.is_selected = (selected_min == 5)
	btn_10.is_selected = (selected_min == 10)
	
	_update_labels(btn_2, selected_min == 2)
	_update_labels(btn_5, selected_min == 5)
	_update_labels(btn_10, selected_min == 10)

func _update_labels(btn: GameButton, is_sel: bool) -> void:
	var num_lbl: Label = btn.get_node_or_null("Col/Num")
	var unit_lbl: Label = btn.get_node_or_null("Col/Unit")
	var badge_lbl: Label = btn.get_node_or_null("Col/Badge")
	
	if num_lbl:
		num_lbl.add_theme_color_override("font_color", Color.WHITE)
	if unit_lbl:
		unit_lbl.add_theme_color_override("font_color", Color("#fef08a") if is_sel else Color("#93c5fd"))
	if badge_lbl:
		badge_lbl.add_theme_color_override("font_color", Color.WHITE if is_sel else Color("#38bdf8"))

func _on_start_pressed() -> void:
	if _is_starting:
		return
	_is_starting = true
	
	# Disable buttons to prevent duplicate mobile taps
	start_btn.disabled = true
	btn_2.disabled = true
	btn_5.disabled = true
	btn_10.disabled = true
	
	vbox.visible = false
	finding_box.visible = true
	finding_sub.text = "%d-minute arena · connecting to players" % selected_min
	
	# Pulsing matchmaking animation
	_animate_finding_match()
	
	# Transition to gameplay
	await get_tree().create_timer(1.2).timeout
	if _finding_tween and _finding_tween.is_valid():
		_finding_tween.kill()
	GameManager.start_game("quick", selected_min)

func _animate_finding_match() -> void:
	if _finding_tween and _finding_tween.is_valid():
		_finding_tween.kill()
	finding_label.pivot_offset = finding_label.size * 0.5
	_finding_tween = create_tween().set_loops()
	_finding_tween.tween_property(finding_label, "scale", Vector2(1.05, 1.05), 0.5).set_trans(Tween.TRANS_SINE)
	_finding_tween.tween_property(finding_label, "scale", Vector2(0.97, 0.97), 0.5).set_trans(Tween.TRANS_SINE)
