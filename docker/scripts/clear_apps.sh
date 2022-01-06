#!/bin/bash
## has to be LF!

for app in $(cat /tmp/apps.txt); do
  path="/var/www/html/"
  full="${path}${app}"
  echo ">>> Clearing: ${app}";

  # shellcheck disable=SC2046
  cd $(echo $full | tr -d '\r') || exit

  #composer dump-autoload
  php artisan cache:clear && php artisan config:clear && php artisan view:clear

done