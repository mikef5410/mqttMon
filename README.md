# Monitor MQTT, notify me of interesting events

This program is a daemon in perl to connect to MQTT, watch for interesting
topics and notify me of them with on-screen notifications, and my stacklight.

It's meant to start life running as root, then drop privs to me so it can
access my session-dbus.
