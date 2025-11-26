i3#!/bin/bash

# Restore display configuration
# This script dynamically queries displays at boot time since display names can change

# Get connected displays
connected_displays=$(xrandr --query | grep " connected" | awk '{print $1}')

if [[ -z "$connected_displays" ]]; then
	exit 0
fi

# Count connected displays
display_count=$(echo "$connected_displays" | wc -l)

# Helper function to get native resolution for a display
get_native_res() {
	local display="$1"
	xrandr --query | \
		awk -v display="$display" '
			$0 ~ "^" display " connected" { found=1; next }
			found && /\*\+/ { print $1; exit }
			found && /^[A-Z]/ { exit }
		'
}

if [[ $display_count -eq 2 ]]; then
	# Two displays: find eDP-* and HDMI-* (or DP-*)
	edp_display=$(echo "$connected_displays" | grep -ioE 'eDP-[0-9]+' | head -n1)
	hdmi_display=$(echo "$connected_displays" | grep -ioE 'HDMI-[0-9]+' | head -n1)
	dp_display=$(echo "$connected_displays" | grep -ioE 'DP-[0-9]+' | head -n1)
	
	# Prefer HDMI over DP for external display
	external_display="$hdmi_display"
	if [[ -z "$external_display" ]]; then
		external_display="$dp_display"
	fi
	
	if [[ -n "$edp_display" ]] && [[ -n "$external_display" ]]; then
		edp_res=$(get_native_res "$edp_display")
		external_res=$(get_native_res "$external_display")
		
		if [[ -n "$edp_res" ]] && [[ -n "$external_res" ]]; then
			external_width=$(echo "$external_res" | cut -d'x' -f1)
			laptop_pos=$external_width
			
			# Configure both displays in single command for proper mouse movement
			xrandr --output "$external_display" --primary --mode "$external_res" --pos 0x0 --rotate normal \
			       --output "$edp_display" --mode "$edp_res" --pos "${laptop_pos}x0" --rotate normal
		fi
	fi
elif [[ $display_count -eq 1 ]]; then
	# Single display: set its native resolution
	display=$(echo "$connected_displays" | head -n1)
	native_res=$(get_native_res "$display")
	
	if [[ -n "$native_res" ]]; then
		xrandr --output "$display" --primary --mode "$native_res" --pos 0x0 --rotate normal
	fi
fi
