# Default setup
setup: 
	@echo "Setting up..."
	chmod +x ./script/setup.sh
	./script/setup.sh

build-cairo: 
	@echo "Build compiled cairo..."
	cd custom_module && scarb build &&  cd ..

run-hdp:
	hdp run-module --module-inputs public.0x5222A4 --local-class-path ./custom_module/target/dev/custom_module_get_parent.compiled_contract_class.json -p input.json -b batch.json --save-fetch-keys-file key.json -c cairo.pie

