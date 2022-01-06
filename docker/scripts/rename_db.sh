#!/bin/bash

mysql -e "CREATE DATABASE \`local_3\`;"
for table in `mysql -B -N -e "SHOW TABLES;" 20211022170001_dump`
do 
  mysql -e "RENAME TABLE \`20211022170001_dump\`.\`$table\` to \`local_3\`.\`$table\`"
done
mysql -e "DROP DATABASE \`20211022170001_dump\`;"