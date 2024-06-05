extends EditorProperty


var option_button: OptionButton = OptionButton.new()
var sk:Skeleton3D
var updating:bool
var current:StringName


func _init() -> void:
	add_child(option_button)
	add_focusable(option_button)
	option_button.item_selected.connect(_on_option_button_item_selected.bind())


func _ready() -> void:
	sk = get_edited_object().get_parent() as Skeleton3D
	for i:int in sk.get_bone_count():
		option_button.add_item(sk.get_bone_name(i))


func _on_option_button_item_selected(index: int) -> void:
	if not updating:
		current = option_button.get_item_text(index)
		emit_changed(get_edited_property(), current)


func _update_property() -> void:
	var new_value:StringName = get_edited_object()[get_edited_property()]
	if (new_value == current):
		return
	
	updating = true 
	current = new_value
	for i:int in option_button.item_count:
		if option_button.get_item_text(i) == new_value:
			option_button.selected = i
			break
	updating = false
