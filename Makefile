.PHONY : all clean

all :
	@touch .imgregen .idcache .namecache
	@rm -rf new proc moddedmaps moddedmaps.zip
	@mkdir -p .mapcache new moddedmaps proc
	@./gen-briefing.sh
	@./pull-maps.sh
	@./modmaps.sh
	@rm -rf new proc .imgregen
	@echo "Modded $$(ls -1 moddedmaps | wc -l) maps!"

clean :
	@rm -rf .idcache proc .imgregen moddedmaps .mapcache .namecache
