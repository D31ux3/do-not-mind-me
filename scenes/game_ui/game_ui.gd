extends Control

@onready var label: Label = $MarginContainer/Label

var pick_ups_collected : int = 0 
var total_pick_ups : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.on_pickup_collected.connect(on_pickup_collected)
	total_pick_ups = len(get_tree().get_nodes_in_group("PickUp"))
	label.text = str(pick_ups_collected) + " / " + str(total_pick_ups)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		GameManager.load_main_scene()

func on_pickup_collected() -> void:
	pick_ups_collected += 1
	label.text = str(pick_ups_collected) + " / " + str(total_pick_ups)
	if pick_ups_collected >= total_pick_ups:
		SignalHub.on_show_exit.emit()
