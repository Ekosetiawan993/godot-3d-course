extends Enemy

const simple_attacks = {
	"slice": "2H_Melee_Attack_Slice",
	"spin": "2H_Melee_Attack_Spin",
	#"spin": "2H_Melee_Attack_Slice",
	"range": "1H_Melee_Attack_Stab",
}
@export var spin_speed: float = 6.0
@export var is_spinning: bool = false

var can_damage: bool = false
#signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	attack_logic()

func _physics_process(delta: float) -> void:
	#if can_damage:
		#var collider = $skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/RayCast3D.get_collider()
		#if collider and "hit" in collider:
			#print("attack player")
			#collider.hit()
	move_toward_player(delta)
	
func set_can_damage(value: bool) -> void:
	can_damage = value

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 5.5)
	if position.distance_to(player.position) < 5.0:
		melee_attack_animation()
	else:
		if position.distance_to(player.position) < notice_radius:
			#range_attack_animation()
			if (rng.randi() % 2) == 0:
				range_attack_animation()
			else:
				spin_attack_animation()
	# 4 attack animation
	# 2 melee and 2 range

func spin_attack_animation() -> void:
	if not is_spinning:
		var tween = create_tween()
		tween.tween_property(self, "speed", spin_speed, 0.5)
		tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
		is_spinning = true
		can_damage = true
		$Timers/AttackTimer.stop()

func _spin_transition(value: float) -> void:
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)
 
func range_attack_animation() -> void:
	stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attacks["range"]
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func melee_attack_animation() -> void:
	stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attacks["slice" if rng.randi() % 2 == 0 else "spin"]
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_spin_limit_area_body_entered(_body: Node3D) -> void:
	if is_spinning:
		#print("stop")
		await get_tree().create_timer(rng.randf_range(0.5, 0.9)).timeout
		var tween = create_tween()
		tween.tween_property(self, "speed", walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		is_spinning = false
		can_damage = false
		$Timers/AttackTimer.start()

func hit() -> void:
	if not $Timers/InvulTimer.time_left:
		print("bos hit")
		$Timers/InvulTimer.start()
		health -= 1
		var tween = create_tween()
		tween.tween_method(_hit_effect, 0.0, 0.7, 0.3)
		tween.tween_method(_hit_effect, 0.7, 0.0, 0.1)

func _hit_effect(value: float) -> void:
	# we can create new geometry material overlay with existing shader
	# or copy the whole goddete material overlay
	#$skin/Rig/Skeleton3D/Nagonford_Body.material_overlay.set_shader_parameter("color", Color.ORANGE_RED)
	$skin/Rig/Skeleton3D/Nagonford_Body.material_overlay.set_shader_parameter("alpha", value)

func attack_logic() -> void:
	if can_damage:
		var collider = $skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/RayCast3D.get_collider()
		if collider and "hit" in collider:
			collider.hit()

func shoot_fireball():
	cast_spell.emit(
		"fireball",
		$skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/Marker3D.global_position,
		last_direction,
		3.0
	)
