extends Control

@onready var btn_2: Button = $VBox/DurationRow/Btn2
@onready var btn_5: Button = $VBox/DurationRow/Btn5
@onready var btn_10: Button = $VBox/DurationRow/Btn10
@onready var start_btn: Button = $VBox/StartBtn
@onready var finding_box: Control = $FindingBox
@onready var finding_label: Label = $FindingBox/FindingText
@onready var finding_sub: Label = $FindingBox/SubText
@onready var vbox: Control = $VBox

var style_gold: StyleBox = preload("res://Resources/btn_gold.tres")
var style_blue: StyleBox = preload("res://Resources/btn_blue.tres")

var selected_min: int = 5

func _ready() -> void:
	finding_box.visible = false
	vbox.visible = true
	_update_buttons()
	
	btn_2.pressed.connect(func(): selected_min = 2; _update_buttons())
	btn_5.pressed.connect(func(): selected_min = 5; _update_buttons())
	btn_10.pressed.connect(func(): selected_min = 10; _update_buttons())
	
	start_btn.pressed.connect(_on_start_pressed)

func _update_buttons() -> void:
	btn_2.add_theme_stylebox_override("normal", style_gold if selected_min == 2 else style_blue)
	btn_5.add_theme_stylebox_override("normal", style_gold if selected_min == 5 else style_blue)
	btn_10.add_theme_stylebox_override("normal", style_gold if selected_min == 10 else style_blue)

func _on_start_pressed() -> void:
	vbox.visible = false
	finding_box.visible = true
	finding_sub.text = str(selected_min) + "-minute arena · connecting to players"
	
	# After 1.2s transition to play
	await get_tree().create_timer(1.2).timeout
	GameManager.start_game("quick", selected_min)

