SAVI?=savi
PROTOC?=protoc

.PHONY: ci spec bin-release gen gen-src gen-spec no-diff-check format-check format

ci: spec gen no-diff-check format-check

# Run the test suite.
spec:
	$(SAVI) run spec $(extra_args)

# Build the protoc compiler Savi plugin executable.
bin/protoc-gen-savi: $(shell find src -name '*.savi')
	$(SAVI) build protoc-gen-savi $(extra_args)

# Build a release version of the binary executable for this platform.
bin-release:
	$(SAVI) build --release protoc-gen-savi $(extra_args)

# Use the protoc compiler Savi plugin to generate some of the code we use.
gen: gen-src gen-spec
gen-src: bin/protoc-gen-savi $(shell find vendor -name '*.proto')
	$(PROTOC) --plugin bin/protoc-gen-savi --savi_out=src -Ivendor vendor/google/protobuf/compiler/plugin.proto
gen-spec: bin/protoc-gen-savi $(shell find spec/proto -name '*.proto')
	$(PROTOC) --plugin bin/protoc-gen-savi --savi_out=spec -Ispec/proto spec/proto/example.proto

# Check that there is no current diff in git.
no-diff-check:
	git diff --no-ext-diff --exit-code

# Check that there are no code formatting violations.
format-check:
	$(SAVI) format --check $(extra_args)

# Fix any code formatting violations.
format:
	$(SAVI) format $(extra_args)
