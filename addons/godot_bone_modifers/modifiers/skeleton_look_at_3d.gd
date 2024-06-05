@tool
class_name SkeletonLookAt3D
extends SkeletonModifier3D


const Utils = preload("../utils.gd")

@export var bone:StringName
@export var target:Node3D
@export var up_axis:Vector3 = Vector3.UP
@export var use_model_front:bool = false


func _process_modification() -> void:
	if not target:
		return
	if bone.is_empty():
		return
	if target.global_position.is_zero_approx():
		return
	var sk:Skeleton3D = get_parent()
	if not sk:
		push_error("SkeletonLookAt3D does not have a Skeleton3D Parent.")
		return
	var id:int = Utils._get_id_from_name(sk, bone)
	if id == -1:
		push_error("No bone named %s exists." % bone)
		return
	
	var t:Transform3D = sk.get_bone_global_pose(id)
	var new_t:Transform3D = t.looking_at(target.global_position, up_axis, use_model_front)
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
