extends Node2D

@onready var lasers = $Lasers;
@onready var asteroids = $Asteroids;
@onready var player = $Player;
@onready var hud = $UI/HUD;
@onready var game_over_screen = $UI/GameOverScreen;
@onready var player_spawn_point = $PlayerSpawnPoint;
@onready var player_spawn_area = $PlayerSpawnPoint/PlayerSpawnArea;

var asteroid_scene = preload("res://Scenes/asteroid.tscn");

var last_milestone:int = 0;

var score:int = 0:
	set(value):
		score = value;
		hud.score = score;

var lives: int = 3:
	set(value):
		lives = value;
		hud.init_lives(lives)

func _ready() -> void:
	$AudioStream/Start.play()
	score = 0;
	lives = 3;
	game_over_screen.visible = false;
	player.connect("laser_shot", _on_player_laser_shot);
	player.connect("died", _on_player_died);
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser);
	$AudioStream/LaserSound.play();

func _on_player_died() -> void:
	lives -= 1;
	if lives <= 0:
		$AudioStream/GameOver.play();
		await get_tree().create_timer(1).timeout;
		$AudioStream/GameOverScreen.play();
		game_over_screen.visible = true;
	else:
		$AudioStream/PlayerDied.play();
		await get_tree().create_timer(1).timeout;
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout;
		player.respawn(player_spawn_point.global_position);

func _on_asteroid_exploded(pos, size, points) -> void:
	score += points;
	_check_score();
	$AudioStream/AsteroidDestroyed.play();
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

func _check_score() -> void:
	# (score / 500) round down 
	# => (650/500) = 1.3 = 1 then * 500 = 500 
	# so current milestone is 500 so next is 1000
	@warning_ignore("integer_division")
	var current_milestone = floor(score / 500) * 500
	
	if current_milestone > last_milestone and current_milestone > 0:
		$AudioStream/Score_hit.play();
		last_milestone = current_milestone
	
	
