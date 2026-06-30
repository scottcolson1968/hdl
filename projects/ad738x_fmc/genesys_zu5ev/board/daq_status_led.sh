#!/bin/bash
###############################################################################
# DAQ status RGB LED state machine (LD5 via PS EMIO GPIO + leds-gpio).
#
#   red   = booting          (set by DT default-state; cleared once we run)
#   blue  = system up, iiod starting / not yet accepting clients
#   green = SAFE TO CONNECT   (iiod listening AND /dev/iio:device0 present)
#
# A PC libiio client (USB WinUSB or network) can connect when GREEN is lit.
# Installed as /usr/local/bin/daq_status_led.sh, run by daq-status-led.service.
###############################################################################

LEDS=/sys/class/leds

set_led() { [ -e "$LEDS/$1/brightness" ] && echo "$2" > "$LEDS/$1/brightness" 2>/dev/null; }

red()   { set_led "daq:red" 1; set_led "daq:green" 0; set_led "daq:blue" 0; }
blue()  { set_led "daq:red" 0; set_led "daq:green" 0; set_led "daq:blue" 1; }
green() { set_led "daq:red" 0; set_led "daq:green" 1; set_led "daq:blue" 0; }

# A network libiio client can connect if an iiod TCP port is listening.
# iiod026 = 30431 (network), iiod_ffs = 30432 (per /etc/default/iiod).
net_ready() {
	ss -ltnH 2>/dev/null | awk '{print $4}' | grep -qE ':(30431|30432)$'
}

# A USB libiio client can connect if the FFS iiod is up and the gadget is
# enumerated (UDC bound + configured by the host).
usb_ready() {
	systemctl is-active --quiet iiod_ffs 2>/dev/null || return 1
	for s in /sys/class/udc/*/state; do
		[ -e "$s" ] && [ "$(cat "$s" 2>/dev/null)" = "configured" ] && return 0
	done
	return 1
}

# "Safe to connect" = the ADC device node exists AND at least one transport is
# actually accepting clients.
ready() {
	[ -e /dev/iio:device0 ] || return 1
	net_ready || usb_ready
}

# On stop/shutdown fall back to red = "not safe to connect".
trap 'red; exit 0' TERM INT

blue
prev=""
while true; do
	if ready; then state=green; else state=blue; fi
	if [ "$state" != "$prev" ]; then "$state"; prev="$state"; fi
	sleep 2
done
