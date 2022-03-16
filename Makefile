.PHONY: build

build: export MIX_ENV=prod
build: deps
	mix compile

.PHONY: test

test: export MIX_ENV=test
test: deps
	mix test


.PHONY: docs

docs: export MIX_ENV=dev
docs: deps
	mix docs

.PHONY: format

format: export MIX_ENV=dev
format: deps
	mix format

.PHONY: deps

deps:
	mix deps.get --all

.PHONY: publish
publish:
	mix hex.publish
