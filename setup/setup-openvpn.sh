#!/bin/bash
# download and inflate, remove zipfile and exclude countries
wget "$OPENVPN_CONFIGS_ZIP_URL" && unzip *.zip && rm *.zip
readarray -t countries < exclude_countries
for country in "${countries[@]}"
do
    echo "Removing files with pattern *-$country-*"
    rm -rf *-"$country"-*
done

