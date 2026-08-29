package main

import "core:sort"

compare_values_by_key :: proc(lhs, rhs: HashMapValue) -> int {
	#no_bounds_check {
		i: u8 = 0
		result := 0
		for {
			if i == lhs.key_len {
				return 1
			}
			if i == rhs.key_len {
				return -1
			}
			result = sort.compare_u8s(lhs.key[i], rhs.key[i])
			if result != 0 {
				return result
			}
			i += 1
		}
	}
}

compare_values_by_hash :: proc(lhs, rhs: HashMapValue) -> int {
	#no_bounds_check {
		if lhs.hash == 0 {
			return 1
		}
		if rhs.hash == 0 {
			return -1
		}
		return sort.compare_u64s(lhs.hash, rhs.hash)
	}
}

sort_hash_map_values_by_key :: proc(city_to_station: ^HashMap) {
	#no_bounds_check {
		sort.quick_sort_proc(
			city_to_station.values[:city_to_station.capacity],
			compare_values_by_key,
		)
	}
}

sort_hash_map_values_by_hash :: proc(city_to_station: ^HashMap) {
	#no_bounds_check {
		sort.quick_sort_proc(
			city_to_station.values[:city_to_station.capacity],
			compare_values_by_hash,
		)
	}
}
