.PHONY: build check test

LEVELS ?=
CATEGORIES ?=
SELECTOR_ARG := $(if $(strip $(CATEGORIES)),--categories "$(CATEGORIES)",$(if $(strip $(LEVELS)),--levels "$(LEVELS)",))

build:
	./scripts/build_high_unified.sh $(SELECTOR_ARG)

check:
	./scripts/build_high_unified.sh --check $(SELECTOR_ARG)

test:
	./tests/test_build_high_unified.sh
