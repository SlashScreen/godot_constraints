@tool
class_name SkeletonConstantModify3D
extends SkeletonModifier3D


const Utils = preload("../utils.gd")

@export var bone:StringName
@export var modifier:Transform3D
@export_enum("local", "global") var mode:int


func _process_modification() -> void:
	if bone.is_empty():
		return
	var sk:Skeleton3D = get_parent()
	if not sk:
		push_error("SkeletonLookAt3D does not have a Skeleton3d Parent.")
		return
	var id:int = Utils._get_id_from_name(sk, bone)
	if id == -1:
		push_error("No bone named %s exists." % bone)
		return
	
	if mode == 0:
		var t:Transform3D = sk.get_bone_pose(id)
		var new_t:Transform3D = t * modifier
		sk.set_bone_pose(id, new_t)
	else:
		var t:Transform3D = sk.get_bone_global_pose(id)
		var new_t:Transform3D = t * modifier
		sk.set_bone_global_pose(id, new_t)


func _get_configuration_warnings() -> PackedStringArray:
	var errs:Array[String] = []
	if get_parent() is Skeleton3D:
		var sk:Skeleton3D = get_parent() as Skeleton3D
		if not bone.is_empty() and Utils._get_id_from_name(sk, bone) == -1:
			errs.append("No bone named %s exists." % bone)
	else:
		errs.append("Parent is not a Skeleton3D!")
	return PackedStringArray(errs)
