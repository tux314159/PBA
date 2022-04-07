#! /bin/sh
cat << EOF | perl -pe 'chomp if eof' >diffs/briefing-rules.yaml
World:
    MissionData:
        Briefing:
EOF

perl -pe 's/\n/\\n/g' briefing.txt >> diffs/briefing-rules.yaml
touch diffs/briefing-rules.yaml
