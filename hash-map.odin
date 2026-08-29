package main

import "core:bytes"
import chash "core:hash"
import vmem "core:mem/virtual"
import "core:sort"

HashMapValue :: struct {
	key_len:  u8,
	hash:     u64,
	sum:      f32,
	min:      f32,
	max:      f32,
	quantity: u32,
	key:      [100]byte,
}

HashMap :: struct {
	values:   []HashMapValue,
	capacity: int,
}

new_hash_map :: proc() -> (HashMap, vmem.Arena) {
	arena: vmem.Arena
	arena_err := vmem.arena_init_static(&arena, 10_000 * size_of(HashMapValue))
	ensure(arena_err == nil, "Failed to init arena")
	arena_alloc := vmem.arena_allocator(&arena)

	hash_map := HashMap {
		values   = make([]HashMapValue, 10_000, arena_alloc),
		capacity = 0,
	}

	return hash_map, arena
}

get_hash :: proc(key: ^[]byte, key_len: u8) -> u64 {
	return chash.crc64_iso_3306(key[:key_len], 0x9e370001)
}

compare_values_by_key :: proc(lhs, rhs: HashMapValue) -> int {
	i: u8 = 0
	result := 0
	for {
		if i == lhs.key_len {
			return 1
		}
		if i == rhs.key_len {
			return -1
		}
		result = sort.compare_u8s(lhs.key[0], rhs.key[0])
		if result != 0 {
			return result
		}
		i += 1
	}
}

compare_values_by_hash :: proc(lhs, rhs: HashMapValue) -> int {
	if lhs.hash == 0 {
		return 1
	}
	if rhs.hash == 0 {
		return -1
	}
	return sort.compare_u64s(lhs.hash, rhs.hash)
}

sort_hash_map_values_by_key :: proc(city_to_station: ^HashMap) {
	sort.quick_sort_proc(city_to_station.values[:city_to_station.capacity], compare_values_by_key)
}

sort_hash_map_values_by_hash :: proc(city_to_station: ^HashMap) {
	sort.quick_sort_proc(city_to_station.values[:city_to_station.capacity], compare_values_by_hash)
}

//NOTE:
// try something in this vein to iterate over the mapindex = (index + 1) % m->capacity;
// try this approach and try sorting by hash key, that way something like a binary search could be possible
get_hash_map_item :: proc(
	key: ^[]byte,
	key_len: u8,
	hash: u64,
	hash_map: ^HashMap,
) -> ^HashMapValue {
	for i in 0 ..< hash_map.capacity {
		if hash_map.values[i].hash == hash {
			//WARNING: remove or use ODIN_DISABLE_ASSERT when executing
			assert(
				hash_map.values[i].key_len == key_len &&
				bytes.compare(
					key[:key_len],
					hash_map.values[i].key[:hash_map.values[i].key_len],
				) ==
					0,
				"no hash collitions",
			)
			return &hash_map.values[i]
		}
	}
	return nil
}

create_hash_map_item :: proc(
	key: [100]byte,
	key_len: u8,
	hash: u64,
	value: f32,
	hash_map: ^HashMap,
) {
	hash_map.values[hash_map.capacity] = HashMapValue {
		key      = key,
		key_len  = key_len,
		hash     = hash,
		sum      = value,
		min      = value,
		max      = value,
		quantity = 1,
	}
	hash_map.capacity += 1
}
