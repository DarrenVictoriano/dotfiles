#!/usr/bin/env bash

# Wait until hypridle is actually running
while ! pgrep -x hypridle >/dev/null; do
  sleep 0.1
done

# Now run your custom toggle script
omarchy-toggle-idle
