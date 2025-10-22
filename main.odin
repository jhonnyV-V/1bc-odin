package main

import "core:strconv"
import "core:bufio"
import "core:io"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	fileHandle, err := os.open("./measurements.txt")
	assert(err == 0, "failed to open file ")
	defer os.close(fileHandle)

	cityToValue := make(map[string]f64, 12500)
	defer delete(cityToValue)

	reader: bufio.Reader
	//NOTE: 294912 my l1d cache in size
	// buffer: [244912]byte
	buffer: [2048]byte
	// buffer: [107]byte ?? Why is this slower??
	bufio.reader_init_with_buf(&reader, os.stream_from_handle(fileHandle), buffer[:])
	defer bufio.reader_destroy(&reader)

	for {
		line, err := bufio.reader_read_slice(&reader, '\n')

		if err != nil {
			break
		}

		for char,i in line {
			if char == ';' {
				key := string(line[:i])
				value := strconv.atof(string(line[i+1: len(line)-1]))
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
