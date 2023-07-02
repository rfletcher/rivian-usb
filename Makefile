shell_scripts := \
	$(shell find src -type f -exec file "{}" \; | grep 'shell script' | cut -d : -f 1) \
	$(shell find src -type f -name '*.bash')


all: validate test lint


test:
	@true

lint:
	@echo Checking shell script style...
	@shellcheck --severity style \
		--exclude SC1091,SC2155 \
		$(shell_scripts)

validate:
	@echo Validating shell scripts...
	@shellcheck --severity warning \
		--exclude SC2155 \
		$(shell_scripts)
