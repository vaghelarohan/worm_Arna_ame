extends Control

signal closed

@onready var title_lbl: Label = $CenterContainer/Panel/Header/Title
@onready var close_btn: Button = $CenterContainer/Panel/Header/CloseBtn
@onready var content_slot: Control = $CenterContainer/Panel/ContentSlot
@onready var bg_overlay: Button = $Backdrop

func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	bg_overlay.pressed.connect(_on_close)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()

func set_title(t: String) -> void:
	title_lbl.text = t

func set_content(node: Node) -> void:
	for c in content_slot.get_children():
		c.queue_free()
	content_slot.add_child(node)

func _on_close() -> void:
	SoundManager.play_click(440.0)
	closed.emit()
	queue_free()

