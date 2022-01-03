#! /bin/sh

perl -pe 's&^(.+)$&curl -o old/tmp https://resource.openra.net/map/id/\1; url=\$(cat old/tmp | jq ".[0].url" | cut -d\\" -f2 | sed "s/^http:/https:/"); title=\$(cat old/tmp | jq ".[0].title" | sed "s/(.*)//g" | sed "s/\\[.*\\]//g" | cut -d: -f2 | cut -d\\" -f2 | tr " " "_"); [ -f old/\$title.oramap ] || curl -o old/\$title.oramap \$url; &' map-ids | tr '\n' ' ' | sh
