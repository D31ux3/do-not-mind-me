extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var debug_label: Label = $DebugLabel
@onready var player_detect: RayCast2D = $PlayerDetect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var warning: Sprite2D = $Warning
@onready var gasp_sound: AudioStreamPlayer2D = $GaspSound
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound

const BULLET = preload("res://scenes/bullet/bullet.tscn")

@export var patrol_points : NodePath

enum EnemyState { Patrolling, Chasing, Searching }

const SPEED : Dictionary[EnemyState,float] = {
	EnemyState.Patrolling: 60,
	EnemyState.Chasing: 110,
	EnemyState.Searching: 80
}

const FOV : Dictionary[EnemyState,float] = {
	EnemyState.Patrolling: 60,
	EnemyState.Chasing: 120,
	EnemyState.Searching: 100
}

var _waypoints : Array[Vector2] = []
var current_waypoint : int = 0

var state : EnemyState = EnemyState.Patrolling

var player_ref : Player


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("set_target"):
		navigation_agent_2d.target_position = get_global_mouse_position()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group(Player.GROUP_NAME)
	if !player_ref: queue_free()
	create_waypoints()

func create_waypoints() -> void:
	for c in get_node(patrol_points).get_children():
		_waypoints.append(c.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	detect_player()
	process_behavior()
	update_movement()
	update_raycast()
	set_label()


func get_fov_angle() -> float:
	var direction_to_player : Vector2 = global_position.direction_to(player_ref.global_position)
	var angle : float = transform.x.angle_to(direction_to_player)
	return rad_to_deg(angle)

func update_raycast() -> void:
	player_detect.look_at(player_ref.global_position)

func player_is_visible() -> bool:
	return player_detect.get_collider() is Player 

func can_see_player() -> bool:
	return abs(get_fov_angle()) < FOV[state] and player_is_visible()

func navigate_waypoint() -> void:
	if _waypoints.is_empty(): return
	navigation_agent_2d.target_position = _waypoints[current_waypoint]
	current_waypoint +=1
	if current_waypoint >= len(_waypoints):
		current_waypoint = 0

func update_movement() -> void:
	if navigation_agent_2d.is_navigation_finished():
		return
	
	var npp : Vector2 = navigation_agent_2d.get_next_path_position()
	rotation = global_position.direction_to(npp).angle()
	#navigation_agent_2d.velocity = transform.x * SPEED
	velocity = transform.x * SPEED[state]
	move_and_slide()

func process_patrolling() -> void:
	if navigation_agent_2d.is_navigation_finished():
		navigate_waypoint()

func process_chasing() -> void:
	navigation_agent_2d.target_position = player_ref.global_position

func process_searching() -> void:
	if navigation_agent_2d.is_navigation_finished():
		set_state(EnemyState.Patrolling)

func process_behavior() -> void:
	match state:
		EnemyState.Patrolling:
			process_patrolling()
		EnemyState.Chasing:
			process_chasing()
		EnemyState.Searching:
			process_searching()

func set_state( new_state : EnemyState) -> void:
	if new_state == state: return
	if state == EnemyState.Searching:
		warning.hide()
	
	if new_state == EnemyState.Searching:
		warning.show()
	elif new_state == EnemyState.Chasing:
		gasp_sound.play()
		animation_player.play("alert")
	elif new_state == EnemyState.Patrolling:
		animation_player.play("RESET")
	state = new_state

func detect_player() -> void:
	if can_see_player():
		set_state(EnemyState.Chasing)
	elif state == EnemyState.Chasing:
		set_state(EnemyState.Searching)

func set_label():
	var s : String = "Fin:%s\n" % navigation_agent_2d.is_navigation_finished()
	s += "Vis:%s FOV:%.0f\n" % [player_is_visible(),get_fov_angle()]
	s += "SEE PLAYER:%s\n" % can_see_player()
	s += "State:%s" % EnemyState.keys()[state]
	debug_label.text = s
	debug_label.rotation = -rotation


func shoot() -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = global_position
	get_tree().current_scene.call_deferred("add_child",bullet)
	laser_sound.play()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_timer_timeout() -> void:
	if state == EnemyState.Chasing:
		shoot()
