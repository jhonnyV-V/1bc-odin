package main

import "core:bufio"
import "core:fmt"
import "core:hash"
import "core:io"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

v1 :: proc() {
	fileHandle, err := os.open("./1M.txt")
	assert(err == 0, "failed to open file ")
	defer os.close(fileHandle)

	cityToValue := make(map[string]f64, 12500)
	defer delete(cityToValue)

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
				key := string(line[:i])
				value, _ := strconv.parse_f64(string(line[i + 1:len(line) - 1]))
				if !(key in cityToValue) {
					cityToValue[key] = 0
				}
				// cityToValue[key] =+ value
				// cityToValue[string(line[:i])] = 0
				// cityToValue[string(line[:i])] = strconv.atof(string(line[i+1: len(line)-1]))
				break
			}
		}
	}
}

v2 :: proc() {
	fileHandle, err := os.open("./1M.txt")
	assert(err == 0, "failed to open file ")
	defer os.close(fileHandle)

	cityToValue, arena := new_hash_map()
	defer vmem.arena_destroy(&arena)

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
				exist := get_hash_map_item(&line, u8(i), hash, &cityToValue)
				value, _ := strconv.parse_f64(string(line[i + 1:len(line) - 1]))
				if exist == nil {
					create_hash_map_item(
						(^([100]byte))(&line[0])^,
						u8(i),
						hash,
						value,
						&cityToValue,
					)
					continue
				}
				exist.value += value
				// cityToValue[key] =+ value
				// cityToValue[string(line[:i])] = 0
				// cityToValue[string(line[:i])] = strconv.atof(string(line[i+1: len(line)-1]))
				break
			}
		}
	}
}

main :: proc() {
	v2()
}
