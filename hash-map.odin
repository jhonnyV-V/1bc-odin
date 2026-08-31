package main

import chash "core:hash"
import vmem "core:mem/virtual"

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

get_hash :: proc(key: []byte, key_len: u8) -> u64 {
	// return chash.murmur64b(key[:key_len]) //1351ms
	// return chash.crc64_iso_3306(key[:key_len], 0x9e370001) //1426ms
	// return chash.crc64_iso_3306(key[:key_len]) //1414ms
	// return chash.murmur64a(key[:key_len]) //1320ms
	// return chash.crc64_ecma_182(key[:key_len]) //1406ms
	// return chash.crc64_xz(key[:key_len]) //1498ms
	// return chash.crc64_iso_3306_inverse(key[:key_len]) //1438ms
	// return chash.fnv64(key[:key_len]) //1278ms
	// return chash.fnv64a(key[:key_len]) //1297ms
	// return chash.fnv64_no_a(key[:key_len]) //1278ms
	return chash.fnv64(key[:key_len])
}

get_hash_map_item :: proc(
	key: ^[]byte,
	key_len: u8,
	hash: u64,
	hash_map: ^HashMap,
) -> ^HashMapValue {
	#no_bounds_check {
		start := 0
		end := hash_map.capacity
		for start < end {
			middle := (start + end) / 2
			current := &hash_map.values[middle]
			if current.hash == hash {
				return current
			} else if hash < current.hash {
				//target left of the middle
				end = middle
			} else {
				start = middle + 1
			}
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

	#no_bounds_check {
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
}
