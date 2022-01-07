#! /bin/sh

rules="pba-balance-rules.yaml,pba-briefing-rules.yaml,bi-balance-rules.yaml,bi-lobby-rules.yaml,bi-player-rules.yaml,ERCC21andBCC-rules.yaml"
notifs="pba-notifications.yaml"
seqs="bi-sequences.yaml,ERCC2-sequences.yaml" # SEX
weaps="ragl-weapons.yaml,bi-weapons.yaml,pba-weapons-rules.yaml"
assets="harv-flipped_top.shp,pip-skull.shp,ragl-weapons.yaml,ref-anim.shp,ref-bot.shp,ref-top.shp,satellite_initialized_delay2s.aud"

updatething() {
    perl -pi -e "s/($1:.*)/\1,$2/g" $3
    grep -q "$1:" $3 || printf "\n$1: $2\n" >> $3
}

for oram in .mapcache/*.oramap; do
    d=$(basename $oram .oramap)

    rm -rf .mapcache/$d
    mkdir .mapcache/$d
    cp $oram .mapcache/$d
    (cd .mapcache/$d; unzip $d.oramap >/dev/null)
    mv .mapcache/$d proc
    rm proc/$d/*.oramap
done

for d in manual/*; do
    cp -R $d proc >/dev/null 2>&1
done

imggen="true"
zipmaps="true"
cs="\x1b[2K\x1b[1G"
if [ -z "$orautil" ]; then
    if [ $(uname) = "Darwin" ]; then
        orautil="'/Applications/OpenRA - Red Alert.app/Contents/Resources/OpenRA.Utility.exe'"
    elif [ $(uname) = "Linux" ]; then
        orautil="/usr/lib/openra/OpenRA.Utility.exe"
    else
        echo "ERROR: OpenRA.Utility.exe not found. Please run the script again, manually setting the variable orautil to point to the location of OpenRA.Utility."
    fi
fi

for dd in proc/*; do
    d=$(basename $dd)
    mapfile=new/$d/map.yaml

    cp -R $dd new
    for f in $(sh -c "echo diffs/{$(echo $rules),$(echo $weaps),$(echo $notifs),$(echo $seqs),$(echo $assets)}"); do
        cp $f new/$d
    done

    printf "$cs""Updating YAMLs... (processing $d)"
    find new/$d -name '*.yaml' -exec dos2unix {} \; 2>/dev/null
    updatething "Rules" $rules $mapfile
    updatething "Weapons" $weaps $mapfile
    updatething "Notifications" $notifs $mapfile
    updatething "Sequences" $seqs $mapfile
    perl -pi -e "s/bi-rules\.yaml,//g" $mapfile

    perl -pi -e "s/(Title: .*?) *(\[.*\])? *$/\1 [PBA]/g" $mapfile
    perl -pi -e "s/(Categories:.*)/Categories: PBA/g" $mapfile

    grep -q "Categories:" $mapfile || printf "\nCategories: PBA\n" >> $mapfile

    # so we can present it more nicely later :p
    imggen="$imggen; printf \"$cs\"\"Compositing map previews... (processing $d)\"; if [ \"$(grep "^$d$" .imgregen)\" ]; then (cd new/$d; zip -rq ../../proc/t.oramap *); $orautil ra --refresh-map $(pwd)/proc/t.oramap; rm -r new/$d; mkdir new/$d; (cd new/$d; unzip -q ../../proc/t.oramap); rm proc/t.oramap; fi; composite pbaoverlay.png -gravity south -resize $(identify -format '%wx%h' new/$d/map.png) new/$d/map.png new/$d/map.png"

    # because imagegen was lazy so must this be
    zipmaps="$zipmaps; printf \"$cs\"\"Zipping maps... (processing $d)\"; (cd new/$d; zip -r ../$d-PBA.oramap . >/dev/null)"
done
printf "$cs""Updating YAMLs... done.\n"

sh -c "$imggen"  # actually generate map previews now
printf "$cs""Compositing map previews... done.\n"
sh -c "$zipmaps"  # actually zip maps now
printf "$cs""Zipping maps... done.\n"

mv new/*.oramap PBAmaps

zip -r PBAmaps.zip PBAmaps >/dev/null
