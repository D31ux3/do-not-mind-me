extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SignalHub.on_show_exit.connect(on_show_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_show_exit() -> void:
	show()
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("WINNER WINNER CHICKEN DINNER WOWERS")
