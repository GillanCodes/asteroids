extends Node2D

@onready var lasers = $Lasers;
@onready var player = $Player;

func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser)
