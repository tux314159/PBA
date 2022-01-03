.PHONY : all

all :
	@touch .idcache
	@rm -rf new PBAmaps PBAmaps.zip
	@mkdir -p .mapcache new PBAmaps proc
	@./gen-briefing.sh
	@./pull-maps.sh
	@./PBAise.sh
	@rm -rf new proc
