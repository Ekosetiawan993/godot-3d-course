extends Enemy

const simple_attacks = {
	"slice": "1H_Melee_Attack_Slice_Diagonal",
	"stab": "2H_Melee_Attack_Stab",
	#"range": "1H_Melee_Attack_Stab",
}

func _ready() -> void:
	health = 3

func _physics_process(delta: float) -> void:
	move_toward_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 5.5)
	#print(position.distance_to(player.position))
	if position.distance_to(player.position) <= attack_radius:
		stab_attack_animation()
	else:
		pass


func stab_attack_animation() -> void:
	stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attacks["slice" if rng.randi() % 2 == 0 else "stab"]
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damage(value: bool):
	$skin/Rig/Skeleton3D/BoneAttachment3D/WarriorSword.can_damage = value
