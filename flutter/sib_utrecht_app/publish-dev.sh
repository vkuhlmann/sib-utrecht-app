#!/run/current-system/sw/bin/bash

set -e
flutter build web --release --web-renderer canvaskit --base-href /development/ --output 'build/web-release'
#cp -r build/web-release/* /mnt/vincent-bucket3/sib-utrecht-app/cloudfront/development/
rclone sync build/web-release vincent-aws:vincent-bucket3/sib-utrecht-app/cloudfront/development --checksum -v

