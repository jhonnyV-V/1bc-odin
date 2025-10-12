package main

import "core:bufio"
import "core:io"
import "core:fmt"
import "core:os"
import "core:strings"
// import "core:path/filepath"

//TODO: try different approach to reading from files and benchmark them
main :: proc() {
	// path, ok := filepath.abs("./measurements.txt")
	// assert(ok, "cannot read filepath")
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
		// This will allocate a string because the line might go over the backing
		// buffer and thus need to join things together
		// consider using a string builder
		// line, err := bufio.reader_read_bytes(&reader, '\n', context.allocator)
		line, err := bufio.reader_read_string(&reader, '\n', context.allocator)
		
		//way to slow for some reason?
		// buffer: [244912]byte
		// readed, err := os.read(fileHandle, buffer[:])
		if err != nil {
			break
		}
		defer delete(line, context.allocator)
		// line = strings.trim_right(line, "\r")
		// process line
	}
}
