all: cli image
clean: cli_clean image_clean
test: cli_test image_test

## CLI ##

cli_command_names := \
	$(shell find cli/src/libexec -type f | cut -d / -f 4 | cut -d - -f 2-)

cli_shell_scripts := \
	$(shell find cli/src -type f -exec file "{}" \; | grep 'shell script' | cut -d : -f 1) \
	$(shell find cli/src -type f -name '*.bash')

cli_clean:
	@echo "CLI: Cleaning up..."
	@find cli/test/tests -type f -name '*.tmpl.bats' -delete
	@find cli/test/tests -type d -empty -delete

cli_generate_tests:
	@echo "CLI: Generating tests from templates..."
	@for TEMPLATE in cli/test/templates/*.tmpl.bats; do\
		for COMMAND in $(cli_command_names); do\
			mkdir -p cli/test/tests/libexec/riv-$$COMMAND;\
			cat "$$TEMPLATE" | sed 's/__COMMAND__/'$$COMMAND'/g' > cli/test/tests/libexec/riv-$$COMMAND/$$(basename $$TEMPLATE);\
		done;\
	done

cli_test: cli_generate_tests
	@echo "CLI: Running tests..."
	@find cli/test/tests -type f -name '*.bats' | xargs bats

cli_lint:
	@echo "CLI: Checking shell script style..."
	@shellcheck --severity style \
		--exclude SC1091,SC2155 \
		$(cli_shell_scripts)

cli_validate:
	@echo "CLI: Validating shell scripts..."
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

image_clean:
	@echo "Image: Cleaning up (TODO)..."

image_test:
	@echo "Image: Running tests (TODO)..."
