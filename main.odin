package main

import "core:bufio"
import "core:io"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	fileHandle, err := os.open("./measurements.txt")
	fmt.println("err:", err)
	assert(err == 0, "failed to open file ")
	defer os.close(fileHandle)

	reader: bufio.Reader
	//NOTE: 294912 my l1d cache in size
	// buffer: [244912]byte
	buffer: [2048]byte
	//NOTE: maybe I could use the os.stream_from_handle to use the io.Stream methods and read
	//in a buffered way
	bufio.reader_init_with_buf(&reader, os.stream_from_handle(fileHandle), buffer[:])
	// NOTE: bufio.reader_init can be used if you want to use a dynamic backing buffer
	defer bufio.reader_destroy(&reader)

	for {
		line, err := bufio.reader_read_slice(&reader, '\n')

		if err != nil {
			break
		}
	}
}
