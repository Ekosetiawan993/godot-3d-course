extends CharacterBody3D

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var base_speed := 5.0
@export var run_speed := 8.0
@export var defend_speed := 2.0
var speed := base_speed
var speed_modifier := 1.0
var is_running: bool = false

@onready var camera = $CameraController/Camera3D
@onready var godette_skin: Node3D = $GodetteSkin
@onready var ui = $UI
@onready var run_particles: GPUParticles3D = $RunParticles


var movement_input := Vector2.ZERO
var last_movement_input := Vector2(0, 1)
var move_type := "Idle"
var is_defend := false:
	set(value):
		if not is_defend and value:
			godette_skin.defend(true)
		elif is_defend and not value:
			godette_skin.defend(false)
		is_defend = value
var weapon_active := true:
	set(value):
		weapon_active = value
		if weapon_active:
			ui.get_node("Spells").hide()
		else:
			ui.get_node("Spells").show()
var health = 5:
	set(value):
		ui.update_health(value, value - health)
		health = value
		if health <= 0:
			get_tree().quit()
var energy = 100:
	set(value):
		energy = min(100, value)
		ui.update_energy(energy)
var stamina = 100:
	set(value):
		ui.update_stamina(stamina, value)
		if stamina == 100 and value < 100:
			ui.change_stamina_alpha(1.0)
		elif value >= 100:
			ui.change_stamina_alpha(0.0)
		stamina = clamp(value, 0, 100)

enum spells {FIREBALL, HEAL}
var current_spell = spells.FIREBALL

signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)

func _ready() -> void:
	weapon_active = true
	godette_skin.switch_weapon(weapon_active)
	ui.setup(health)

func _physics_process(delta: float) -> void:
	# 9: 42
	RenderingServer.global_shader_parameter_set("player_position", global_position)
	#movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	
	#velocity = Vector3(movement_input.x, 0, movement_input.y) * base_speed
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	#if Input.is_action_just_pressed("ui_accept"):
		#hit()
	move_and_slide()
	physics_logic()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d := Vector2(velocity.x, velocity.z) # just move without y
	if Input.is_action_pressed("run"):
		speed = run_speed
		is_running = true
	else:
		speed = base_speed
		is_running = false
	if is_defend:
		speed = defend_speed

	if movement_input != Vector2.ZERO:
		vel_2d += movement_input * speed * delta * 8.0
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
		#godette_skin/AnimationPlayer.current_animation = "Running_B"
		#godette_skin.set_move_state("Running_B")
		move_type = "Running_B"
		var target_angle := -movement_input.angle() + PI/2
		godette_skin.rotation.y = rotate_toward(godette_skin.rotation.y, target_angle, delta * 6.0)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, speed * 4.0 * delta)
		#godette_skin/AnimationPlayer.current_animation = "Idle"
		#godette_skin.set_move_state("Idle")
		move_type = "Idle"
	if !is_on_floor():
		move_type = "Jump_Idle"
	godette_skin.set_move_state(move_type)
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y
	#print(speed)
	if movement_input:
		last_movement_input = movement_input.normalized()
	
	run_particles.emitting = is_on_floor() and is_running and movement_input != Vector2.ZERO

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= 20: 
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			stamina -= 20 
		#godette_skin.set_move_state("Jump")
	var gravity := jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

func ability_logic() -> void:
	# actual attack
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			godette_skin.attack()
		else:
			if energy >= 20:
				godette_skin.cast_spell()
				stop_movement(0.3, 0.8)
				energy -= 10
	
	# defend
	is_defend = Input.is_action_pressed("block")
	
	# switch weapon / magic
	if Input.is_action_just_pressed("switch weapon") and not godette_skin.attacking:
		weapon_active = not weapon_active
		godette_skin.switch_weapon(weapon_active)
		do_squash_and_stretch(1.2, 0.15)
	# switch spell
	if Input.is_action_just_pressed("switch spell") and not godette_skin.attacking and not weapon_active:
		current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		ui.update_spell(spells, current_spell)
		

func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	if not $InvulTimer.time_left:
		print("player hit")
		godette_skin.hit()
		stop_movement(0.3, 0.3)
		health -= 1
		$InvulTimer.start()

func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(godette_skin, "squash_and_stretch", value, duration)
	tween.tween_property(godette_skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)

func shoot_magic(pos: Vector3):
	if current_spell == spells.FIREBALL:
		cast_spell.emit("fireball", pos, last_movement_input, 1)
	elif current_spell == spells.HEAL:
		health += 1
		godette_skin.heal_tween()

func _on_energy_recover_timer_timeout() -> void:
	if energy < 100:
		energy += 1



# 9: 03: 00 , visual shader not having albedo, change to fragment, water shader
# 9: 27: 30 , grass shader
# 9: 33: 10, grass fragment shader
# 9: 47: 00, one blade of grass, proton scater for a lot of grass
# 9: 52: 00, fireball shader
# 10: 06: 50, player shader, on material overlay
# 10: 12: 50, control player body shader with code
# 10: 17: 00, player shader when hit


func _on_stamina_recover_timer_timeout() -> void:
	if stamina < 100:
		stamina += 1


func physics_logic() -> void:
	# movinf rigid body object
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-get_slide_collision(i).get_normal())
