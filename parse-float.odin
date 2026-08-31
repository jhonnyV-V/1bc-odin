package main

import "core:fmt"
import "core:strconv"

// the temperature value is within [-99.9, 99.9] range.
// the temp will be between 3 and 5 bytes
parse_temp :: proc(raw_temp: []byte) -> f32 {
	s := raw_temp
	is_negative := false
	result: f32 = 0
	base := 10
	i := 0

	#no_bounds_check {
		if raw_temp[0] == '-' {
			is_negative = true
			s = s[1:]
		}

		for char, i in raw_temp {
			if char == '.' {
				s = s[i + 1:]
				break
			}
			result *= 10
			result += f32(int(char - '0'))

		}
		result += f32(int(s[0] - '0')) / 10
	}
	if is_negative {
		result = -result
	}
	return result
}
