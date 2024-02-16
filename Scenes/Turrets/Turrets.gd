extends Node2D

var build_type
var category
var enemy_array = []
var is_built = false
var enemy
var is_ready = true

func _ready():
	if is_built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[build_type]["range"]
		

func _physics_process(delta):
	if enemy_array.size() != 0 and is_built:
		select_enemy()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if is_ready:
			fire()
	else:
		enemy = null
	
func fire():
	is_ready = false
	if category == "bullet":
		fire_gun()
	else:
		fire_missile()
		
	enemy.on_hit(GameData.tower_data[build_type]["damage"])
	yield(get_tree().create_timer(GameData.tower_data[build_type]["rof"]), "timeout")
	is_ready = true
	
func fire_gun():
	get_node("AnimationPlayer").play("Fire")

func fire_missile():
	pass
	
func turn():
	get_node("Turret").look_at(enemy.position)

func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.offset)
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]

func _on_Range_body_entered(body):
	enemy_array.append(body.get_parent())


func _on_Range_body_exited(body):
	enemy_array.erase(body.get_parent())
