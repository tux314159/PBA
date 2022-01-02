.PHONY : all

all :
	@rm -rf new PBAmaps PBAmaps.zip
	@mkdir new PBAmaps
	@./PBAise.sh
	@rm -rf new
