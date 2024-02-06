#!/run/current-system/sw/bin/bash

set -e
flutter build web --profile --web-renderer canvaskit --base-href /development/ --output 'build/web-profile'
#cp -r build/web-release/* /mnt/vincent-bucket3/sib-utrecht-app/cloudfront/development/
rclone sync build/web-profile vincent-aws:vincent-bucket3/sib-utrecht-app/cloudfront/development --checksum -v

