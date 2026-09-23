#!/usr/bin/env bash
# Same as `npm start`: starts Django + React and opens the browser.
exec node "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/start.js"
