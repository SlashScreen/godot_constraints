extends RefCounted


static func _get_id_from_name(sk:Skeleton3D, n:StringName) -> int:
	for i:int in range(sk.get_bone_count()):
		if sk.get_bone_name(i) == n:
			return i
	return -1
