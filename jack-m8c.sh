#!/bin/bash

# Initialize variables
soundcard1="USB"             # Set your soundcard name (aplay -l)
midi_controller="SINCO"      # Set your MIDI controller's ALSA name (aconnect -l)
buffersize="128"             # Set your desired buffer size
soundcard2="M8"
m8_midi="M8"
samplerate="44100"
period="4"

# Start JACK server
jackd -d alsa -d hw:"$soundcard1" -r "$samplerate" -p "$buffersize" &
if [ $? -ne 0 ]; then
  echo "Failed to start JACK server."
  exit 1
fi

# Check if the Instrument with the Card Name "$soundcard1" is connected
if [ $(aplay -l | grep -c "$soundcard1") -eq 0 ]; then
  echo "$soundcard1 not detected, skipping connection."
else
  echo "$soundcard1 detected, connecting."

  alsa_in -j "${soundcard1}_in" -d hw:"$soundcard1",DEV=0 -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
  alsa_out -j "${soundcard1}_out" -d hw:"$soundcard1",DEV=0 -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &

  sleep 4

  jack_connect "${soundcard1}_in:capture_1" system:playback_1
  jack_connect "${soundcard1}_in:capture_2" system:playback_2
fi

# Open audio interface between "$soundcard2" Out and System In
alsa_in -j "${soundcard2}_in" -d hw:"$soundcard2",DEV=0 -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
alsa_out -j "${soundcard2}_out" -d hw:"$soundcard2",DEV=0 -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &

sleep 4

jack_connect "$soundcard2"_in:capture_1 system:playback_1
jack_connect "$soundcard2"_in:capture_2 system:playback_2

jack_connect system:capture_1 "$soundcard2"_out:playback_1
jack_connect system:capture_2 "$soundcard2"_out:playback_2

# MIDI setup
# Start a2jmidid to bridge ALSA MIDI to JACK MIDI
a2jmidid -e &
sleep 2

# Connect MIDI controller to M8 if variables are set
if [ -n "$midi_controller" ] && [ -n "$m8_midi" ]; then
  echo "Attempting to connect MIDI controller $midi_controller to $m8_midi..."

  # Find the MIDI ports
  controller_port=$(jack_lsp | grep -m1 "a2j:${midi_controller}.*capture")
  m8_port=$(jack_lsp | grep -m1 "a2j:${m8_midi}.*playback")

  if [ -n "$controller_port" ] && [ -n "$m8_port" ]; then
    echo "Connecting $controller_port to $m8_port"
    jack_connect "$controller_port" "$m8_port"
  else
    echo "One or both MIDI ports not found. Please check names and connections."
    echo "Controller port: $controller_port"
    echo "M8 port: $m8_port"
  fi
else
  echo "MIDI controller or M8 MIDI name not set, skipping MIDI connection."
fi

# Start M8C
m8c

# Clean up audio routing
killall -s SIGINT alsa_out alsa_in
