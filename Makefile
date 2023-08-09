all: cli image
clean: cli_clean image_clean
test: cli_test image_test

## CLI ##

cli_command_names := \
	$(shell find cli/src/libexec -type f | cut -d / -f 4 | cut -d - -f 2-)

cli_shell_scripts := \
	$(shell find cli/src -type f -exec file "{}" \; | grep 'shell script' | cut -d : -f 1) \
	$(shell find cli/src -type f -name '*.bash')

cli: cli_test

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

image_dir := image/pi-gen
stage_dir := $(image_dir)/stage3/99-install-rivian-usb

image: image_build image_test

image_build: image_clean image_configure image_build_run

image_build_run:
	@echo "Image: Building OS Image"
	@cd $(image_dir) && ./build-docker.sh

image_clean:
	@echo "Image: Cleaning up..."
	@git submodule deinit -f $(image_dir) >/dev/null
	@git submodule update --init $(image_dir) >/dev/null 2>&1

image_configure:
	@echo "Image: Configuring image..."
	@cp image/config $(image_dir)/config
  # skip default pi-gen image generation
	@touch $(image_dir)/stage{0..2}/SKIP_IMAGES
	@rm -rf $(image_dir)/stage{3..5}
  # install riv image customizations
	@rsync -a --delete image/customizations/ $(image_dir)/stage3/
	@cp $(image_dir)/stage{2,3}/prerun.sh
	@cli/src/bin/riv dependencies -p > $(stage_dir)/00-packages
  # copy `riv` into the image
	@mkdir -p $(stage_dir)/files/riv
	@cli/src/bin/riv install -s . -t $(stage_dir)/files/riv >/dev/null

image_test:
	@echo "Image: Running tests (TODO)..."
