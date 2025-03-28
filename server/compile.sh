#!/bin/bash

rm -f sds_server.zip

dart pub cache clean
dart pub get
dart compile exe -o sds_server bin/sds_server.dart
zip -r sds_server.zip ./
