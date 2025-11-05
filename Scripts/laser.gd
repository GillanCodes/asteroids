extends Area2D

var _movevement_vector: Vector2 = Vector2(0, -1);
@export var speed:float = 250;

func _physics_process(delta):
	global_position += _movevement_vector.rotated(rotation) * speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free();


func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		var asteroid = area;
		asteroid.explode();
		queue_free();
