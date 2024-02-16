extends Node2D

var map_node

var current_wave = 0
var enemies_in_wave = 0

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

func _ready():
	
	## Get a reference to the node named "Map1" and store it in the `map_node` variable.
	## This represents a map or level-related node.
	map_node = get_node("Map1")
	
	# Iterate through all nodes in the scene tree that belong to the group "build_buttons".
	## These are assumed to be UI buttons for initiating build mode.	
	for button in get_tree().get_nodes_in_group("build_buttons"):
		
		## Connect each button's "pressed" signal to the local function "initiate_build_mode".
		## This means that whenever a button in this group is pressed, the `initiate_build_mode` function will be called.
		## Additionally, pass the button's name as an argument to the function, for identification purposes.
		button.connect("pressed", self, "initiate_build_mode", [button.get_name()])
	
func _process(delta):
	if build_mode:
		update_tower_preview()
	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()
		
##
## ENEMY WAVE FUNCTIONS
##
func start_next_wave():
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2),"timeout") ## interval between waves so enemies does not instant spawn
	spawn_enemies(wave_data)
	
	
func retrieve_wave_data():
	var wave_data = [["BlueTank", 0.7], ["BlueTank", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data
		
func spawn_enemies(wave_data):
	for enemy in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + enemy[0] + ".tscn").instance()
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(enemy[1]),"timeout")
##
## TOWER BUIDLING FUNCTIONS
##

## This function is called when a build button is pressed, triggering build mode.
## It takes a string argument representing the type of tower (Gun or Missile) to be built.
func initiate_build_mode(tower_type):
	
	if build_mode:
		cancel_build_mode()
	## Construct the full tower type name by appending "T1" to the provided `tower_type`.
	build_type = tower_type + "T1"
	
	## Set the `build_mode` flag to True, indicating that build mode is now active.
	build_mode = true
	
	## Get a reference to the node named "UI" and call its `set_tower_preview` method.
	## This function interacts with the UI to show a preview of the chosen tower.
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "8061cc26")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "99d42121")
		build_valid = false
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.is_built = true
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cellv(build_tile, 5)
	
	

