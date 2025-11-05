extends Node2D

@onready var lasers = $Lasers;
@onready var asteroids = $Asteroids;
@onready var player = $Player;

var asteroid_scene = preload("res://Scenes/asteroid.tscn");

func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size) -> void:
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				_spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				_spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func _spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate();
	a.global_position = pos;
	a.size = size;
	a.connect("exploded", _on_asteroid_exploded);
	asteroids.call_deferred("add_child", a)
