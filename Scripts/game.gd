extends Node2D

@onready var lasers = $Lasers;
@onready var asteroids = $Asteroids;
@onready var player = $Player;
@onready var hud = $UI/HUD;
@onready var game_over_screen = $UI/GameOverScreen;
@onready var player_spawn_point = $PlayerSpawnPoint;
@onready var player_spawn_area = $PlayerSpawnPoint/PlayerSpawnArea;

var asteroid_scene = preload("res://Scenes/asteroid.tscn");

var score:int = 0:
	set(value):
		score = value;
		hud.score = score;

var lives: int = 3:
	set(value):
		lives = value;
		hud.init_lives(lives)

func _ready() -> void:
	score = 0;
	lives = 3;
	game_over_screen.visible = false;
	player.connect("laser_shot", _on_player_laser_shot);
	player.connect("died", _on_player_died);
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser)

func _on_player_died() -> void:
	lives -= 1;
	if lives <= 0:
		game_over_screen.visible = true;
	else:
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout;
		player.respawn(player_spawn_point.global_position);
	

func _on_asteroid_exploded(pos, size, points) -> void:
	score += points;
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				_spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM);
			Asteroid.AsteroidSize.MEDIUM:
				_spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass;

func _spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate();
	a.global_position = pos;
	a.size = size;
	a.connect("exploded", _on_asteroid_exploded);
	asteroids.call_deferred("add_child", a);
