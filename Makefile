.PHONY : all

all :
	@rm -rf new PBAmaps PBAmaps.zip
	@mkdir old new PBAmaps
	@./pull-ids.sh
	@./PBAise.sh
	@rm -rf old new
