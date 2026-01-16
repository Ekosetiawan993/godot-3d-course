extends CharacterBody3D

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var base_speed := 4.0
@export var run_speed := 8.0

@onready var camera = $CameraController/Camera3D

var movement_input := Vector2.ZERO

func _physics_process(delta: float) -> void:
	#movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	
	#velocity = Vector3(movement_input.x, 0, movement_input.y) * base_speed
	move_logic(delta)
	jump_logic(delta)
	
	move_and_slide()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d := Vector2(velocity.x, velocity.z) # just move without y
	var speed := base_speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	if movement_input != Vector2.ZERO:
		vel_2d += movement_input * speed * delta
		vel_2d = vel_2d.limit_length(speed)
		#$GodetteSkin/AnimationPlayer.current_animation = "Running_B"
		$GodetteSkin.set_move_state("Running_B")
		var target_angle := -movement_input.angle() + PI/2
		$GodetteSkin.rotation.y = rotate_toward($GodetteSkin.rotation.y, target_angle, delta * 6.0)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, speed * 4.0 * delta)
		#$GodetteSkin/AnimationPlayer.current_animation = "Idle"
		$GodetteSkin.set_move_state("Idle")
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y
	#print(speed)

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"): 
			velocity.y = -jump_velocity
	var gravity := jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

# 2:00:00
