@tool
class_name SkeletonJiggleBone3D
extends SkeletonModifier3D


# follows https://github.com/vrm-c/vrm-specification/tree/master/specification/VRMC_springBone-1.0#springbone-algorithm

const Utils = preload("../utils.gd")

@export var bone:StringName:
	set(val):
		bone = val
		_initialize_bone()
@export var motion:Curve = preload("default_motion.res")
@export var drag:float = 0.2
@export var stiffness_force:float = 0.5
@export var gravity_direction:Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@export var gravity_strength:float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _bid:int = -1
var sk:Skeleton3D:
	get:
		return get_parent() as Skeleton3D

var _prev_tail:Vector3 # position in previous frame
var _current_tail:Vector3 # position in current frame
var _bone_axis:Vector3 # direction of bone in rest state
var _bone_length:float # lenght of bone. 
var _initial_local_transform:Transform3D # rest transform
var _initial_rot:Quaternion # rest orientation of bone

var next_rot:Quaternion = Quaternion.IDENTITY


func _process_modification() -> void:
	if _bid == -1:
		return
	sk.set_bone_pose_rotation(_bid, next_rot)


func _physics_process(delta: float) -> void:
	if _bid == -1:
		return
	var next_tail:Vector3 = _inertia(delta)
	next_tail = _collide(next_tail)
	next_rot = _apply_rotation(next_tail)


func _inertia(delta:float) -> Vector3:
	var g_pos:Vector3 = sk.get_bone_global_pose(_bid).origin
	var l_rot:Quaternion = sk.get_bone_pose_rotation(_bid)
	var p_rot := Quaternion.IDENTITY
	var pid:int = sk.get_bone_parent(_bid)
	if not pid == -1:
		p_rot = sk.get_bone_global_pose(pid).basis.get_rotation_quaternion()
	
	var inertia:Vector3 = (_current_tail - _prev_tail) * (1.0 - drag)
	var stiffness:Vector3 = delta * p_rot * l_rot * _bone_axis * stiffness_force
	var external:Vector3 = delta * gravity_direction * gravity_strength
	
	var next_tail:Vector3 = _current_tail + inertia + stiffness + external
	next_tail = g_pos + (next_tail - g_pos).normalized() * _bone_length
	
	return next_tail


func _collide(next_tail:Vector3) -> Vector3:
	return next_tail


func _apply_rotation(next_tail:Vector3) -> Quaternion:
	_prev_tail = _current_tail
	_current_tail = next_tail
	var pid:int = sk.get_bone_parent(_bid)
	if pid == -1:
		return Quaternion.IDENTITY
	var p_tr:Transform3D = Transform3D() 
	if not pid == -1:
		p_tr = sk.get_bone_global_pose(pid)
	
	var to:Vector3 = (next_tail * (p_tr * _initial_local_transform).inverse()).normalized()
	return _initial_rot * Quaternion.from_euler(to) # ???


func _initialize_bone() -> void:
	_initial_local_transform = sk.get_bone_rest(_bid)
	_initial_rot = sk.get_bone_pose_rotation(_bid)
	_bone_axis = sk.get_bone_global_rest(_bid).basis.get_euler()
	var pid:int = sk.get_bone_parent(_bid)
	if pid == -1:
		_bone_length = 1.0
	var p_pos = Vector3.ZERO 
	if not pid == -1:
		sk.get_bone_rest(pid).origin
	_bone_length = _initial_local_transform.origin.distance_to(p_pos)


func _get_configuration_warnings() -> PackedStringArray:
	var errs:Array[String] = []
	if get_parent() is Skeleton3D:
		var sk:Skeleton3D = get_parent() as Skeleton3D
		if not bone.is_empty() and Utils._get_id_from_name(sk, bone) == -1:
			errs.append("No bone named %s exists." % bone)
	else:
		errs.append("Parent is not a Skeleton3D!")
	return PackedStringArray(errs)


func _validate_bone() -> void:
	if bone.is_empty():
		_bid = -1
		return
	if not sk:
		_bid = -1
		push_error("SkeletonLookAt3D does not have a Skeleton3D Parent.")
		return
	_bid = Utils._get_id_from_name(sk, bone)
	if _bid == -1:
		push_error("No bone named %s exists." % bone)
		return
