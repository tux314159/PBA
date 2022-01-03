#! /bin/sh

perl -pe 's&^(.+)$&grep -q "^\1\$" .idcache || { echo \1 >> .idcache; curl -o .mapcache/tmp https://resource.openra.net/map/id/\1; url=\$(cat .mapcache/tmp | jq ".[0].url" | cut -d\\" -f2 | sed "s/^http:/https:/"); title=\$(cat .mapcache/tmp | jq ".[0].title" | sed "s/(.*)//g" | sed "s/\\[.*\\]//g" | cut -d: -f2 | cut -d\\" -f2 | tr " " "_"); curl -o .mapcache/\$title.oramap \$url; } ; &' map-ids | tr '\n' ' ' | sh
