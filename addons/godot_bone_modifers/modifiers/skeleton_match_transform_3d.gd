@tool
class_name SkeletonMatchTransform3D
extends SkeletonModifier3D


const Utils = preload("../utils.gd")

@export var bone:StringName
@export var target:Node3D

@export_flags("X", "Y", "Z") var match_translation:int = X | Y | Z
@export_flags("X", "Y", "Z") var match_rotation:int = X | Y | Z
@export_flags("X", "Y", "Z") var match_scale:int = X | Y | Z

enum {
	X = 0b001,
	Y = 0b010,
	Z = 0b100,
}


func _process_modification() -> void:
	if not target:
		return
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
	
	sk.set_bone_pose(id, _match_transform(sk.get_bone_pose(id), target.transform))


func _match_transform(source:Transform3D, from:Transform3D) -> Transform3D:
	var output := Transform3D()
	
	# Translate
	var s_pos:Vector3 = source.origin
	var f_pos:Vector3 = from.origin
	output.origin = Vector3(
		f_pos.x if match_translation & X == X else s_pos.x,
		f_pos.y if match_translation & Y == Y else s_pos.y,
		f_pos.z if match_translation & Z == Z else s_pos.z,
	)
	
	# Rotate
	var s_rot:Vector3 = source.basis.get_euler()
	var f_rot:Vector3 = from.basis.get_euler()
	output.basis = Basis.from_euler(Vector3(
		f_rot.x if match_rotation & X == X else s_rot.x,
		f_rot.y if match_rotation & Y == Y else s_rot.y,
		f_rot.z if match_rotation & Z == Z else s_rot.z,
	))
	
	# Scale
	var s_sca:Vector3 = source.basis.get_scale()
	var f_sca:Vector3 = from.basis.get_scale()
	output = output.scaled(Vector3(
		f_sca.x if match_scale & X == X else s_sca.x,
		f_sca.y if match_scale & Y == Y else s_sca.y,
		f_sca.z if match_scale & Z == Z else s_sca.z,
	))
	
	return output


func _get_configuration_warnings() -> PackedStringArray:
	var errs:Array[String] = []
	if get_parent() is Skeleton3D:
		var sk:Skeleton3D = get_parent() as Skeleton3D
		if not bone.is_empty() and Utils._get_id_from_name(sk, bone) == -1:
			errs.append("No bone named %s exists." % bone)
	else:
		errs.append("Parent is not a Skeleton3D!")
	return PackedStringArray(errs)
