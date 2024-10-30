# HDP Module Template

This public template provides a quick start for developing custom modules with the HDP (Herodotus Data Processor). For more information, refer to the [HDP Documentation](https://docs.herodotus.dev/herodotus-docs/developers/data-processor).

## Versions

This template is compatible with the following versions:

- [HDP CLI | 0d985094f94b641e38b4d8267357f70e1899c70d](https://github.com/HerodotusDev/hdp/tree/0d985094f94b641e38b4d8267357f70e1899c70d)
- [HDP Cairo | f160f8eae203d96b001a9b3fc33a9e7018eb69f5](https://github.com/HerodotusDev/hdp-cairo/tree/f160f8eae203d96b001a9b3fc33a9e7018eb69f5)

## How to Write an HDP Module

In the `/custom_module` directory, you can define your own module using the `hdp_cairo` library.

## Running the HDP Module Locally

### 1. Setup

Copy the environment variables from the [example file](.env.example) into a `.env` file.

Set up the project by compiling the Cairo program and preparing the Python environment:

```sh
make setup
```

### 2. Build the Module

Build the custom module. Ensure the module is already created. If not, complete the previous step first.

```sh
make build-cairo
```

Or navigate to the root of the module folder and run:

```sh
scarb build
```

This should generate a new build file in the following structure:

```
custom_module \
    src \
       lib.cairo
    target \
       dev \
          custom_module_custom_module.compiled_contract_class.json
```

### 3. Run the HDP Module

If you haven’t installed the `hdp` CLI binary, install it with:

```sh
# Install with Cargo
cargo install --git https://github.com/HerodotusDev/hdp/ --tag v0.8.0 --locked --force hdp-cli
```

Run the HDP module locally with:

```sh
RUST_LOG=debug make run-hdp
```

To understand the command breakdown, it uses `0x5222A4` as the first public input and specifies the module’s build JSON file. `-p input.json -b batch.json` runs the preprocessing step, while `-c cairo.pie` initiates trace generation. The `--save-fetch-keys-file key.json` option saves the keys of fetched data for debugging.

```sh
hdp run-module --module-inputs public.0x5222A4 --local-class-path ./custom_module/target/dev/custom_module_get_parent.compiled_contract_class.json -p input.json -b batch.json --save-fetch-keys-file key.json -c cairo.pie
```

Successful execution should display logs similar to this:

```console
2024-10-30T11:26:52.369335Z  INFO hdp::cairo_runner::run: number of steps: 22959
2024-10-30T11:26:52.369413Z  INFO hdp::cairo_runner::run: cairo run output: CairoRunOutput {
    tasks_root: 0x40338e4a3bf4160b52544dc2e0cac3710905683083d7af26af6656cd2c1a9828,
    results_root: 0xd666f65da14252d1c31f5ea28b0b95a155278e813ecf6ecd262598afb112e276,
    results: [
        264350994751032333482775472856390598011,
    ],
}
2024-10-30T11:26:52.369733Z  INFO hdp::processor: 2️⃣  Processor completed successfully
2024-10-30T11:26:52.369769Z  INFO hdp::hdp_run: finished processing the data, saved pie file in cairo.pie
2024-10-30T11:26:52.369824Z  INFO hdp_cli::cli: HDP Cli Finished in: 11.065157458s
```

## Deploying and Running the HDP Module via Server

### 1. Deploy the HDP Module

Upload the compiled contract class file to the program registry:

```console
curl --location 'https://sharp.api.herodotus.cloud/submit-program?apiKey={API_KEY}' \
--form 'programFile=@"custom_module_custom_module.compiled_contract_class.json"'
```

This request returns a program hash, for example:

```console
0xaae117f9cdfa4fa4d004f84495c942adebf17f24aec8f86e5e6ea29956b47e
```

To confirm program registration, query the registry:

```sh
curl --location 'http://program-registery.api.herodotus.cloud/get-metadata?program_hash=0xaae117f9cdfa4fa4d004f84495c942adebf17f24aec8f86e5e6ea29956b47e'
```

## 2. Submit a Request to the HDP Module

With the program hash from the registry, submit a request to the HDP:

Use the correct program hash and provide input data for the `pub fn main()` function.

```console
curl --location 'https://hdp.api.herodotus.cloud/submit-batch-query?apiKey={API_KEY}' \
--header 'Content-Type: application/json' \
--data '{
  "destinationChainId": "ETHEREUM_SEPOLIA",
  "tasks": [
    {
      "type": "Module",
      "programHash": "0xaae117f9cdfa4fa4d004f84495c942adebf17f24aec8f86e5e6ea29956b47e",
      "inputs": [
        {
          "visibility": "public",
          "value": "0x3"
        },
        {
          "visibility": "public",
          "value": "0x5222A4"
        },
        {
          "visibility": "public",
          "value": "0x5222A7"
        },
        {
          "visibility": "public",
          "value": "0x5222C4"
        },
        {
          "visibility": "public",
          "value": "0x13cb6ae34a13a0977f4d7101ebc24b87bb23f0d5"
        }
      ]
    }
  ]
}'
```

## Tool Versions

The versions used in this template are:

```console
❯ scarb --version
scarb 2.6.5 (d49f54394 2024-06-11)
cairo: 2.6.4 (https://crates.io/crates/cairo-lang-compiler/2.6.4)
sierra: 1.5.0
```
