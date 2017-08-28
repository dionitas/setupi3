#!/usr/bin/env python
# spotstat.py

from pydbus import SessionBus
from os import environ

player = 'org.mpris.MediaPlayer2.spotify'

try:
    # Connect to session bus
    bus = SessionBus()
    # Create player object proxy
    proxy = bus.get(player, '/org/mpris/MediaPlayer2')

    # Toggle play/pause on mouse click
    if environ.get('BLOCK_BUTTON') == '1':
        from time import sleep
        proxy.PlayPause()
        sleep(0.01)

    # Get playback status (playing/paused/stopped)
    playback = proxy.PlaybackStatus
    if playback == 'Playing':
        status = '>'
    elif playback == 'Paused':
        status = 'II'
    else:
        status = 'x'

    # Get track metadata
    metadata = proxy.Metadata
    artist = metadata.get('xesam:artist')[0]
    title = metadata.get('xesam:title')

    print('%s - %s  [%s]' % (artist, title, status))

except:
    exit
