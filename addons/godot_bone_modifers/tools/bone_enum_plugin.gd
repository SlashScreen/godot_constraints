extends EditorInspectorPlugin


const BONE_SELECTOR = preload("bone_selector.gd")


func _can_handle(object: Object) -> bool:
	if  object is SkeletonLookAt3D or\
		object is SkeletonLookAt3D or\
		object is SkeletonConstantModify3D or\
		object is SkeletonMatchTransform3D or\
		object is SkeletonConstraint3D or\
		object is SkeletonJiggleBone3D:
			return true
	else:
		return false


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if object.get_parent() is not Skeleton3D:
		return false
	if name == "bone":
		add_property_editor("bone", BONE_SELECTOR.new())
		return true 
	return false
