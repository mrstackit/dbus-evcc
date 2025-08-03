#!/bin/bash
svc -d /service/dbus-evcc
sleep 1
svc -u /service/dbus-evcc
