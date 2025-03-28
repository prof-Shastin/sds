#!/bin/bash

rm -f sds_web.zip
flutter clean
zip -r sds_web.zip ./
flutter build web

rm -rf ../sds_server/web-template/images
mv ../sds_server/web/images ../sds_server/web-template/images
rm -rf ../sds_server/web
cp -R ../sds_server/web-template ../sds_server/web
cp -R build/web/* ../sds_server/web/
