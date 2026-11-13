extends Control

signal closed

@onready var title_lbl: Label = $CenterContainer/Panel/Header/Title
@onready var close_btn: Button = $CenterContainer/Panel/Header/CloseBtn
@onready var content_slot: Control = $CenterContainer/Panel/ContentSlot
@onready var bg_overlay: Button = $Backdrop

var _closing: bool = false

func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	bg_overlay.pressed.connect(_on_close)
	
	var panel: Panel = $CenterContainer/Panel
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	panel.scale = Vector2(0.88, 0.88)
	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, 0.18)

func set_panel_size(sz: Vector2) -> void:
	var panel: Panel = $CenterContainer/Panel
	var vp_size: Vector2 = get_viewport_rect().size
	var max_w: float = vp_size.x * 0.94 if vp_size.x > 0 else 1920.0
	var max_h: float = vp_size.y * 0.92 if vp_size.y > 0 else 1080.0
	var final_w: float = clamp(sz.x, 600.0, max_w)
	var final_h: float = clamp(sz.y, 440.0, max_h)
	var target_sz := Vector2(final_w, final_h)
	panel.custom_minimum_size = target_sz
	panel.size = target_sz
	panel.pivot_offset = target_sz * 0.5

func _unhandled_input(event: InputEvent) -> void:
	if visible and not _closing and event.is_action_pressed("ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()

func set_title(t: String) -> void:
	title_lbl.text = t

func set_content(node: Node) -> void:
	for c in content_slot.get_children():
		c.queue_free()
	if node is Control:
		node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_slot.add_child(node)
	if node.has_method("get_modal_size"):
		set_panel_size(node.get_modal_size())

func _on_close() -> void:
	if _closing:
		return
	_closing = true
	SoundManager.play_click(440.0)
	closed.emit()
	
	var panel: Panel = $CenterContainer/Panel
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(panel, "modulate:a", 0.0, 0.14)
	await tw.finished
	queue_free()
