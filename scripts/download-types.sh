#!/usr/bin/env bash

# type definitions
if [ ! -d "types" ]; then
  mkdir "types"
fi
curl -L "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua" > "types/globalTypes.d.lua"
curl -L "https://gist.githubusercontent.com/nightcycle/3ecee1b598c4e1d26acd7a2899ff4350/raw/527b11c49aa70b23ff5d14b37966a832c13e8475/bench.d.lua" > "types/benchmark.d.lua"
curl -L "https://gist.githubusercontent.com/nightcycle/3ecee1b598c4e1d26acd7a2899ff4350/raw/527b11c49aa70b23ff5d14b37966a832c13e8475/bench.d.lua" > "types/bench.d.lua"

# lint definitions
if [ ! -d "lints" ]; then
  mkdir "lints"
fi
curl -L "https://gist.github.com/nightcycle/a57e04de443dfa89bd08c8eb001b03c6/raw" > "lints/lua51.yml"
curl -L "https://gist.github.com/nightcycle/93c4b9af5bbf4ed09f39aa908dffccd0/raw" > "lints/luau.yml"