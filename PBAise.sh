#! /usr/bin/env sh

pbarules="pba-balance-rules.yaml,pba-briefing-rules.yaml"
pbanotif="pba-notifications.yaml"
pbaweap="pba-weapons-rules.yaml"
rest="bi-balance-rules.yaml,bi-lobby-rules.yaml,bi-player-rules.yaml,bi-sequences.yaml,bi-weapons.yaml,ERCC21andBCC-rules.yaml,ERCC2-sequences.yaml,harv-flipped_top.shp,pip-skull.shp,ragl-weapons.yaml,ref-anim.shp,ref-bot.shp,ref-top.shp,satellite_initialized_delay2s.aud"

mkdir new

for d in *; do
    mapfile=new/$d/map.yaml
    if [ ! -d $d ]; then continue; fi
    cp -R $d new
    for f in $(sh -c "echo diffs/{$(echo $pbarules),$(echo $pbaweap),$(echo $pbanotif),$(echo $rest)}"); do
        cp $f new/$d
    done
    (cd new/$d; find -name '*.yaml' -exec dos2unix {} \;)
    sed -i "s|\(Rules:.*\)|\1,$pbarules|g" $mapfile
    sed -i "s|bi-rules.yaml,||g" $mapfile
    sed -i "s|\(Weapons:.*\)|\1,$pbaweap|g" $mapfile
    sed -i "s|\(Notifications:.*\)|\1$pbanotif|g" $mapfile # SPECIAL CASE! NO COMMA
    grep "Notifications:" $mapfile || printf "\nNotifications: $pbanotif\n" >> $mapfile
    sed -i "s|\(Title:.*\)\[.*\]|\1[PBA]|g" $mapfile
    sed -i "s|\(Categories:.*\)|Categories: PBA|g" $mapfile
    (cd new/$d; zip -r ../$d.oramap . >/dev/null)
done

mkdir sub
mv new/*.oramap sub
rm -rf new

rm -f sub.zip
zip -r sub.zip sub >/dev/null
rm -rf sub
