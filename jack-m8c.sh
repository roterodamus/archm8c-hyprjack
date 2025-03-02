#!/bin/bash

# Initialize variables
soundcard1="PCH"  # Set your soundcard name
soundcard2="M8"
samplerate="44100"                # Set your desired sample rate
buffersize="128"                  # Set your desired buffer size
period="4"                        # Set your desired period

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

# Start M8C
m8c


# Clean up audio routing
killall -s SIGINT alsa_out alsa_in


