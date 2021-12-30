.PHONY : all

all :
	@rm -rf new sub sub.zip
	@mkdir new sub
	@./PBAise.sh
	@rm -rf new sub
