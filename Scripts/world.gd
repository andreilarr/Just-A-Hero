extends Node2D

const PLAYER_PREFAB := preload("res://Scenes/Prefabs/player.tscn")
const STAGE_PREFABS := [
	preload("res://Scenes/Stages/stage_01.tscn"), 
	preload("res://Scenes/Stages/stage_02.tscn"),
	preload("res://Scenes/Stages/stage_03.tscn")
]

@onready var camera: Camera2D = $Camera
@onready var stage_container: Node2D = $StageContainer
@onready var actors_conteiner: Node2D = $ActorsConteiner
@onready var stage_transition: StageTransition = $UI/UIConteiner/StageTransition


var camera_initial_position := Vector2.ZERO
var current_stage_index = -1
var is_camera_locked := false
var is_stage_ready_for_loading := false
var player : Player = null

func _ready() -> void:
	camera_initial_position = camera.position
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_interim.connect(load_next_stage.bind())
	load_next_stage()

func _process(_delta: float) -> void:
	if is_stage_ready_for_loading: 
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFABS[current_stage_index].instantiate()
		stage_container.add_child(stage)
		player = PLAYER_PREFAB.instantiate()
		actors_conteiner.add_child(player)
		player.position = stage.get_player_spawn_location()
		actors_conteiner.player = player
		camera.position = camera_initial_position
		camera.reset_smoothing()
		stage_transition.end_transition()
		
	if player != null: 
		camera.position.y = (player.global_position.y - 40)
		if not is_camera_locked:
			camera.position.x = player.global_position.x
		
func load_next_stage() -> void:
	current_stage_index += 1
	if current_stage_index < STAGE_PREFABS.size():
		for actor : Node2D in actors_conteiner.get_children():
			actor.queue_free()
		
		for existing_stage in stage_container.get_children():
			existing_stage.queue_free()
		is_stage_ready_for_loading = true

		
func on_checkpoint_start() -> void:
	is_camera_locked = true
	
func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camera_locked = false
