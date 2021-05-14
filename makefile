code-dirs = app

default:
	cabal build

run:
	cabal run

hlint:
	hlint --no-exit-code $(code-dirs)

stylish:
	@find $(code-dirs) -type f -name "*.hs" | while read fname; do \
	  stylish-haskell -i "$$fname"; \
	done
