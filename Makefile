.PHONY: build check test

build:
	./scripts/build_high_unified.sh

check:
	./scripts/build_high_unified.sh --check

test:
	./tests/test_build_high_unified.sh
