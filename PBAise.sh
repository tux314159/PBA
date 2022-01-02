#! /usr/bin/env bash

rules="pba-balance-rules.yaml,pba-briefing-rules.yaml,bi-balance-rules.yaml,bi-lobby-rules.yaml,bi-player-rules.yaml,ERCC21andBCC-rules.yaml"
notifs="pba-notifications.yaml"
seqs="bi-sequences.yaml,ERCC2-sequences.yaml" # SEX
weaps="ragl-weapons.yaml,bi-weapons.yaml,pba-weapons-rules.yaml"
assets="harv-flipped_top.shp,pip-skull.shp,ragl-weapons.yaml,ref-anim.shp,ref-bot.shp,ref-top.shp,satellite_initialized_delay2s.aud"

function updatething {
    perl -pi -e "s/($1:.*)/\1,$2/g" $3
    grep -q "$1:" $3 || printf "\n$1: $2\n" >> $3
}

for d in *; do
    [ $d == new ] || [ $d == PBAmaps ] || [ $d == diffs ] && continue
    mapfile=new/$d/map.yaml

    if [ ! -d $d ]; then continue; fi
    cp -R $d new
    for f in $(sh -c "echo diffs/{$(echo $rules),$(echo $weaps),$(echo $notifs),$(echo $seqs),$(echo $assets)}"); do
        cp $f new/$d
    done

    (cd new/$d; find -name '*.yaml' -exec dos2unix {} \; 2>/dev/null)
    updatething "Rules" $rules $mapfile
    updatething "Weapons" $weaps $mapfile
    updatething "Notifications" $notifs $mapfile
    updatething "Sequences" $seqs $mapfile
    perl -pi -e "s/bi-rules\.yaml,//g" $mapfile

    perl -pi -e "s/(Title: .*?) *(\[.*\])? *$/\1 [PBA]/g" $mapfile
    perl -pi -e "s/(Categories:.*)/Categories: PBA/g" $mapfile
    grep -q "Categories:" $mapfile || printf "\nCategories: PBA\n" >> $mapfile
    (cd new/$d; zip -r ../$d-PBA.oramap . >/dev/null)
done

mv new/*.oramap PBAmaps

zip -r PBAmaps.zip PBAmaps >/dev/null
