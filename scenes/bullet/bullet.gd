extends Area2D

const SPEED : float = 250

var dir : Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p : Player= get_tree().get_first_node_in_group(Player.GROUP_NAME)
	if !p: queue_free()
	else:
		dir = global_position.direction_to(p.global_position) * SPEED
		look_at(p.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += dir * delta


func _on_body_entered(body: Node2D) -> void:
	queue_free()


func _on_screen_notifier_screen_exited() -> void:
	queue_free()
