.PHONY : all

all :
	@touch .idcache
	@rm -rf new PBAmaps PBAmaps.zip
	@mkdir -p old new PBAmaps
	@./gen-briefing.sh
	@./pull-maps.sh
	@./PBAise.sh
	@rm -rf new
