#! /bin/sh

. ./config.sh

updatething() {
    # adds stuff to a line in a yaml
    if [ $2 ]; then
        perl -pi -e "s/($1:.*)/\1,$2/g" $3
        # in case it didn't even exist in the first place
        grep -q "$1:" $3 || printf "\n$1: $2\n" >> $3
    fi
}

for d in manual/*; do
    # if it's not a directory it's a zip
    [ -d "$d" ] || cp -R $d .mapcache >/dev/null 2>&1
    # if it's executable, imgregen
    [ -x "$d" ] && echo "$(basename "$d" .oramap)" >> .imgregen
done

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
    [ "$(file -b $d)" = "directory" ] && cp -R $d proc >/dev/null 2>&1
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
        [ $f = "diffs/" ] && continue
        cp $f new/$d
    done

    printf "$cs""Updating YAMLs... (processing $d)"
    find new/$d -name '*.yaml' -exec dos2unix {} \; 2>/dev/null
    updatething "Rules" "$rules" $mapfile
    updatething "Weapons" "$weaps" $mapfile
    updatething "Notifications" "$notifs" $mapfile
    updatething "Sequences" "$seqs" $mapfile
    perl -pi -e "s/bi-rules\.yaml,//g" $mapfile

    perl -pi -e "s/(Title: .*?) *(\[.*\])? *$/\1 $titleappend/g" $mapfile
    perl -pi -e "s/(Categories:.*)/Categories: $category/g" $mapfile
    grep -q "Categories:" $mapfile || printf "\nCategories: $category\n" >> $mapfile

    # so we can present it more nicely later :p
    imggen="$imggen; printf '$cs''Compositing map previews... (processing $d)'"
    imggen="$imggen; if [ \"$(grep "^$d$" .imgregen)\" ]; then true"
    imggen="$imggen;     (cd new/$d; zip -rq ../../proc/t.oramap *)"
    imggen="$imggen;     $orautil ra --refresh-map $(pwd)/proc/t.oramap"
    imggen="$imggen;     rm -r new/$d"
    imggen="$imggen;     mkdir new/$d"
    imggen="$imggen;     (cd new/$d; unzip -q ../../proc/t.oramap)"
    imggen="$imggen;     rm proc/t.oramap"
    imggen="$imggen; fi"
    imggen="$imggen; composite $previewoverlay -gravity south -resize $(identify -format '%wx%h' new/$d/map.png) new/$d/map.png new/$d/map.png"

    # imagegen was lazy so this must be as well
    zipmaps="$zipmaps; printf \"$cs\"\"Zipping maps... (processing $d)\"; (cd new/$d; zip -r ../$d-$fnameappend.oramap . >/dev/null)"
done
printf "$cs""Updating YAMLs... done.\n"

sh -c "$imggen"  # actually generate map previews now
printf "$cs""Compositing map previews... done.\n"
sh -c "$zipmaps"  # actually zip maps now
printf "$cs""Zipping maps... done.\n"

mv new/*.oramap moddedmaps
