extends EditorInspectorPlugin


const BONE_SELECTOR = preload("bone_selector.gd")


func _can_handle(object: Object) -> bool:
	match object:
		SkeletonLookAt3D, \
		SkeletonConstantModify3D, \
		SkeletonMatchTransform3D, \
		SkeletonConstraint3D, \
		SkeletonJiggleBone3D:
			return true
		_:
			return false


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if not object.get_parent() is Skeleton3D:
		return false
	if name == "bone":
		add_property_editor("bone", BONE_SELECTOR.new())
		return true 
	return false
