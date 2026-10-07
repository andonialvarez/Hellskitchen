class_name DataIndex
extends RefCounted
## Búsqueda por "id" en las tablas de datos (demonios, objetos, despensa,
## decoración). El índice se construye una sola vez, la primera vez que se
## pide algo, y se guarda en el diccionario `cache` de cada tabla.


static func by_id(cache: Dictionary, list: Array, id: String) -> Dictionary:
	if cache.is_empty():
		for entry in list:
			cache[entry["id"]] = entry
	return cache.get(id, {})
