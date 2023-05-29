SWIFT_BIN_PATH = $(shell swift build --show-bin-path)
EXAMPLE_PATH = ./Example
BUILD_TEMP = .build/temp

test:
	swift test --sanitize=thread --enable-code-coverage

coverage:
	llvm-cov export $(SWIFT_BIN_PATH)/BreezePackageTests.xctest \
		--instr-profile=$(SWIFT_BIN_PATH)/codecov/default.profdata \
		--format=lcov > $(GITHUB_WORKSPACE)/lcov.info