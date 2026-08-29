package main

import "core:bufio"
import "core:fmt"
import "core:hash"
import "core:math"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

// the temperature value is within [-99.9, 99.9] range.
// the temp will be between 3 and 5 bytes
// check how odin parses f32
parse_temp :: proc(raw_temp: []byte) -> f32 {
	value, _ := strconv.parse_f32(string(raw_temp))
	return value
}

populate_from_file :: proc(city_to_station: ^HashMap) {
	fileHandle, err := os.open("./10M.txt")
	assert(err == 0, "failed to open file ")
	defer os.close(fileHandle)
	reader: bufio.Reader
	//NOTE: 294912 my l1d cache in size
	// buffer: [244912]byte
	buffer: [2048]byte
	// buffer: [107]byte ?? Why is this slower??
	bufio.reader_init_with_buf(&reader, os.to_stream(fileHandle), buffer[:])
	defer bufio.reader_destroy(&reader)


	for {
		line, err := bufio.reader_read_slice(&reader, '\n')

		if err != nil {
			break
		}

		for char, i in line {
			if char == ';' {
				hash := get_hash(&line, u8(i))
				station := get_hash_map_item(&line, u8(i), hash, city_to_station)
				value := parse_temp(line[i + 1:len(line) - 1])
				if station == nil {
					create_hash_map_item(
						(^([100]byte))(&line[0])^,
						u8(i),
						hash,
						value,
						city_to_station,
					)
					insertion_sort_map_values(city_to_station)
					continue
				}
				station.sum += value
				if station.min > value {
					station.min = value
				} else if station.max < value {
					station.max = value
				}
				station.quantity += 1
				break
			}
		}
	}
}

//NOTE: how fast can I write to std output?
print_results :: proc(city_to_station: ^HashMap) {
	#no_bounds_check {
		out := os.to_writer(os.stdout)
		for i in 0 ..< city_to_station.capacity {
			station := city_to_station.values[i]
			fmt.wprintf(
				out,
				"%s=%.1f/%.1f/%.1f\n",
				station.key[:station.key_len],
				station.min,
				math.ceil(station.sum / f32(station.quantity)),
				station.max,
			)
		}
	}
}

main :: proc() {
	city_to_station, arena := new_hash_map()
	defer vmem.arena_destroy(&arena)

	populate_from_file(&city_to_station)

	sort_hash_map_values_by_key(&city_to_station)

	print_results(&city_to_station)
}
