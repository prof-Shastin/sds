#!/bin/bash

flutter pub get

flutter run -d web-server --web-port 8081 --web-hostname 0.0.0.0
