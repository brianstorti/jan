#!/bin/sh

set -e

cd "$(dirname "$0")"

mkdir -p build/

elm-make --yes --output build/test1.js Test.elm
echo "Elm.worker(Elm.Main);" >> build/test1.js
echo "echotest\nexit" | node build/test1.js

elm-make --yes --output build/test2.js FileTest.elm
echo "Elm.worker(Elm.Main);" >> build/test2.js
node build/test2.js

elm-make --yes --output build/test3.js BigString.elm
echo "Elm.worker(Elm.Main);" >> build/test3.js
node build/test3.js > /dev/null
echo "Success"
