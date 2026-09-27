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

sort_hash_map_values_by_key :: proc(hash_map: ^HashMap) {
	#no_bounds_check {
		sort.quick_sort_proc(hash_map.values[:hash_map.capacity], compare_values_by_key)
	}
}

insertion_sort_map_values :: proc(hash_map: ^HashMap) {
	#no_bounds_check {
		swap: HashMapValue
		for i in 1 ..< hash_map.capacity {
			for j := i; j > 0 && hash_map.values[j - 1].hash > hash_map.values[j].hash; j -= 1 {
				swap = hash_map.values[j]
				hash_map.values[j] = hash_map.values[j - 1]
				hash_map.values[j - 1] = swap
			}
		}
	}
}
