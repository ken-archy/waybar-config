#!/usr/bin/env bash
#
# Streams standalone `cava` output as block characters for a Waybar
# custom/script module. Use this when Waybar was built WITHOUT libcava.
#
# Put this at: ~/.config/waybar/scripts/cava.sh
# Then:        chmod +x ~/.config/waybar/scripts/cava.sh

# Number of bars shown in the bar
bars=12

# The 8 block characters (U+2581 .. U+2588). Any Nerd/monospace font has these.
blocks="▁▂▃▄▅▆▇█"

# Avoid stacking cava processes when Waybar reloads.
# NOTE: this also kills a cava you might be running manually in a terminal.
pkill -x cava >/dev/null 2>&1

# Build a sed program that strips the ';' delimiters and maps 0..7 -> blocks
dict="s/;//g;"
i=0
while [ "$i" -lt "${#blocks}" ]; do
  dict="${dict}s/$i/${blocks:$i:1}/g;"
  i=$((i + 1))
done

# Minimal cava config written to a temp file
config_file="/tmp/waybar_cava_config"
cat >"$config_file" <<EOF
[general]
bars = $bars
framerate = 30

[input]
# 'pulse' works with PipeWire too (via pipewire-pulse).
# If you have no sound reaction, try: method = pipewire
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[smoothing]
noise_reduction = 0.77
EOF

# Stream: each frame is one line, piped through sed and emitted to Waybar
cava -p "$config_file" | sed -u "$dict"
