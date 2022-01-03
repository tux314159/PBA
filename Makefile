.PHONY : all

all :
	@rm -rf new PBAmaps PBAmaps.zip
	@mkdir old new PBAmaps
	@./pull-maps.sh
	@./PBAise.sh
	@rm -rf old new
