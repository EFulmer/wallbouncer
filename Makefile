build:
	odin build -file main.odin

build-and-run: build
	odin run .
