#! /bin/sh
cat << EOF | perl -pe 'chomp if eof' >diffs/pba-briefing-rules.yaml
World:
    MissionData:
        Briefing:
EOF

perl -pe 's/\n/\\n/g' briefing.txt >> diffs/pba-briefing-rules.yaml
echo >> diffs/pba-briefing-rules.yaml
