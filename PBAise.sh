#! /usr/bin/env sh

rules="pba-balance-rules.yaml,pba-briefing-rules.yaml,bi-balance-rules.yaml,bi-lobby-rules.yaml,bi-player-rules.yaml,ERCC21andBCC-rules.yaml"
notifs="pba-notifications.yaml"
seqs="bi-sequences.yaml,ERCC2-sequences.yaml" # SEX
weaps="ragl-weapons.yaml,bi-weapons.yaml,pba-weapons-rules.yaml"
others="harv-flipped_top.shp,pip-skull.shp,ragl-weapons.yaml,ref-anim.shp,ref-bot.shp,ref-top.shp,satellite_initialized_delay2s.aud"

mkdir new

function updatething {
    sed -i'.bkp' "s|\($1:.*\)|\1,$2|g" $3
    grep -q "$1:" $3 || printf "\n$1: $2\n" >> $3
}

for d in *; do
    mapfile=new/$d/map.yaml

    if [ ! -d $d ]; then continue; fi
    cp -R $d new
    for f in $(sh -c "echo diffs/{$(echo $rules),$(echo $weaps),$(echo $notifs),$(echo $seqs),$(echo $others)}"); do
        cp $f new/$d
    done

    (cd new/$d; find -name '*.yaml' -exec dos2unix {} \; 2>/dev/null)
    updatething "Rules" $rules $mapfile
    updatething "Weapons" $weaps $mapfile
    updatething "Notifications" $notifs $mapfile
    updatething "Sequences" $seqs $mapfile
    sed -i "s|bi-rules.yaml,||g" $mapfile

    # damn
    #sed -i "s|\(Notifications:.*\)|\1$pbanotif|g" $mapfile # SPECIAL CASE! NO COMMA
    #grep -q "Notifications:" $mapfile || printf "\nNotifications: $pbanotif\n" >> $mapfile

    sed -i "s|\(Title:.*\)\[.*\]|\1[PBA]|g" $mapfile
    sed -i "s|\(Categories:.*\)|Categories: PBA|g" $mapfile
    (cd new/$d; zip -r ../$d.oramap . >/dev/null)
done

mkdir sub
mv new/*.oramap sub
rm -rf new

find . -name '*.bkp' -print -delete
rm -f sub.zip
zip -r sub.zip sub >/dev/null
rm -rf sub
