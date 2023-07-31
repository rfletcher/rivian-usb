all: cli image

## CLI ##

cli_shell_scripts := \
	$(shell find cli/src -type f -exec file "{}" \; | grep 'shell script' | cut -d : -f 1) \
	$(shell find cli/src -type f -name '*.bash')

cli: cli_validate cli_lint cli_test

cli_test:
	@true

cli_lint:
	@echo CLI: Checking shell script style...
	@shellcheck --severity style \
		--exclude SC1091,SC2155 \
		$(cli_shell_scripts)

cli_validate:
	@echo CLI: Validating shell scripts...
	@shellcheck --severity warning \
		--exclude SC2155 \
		$(cli_shell_scripts)

## OS Image ##

image: image_test image_build

image_build: image_build_prepare image_build_run

image_build_prepare:
	@echo "Image: Configuring image..."
	@cli/src/bin/riv image-prepare .

image_build_run:
	@echo "Image: Building OS Image"
	@cd image/pi-gen && ./build-docker.sh

image_test:
	@echo "Image: Testing (TODO)..."
