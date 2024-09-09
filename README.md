# HDP Module Template

This is a public template to quickly start your HDP (Herodotus Data Processor) custom module development. For more information, please refer to the [HDP Docs](https://docs.herodotus.dev/herodotus-docs/developers/data-processor).

## 1. Build

Build the compiled contract class file:

```console
scarb build
```

You should see that a new build file has been added:

```
custom_module \
    src \
       lib.cairo
    target \
       dev \
          custom_module_custom_module.compiled_contract_class.json
```

## 2. Upload

Upload the compiled contract class file to the program registry:

```console
curl --location 'http://program-registery.api.herodotus.cloud/upload-program?apiKey={API_KEY}' \
--form 'program=@"custom_module_custom_module.compiled_contract_class.json"'
```

This request will return a program hash as a response:

```console
0x64041a339b1edd10de83cf031cfa938645450f971d2527c90d4c2ce68d7d412
```

## 3. Request

Now, with this custom module, you can submit a request to the HDP:

Provide the correct program hash from the program registry. Input data should be the input for the `pub fn main()` function.

```console
curl --location 'https://hdp.api.herodotus.cloud/submit-batch-query?apiKey={API_KEY}' \
--header 'Content-Type: application/json' \
--data '{
    "destinationChainId": "ETHEREUM_SEPOLIA",
    "tasks": [
        {
        "type": "Module",
        "programHash": "0x64041a339b1edd10de83cf031cfa938645450f971d2527c90d4c2ce68d7d412",
        "inputs": [
            {
            "visibility": "private",
            "value": "0x5222a4"
            },
            {
            "visibility": "public",
            "value": "0x00000000000000000000000013cb6ae34a13a0977f4d7101ebc24b87bb23f0d5"
            }
        ]
        }
    ]
    }'
```

## Versions

Here are the current versions:

```console
❯ scarb --version
scarb 2.6.5 (d49f54394 2024-06-11)
cairo: 2.6.4 (https://crates.io/crates/cairo-lang-compiler/2.6.4)
sierra: 1.5.0
```
