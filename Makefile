##################
#   Variables    #
##################

GIT_VERSION = $(shell git rev-list -1 HEAD)

ifdef RELEASE
	EXAMPLE_VERSION := $(RELEASE)
else
	EXAMPLE_VERSION := dev
endif

ifdef ARCHIVE_OUTDIR
	OUTPUT_PATH := $(ARCHIVE_OUTDIR)
else
	OUTPUT_PATH := .
endif

LOCAL_OS := $(shell uname)
ifeq ($(LOCAL_OS),Linux)
   TARGET_OS_LOCAL = linux
else ifeq ($(LOCAL_OS),Darwin)
   TARGET_OS_LOCAL = darwin
else
   TARGET_OS_LOCAL ?= windows
endif
export GOOS ?= $(TARGET_OS_LOCAL)

ifeq ($(GOOS),windows)
	BINARY_EXT_LOCAL:=.exe
	GOLANGCI_LINT:=golangci-lint.exe
	export ARCHIVE_EXT = .zip
else
	BINARY_EXT_LOCAL:=
	GOLANGCI_LINT:=golangci-lint
	export ARCHIVE_EXT = .tar.gz
endif

export BINARY_EXT ?= $(BINARY_EXT_LOCAL)

##################
# Linting/Verify #
##################

lint-prepare:
ifeq (,$(shell which golangci-lint))
	@echo "Installing golangci-lint"
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOPATH)/bin v1.23.1 > /dev/null 2>&1
else
	@echo "golangci-lint is installed"
endif

lint:
	@echo "Linting"
	golangci-lint run ./...

vet:
	@echo "Vetting"
	go vet ./...

##################
#    Testing     #
##################

test:
	go test -v ./... -cover -race -covermode=atomic

##################
#     Build      #
##################

LDFLAGS:=-X main.commit=$(GIT_VERSION) -X main.version=$(EXAMPLE_VERSION) -X "main.date=$(shell date -u)"

build::
	GOOS=$(GOOS) GOARCH=amd64 go build -ldflags='$(LDFLAGS)' -o example$(BINARY_EXT) main.go

##################
#    Release     #
##################

archive:
ifeq ("$(wildcard $(OUTPUT_PATH))", "")
	mkdir -p $(OUTPUT_PATH)
endif

ifeq ($(GOOS),windows)
	zip $(OUTPUT_PATH)/example_$(GOOS)_amd64$(ARCHIVE_EXT) example$(BINARY_EXT)
else
	tar -czvf "$(OUTPUT_PATH)/example_$(GOOS)_amd64$(ARCHIVE_EXT)" "example$(BINARY_EXT)"
endif

release: build archive generate-checksum

##################
#     Verify     #
##################

generate-checksum:
	cd $(OUTPUT_PATH)
	sha256sum example_$(GOOS)_amd64$(ARCHIVE_EXT) >> checksums.sha256

verify-checksum:
	sha256sum -c $(OUTPUT_PATH)/checksums.sha256
