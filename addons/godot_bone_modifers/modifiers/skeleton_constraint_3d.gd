@tool
class_name SkeletonConstraint3D
extends SkeletonModifier3D


const Utils = preload("../utils.gd")

@export var bone:StringName

@export_category("Rotation")
@export_range(0.0, 360.0) var x_limit_min:float = 0.0
@export_range(0.0, 360.0) var x_limit_max:float = 360.0
@export_range(0.0, 360.0) var y_limit_min:float = 0.0
@export_range(0.0, 360.0) var y_limit_max:float = 360.0
@export_range(0.0, 360.0) var z_limit_min:float = 0.0
@export_range(0.0, 360.0) var z_limit_max:float = 360.0


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
	
	sk.set_bone_pose_rotation(id, _limit_rotation(sk.get_bone_pose_rotation(id).get_euler()))


func _limit_rotation(old:Vector3) -> Quaternion:
	var new := clamp(old, 
		Vector3(deg_to_rad(x_limit_min), deg_to_rad(y_limit_min), deg_to_rad(z_limit_min)),
		Vector3(deg_to_rad(x_limit_max), deg_to_rad(y_limit_max), deg_to_rad(z_limit_max)),
		)
	return Quaternion.from_euler(new)


func _get_configuration_warnings() -> PackedStringArray:
	var errs:Array[String] = []
	if get_parent() is Skeleton3D:
		var sk:Skeleton3D = get_parent() as Skeleton3D
		if not bone.is_empty() and Utils._get_id_from_name(sk, bone) == -1:
			errs.append("No bone named %s exists." % bone)
	else:
		errs.append("Parent is not a Skeleton3D!")
	return PackedStringArray(errs)
