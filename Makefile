.PHONY: runtime

VERSION = $(shell go run tools/build-version.go)
HASH = $(shell git rev-parse --short HEAD)
DATE = $(shell go run tools/build-date.go)

# Builds micro after checking dependencies but without updating the runtime
build: deps tcell
	go build -ldflags "-s -w -X main.Version=$(VERSION) -X main.CommitHash=$(HASH) -X 'main.CompileDate=$(DATE)'" ./cmd/micro

# Builds micro after building the runtime and checking dependencies
build-all: runtime build

# Builds micro without checking for dependencies
build-quick:
	go build -ldflags "-s -w -X main.Version=$(VERSION) -X main.CommitHash=$(HASH) -X 'main.CompileDate=$(DATE)'" ./cmd/micro

# Same as 'build' but installs to $GOPATH/bin afterward
install: build
	mkdir -p $(GOPATH)/bin
	mv micro $(GOPATH)/bin

# Same as 'build-all' but installs to $GOPATH/bin afterward
install-all: runtime install

# Same as 'build-quick' but installs to $GOPATH/bin afterward
install-quick: build-quick
	mkdir -p $(GOPATH)/bin
	mv micro $(GOPATH)/bin

# Updates tcell
tcell:
	git -C $(GOPATH)/src/github.com/zyedidia/tcell pull

# Checks for dependencies
deps:
	go get -d ./cmd/micro

# Builds the runtime
runtime:
	go get -u github.com/jteeuwen/go-bindata/...
	$(GOPATH)/bin/go-bindata -nometadata -o runtime.go runtime/...
	mv runtime.go cmd/micro

test:
	go get -d ./cmd/micro
	go test ./cmd/micro

clean:
	rm -f micro
