extends Sprite

var q: Quat = Quat()

func _ready() -> void:
	pass


func update_position() -> void:
	self.position.x = q.x
	self.position.y = q.y


func _process(delta):
	update_position()
