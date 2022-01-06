.PHONY : all clean

all :
	@touch .imgregen .idcache .namecache
	@rm -rf new proc PBAmaps PBAmaps.zip
	@mkdir -p .mapcache new PBAmaps proc
	@./gen-briefing.sh
	@./pull-maps.sh
	@./PBAise.sh
	@rm -rf new proc .imgregen
	@echo "Done."

clean :
	@rm -rf .idcache proc .imgregen PBAmaps PBAmaps.zip .mapcache .namecache
