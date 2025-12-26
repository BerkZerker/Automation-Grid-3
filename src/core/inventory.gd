extends Node
class_name Inventory

signal inventory_changed

# Array of { "id": "iron_ore", "count": 10 }
var slots: Array = [] 
@export var max_slots: int = 10

func add_item(id: String, count: int) -> int:
	# Try to stack
	for slot in slots:
		if slot.id == id:
			slot.count += count
			inventory_changed.emit()
			return 0 # Remaining
	
	# New slot
	if slots.size() < max_slots:
		slots.append({"id": id, "count": count})
		inventory_changed.emit()
		return 0
	
	return count # Could not fit

func remove_item(id: String, count: int) -> bool:
	for i in range(slots.size()):
		if slots[i].id == id:
			if slots[i].count >= count:
				slots[i].count -= count
				if slots[i].count == 0:
					slots.remove_at(i)
				inventory_changed.emit()
				return true
			else:
				# Partial remove not implemented for simple check
				return false
	return false

func get_contents() -> Array:
	return slots
