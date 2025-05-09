extends CharacterBody2D

class_name Player

const GROUP_NAME  : String = "Player"

var speed : float = 160

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move()
	move_and_slide()

func move() -> void:
	var move_vector : Vector2 = Vector2.ZERO
	move_vector.x = Input.get_axis("move_left","move_right")
	move_vector.y = Input.get_axis("move_up","move_down")
	
	velocity = move_vector.normalized() * speed
	rotation = velocity.angle()
	
