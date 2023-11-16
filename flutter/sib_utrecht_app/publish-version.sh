#!/run/current-system/sw/bin/bash

set -e
flutter build web --release --web-renderer canvaskit --base-href '/v0.1.6/' --output 'build/web-release'
#cp -r build/web-release/* /mnt/vincent-bucket3/sib-utrecht-app/cloudfront/development/
rclone sync build/web-release 'vincent-aws:vincent-bucket3/sib-utrecht-app/cloudfront/v0.1.version' --checksum -v

