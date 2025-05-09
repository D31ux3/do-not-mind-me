extends Area2D


@onready var sound: AudioStreamPlayer2D = $Sound

const GROUP_NAME : String = "PickUp"

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _on_body_entered(body: Node2D) -> void:
	set_deferred("monitoring",false)
	hide()
	sound.play()
	if body is Player:
		SignalHub.on_pickup_collected.emit()


func _on_sound_finished() -> void:
	queue_free()
