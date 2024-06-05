@tool
extends EditorPlugin


const BoneEnumPlugin = preload("tools/bone_enum_plugin.gd")

var bep := BoneEnumPlugin.new()



func _enter_tree() -> void:
	add_inspector_plugin(bep)


func _exit_tree() -> void:
	remove_inspector_plugin(bep)
