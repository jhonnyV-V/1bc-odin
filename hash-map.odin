package main

import "core:bytes"
import chash "core:hash"
import vmem "core:mem/virtual"

HashMapValue :: struct {
	key_len: u8,
	hash:    u64,
	sum:     f32,
	min:     f32,
	max:     f32,
	quanity: u32,
	key:     [100]byte,
}

HashMap :: struct {
	values:   []HashMapValue,
	capacity: int,
}

new_hash_map :: proc() -> (HashMap, vmem.Arena) {
	arena: vmem.Arena
	arena_err := vmem.arena_init_static(&arena, 10_000 * size_of(HashMapValue))
	ensure(arena_err == nil)
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

// improve access time
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
		key     = key,
		key_len = key_len,
		hash    = hash,
		sum     = value,
		min     = value,
		max     = value,
		quanity = 1,
	}
	hash_map.capacity += 1
}
