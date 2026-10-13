class_name TraceTreeData
extends Resource
## Cây vận mệnh của một vận mệnh (dùng chung cho mọi nhân vật cùng vận mệnh): nút chỉ số nhỏ + 3 nút bị động lớn.

@export var path: CharacterPath.Type = CharacterPath.Type.DESTRUCTION
@export var nodes: Array[TraceNodeData] = []


func get_node_data(node_id: StringName) -> TraceNodeData:
	for node in nodes:
		if node.id == node_id:
			return node
	return null
