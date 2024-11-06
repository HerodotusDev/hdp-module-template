# HDP Module Template

A quickstart template for developing custom modules with the Herodotus Data Processor (HDP). Verified on-chain state can be accessed in Cairo contracts using custom syscall invoke functions.

[📚 View Full Documentation](https://docs.herodotus.dev/herodotus-docs/developers/data-processor)

## 📋 Prerequisites

- [Scarb](https://docs.swmansion.com/scarb/download) (v2.6.5+)
- Docker
- Ethereum Sepolia RPC URL

## 🔧 Setup & Local Development

1. **Configure Environment**

   - Copy `.env.example` to `.env`:
     ```sh
     cp .env.example .env
     ```
   - Add your Ethereum Sepolia RPC URL to the `.env` file.

2. **Build the Module**

   ```sh
   scarb build
   ```

   This command generates:

   ```
   custom_module/
     ├── src/
     │   └── lib.cairo
     └── target/
         └── dev/
             └── custom_module.compiled_contract_class.json
   ```

3. **Configure Input Parameters**

   Edit `request.json`. **Only modify the `inputs` section; leave other fields unchanged**. Here's an example:

   ```json
   {
     "destinationChainId": "ETHEREUM_SEPOLIA", // DO NOT EDIT
     "tasks": [
       {
         "type": "Module", // DO NOT EDIT
         "localClassPath": "./local_contract.json", // DO NOT EDIT
         "inputs": [
           {
             "visibility": "public", // Can be "public" or "private"
             "value": "0x5222A4"
           }
         ]
       }
     ]
   }
   ```

4. **Run Locally**

   Ensure Docker is running, then use one of the following commands:

   **Generic command structure:**

   ```sh
   ./script/run.sh <request_file_path> <compiled_contract_class_path> [output_directory]
   ```

   **Example with default paths:**

   ```sh
   ./script/run.sh request.json custom_module/target/dev/custom_module_get_parent.compiled_contract_class.json ./output
   ```

   If run successfully, the log will display:

   ```console
   ❯ ./script/run.sh request.json custom_module/target/dev/custom_module_get_parent.compiled_contract_class.json
   2023-11-06T07:39:51.314675Z  INFO hdp::preprocessor::module_registry: Contract class fetched successfully from local path: "./local_contract.json"
   2023-11-06T07:39:51.314718Z  INFO hdp::preprocessor::compile::module: Target task: Module {
     program_hash: 0x62c37715e000abfc6f931ee05a4ff1be9d7832390b31e5de29d197814db8156,
     inputs: [
       ModuleInput {
         visibility: Public,
         value: 0x5222a4,
       },
     ],
     local_class_path: Some("./local_contract.json"),
   }
   ...
   Output files are saved in the 'output' directory.
   ```

   In the `output` folder, you will find:

   ```
   output/
     ├── batch.json
     ├── cairo.pie
     └── input.json
   ```

### Development Resources

- Install [Cairo1 Syscalls](https://github.com/HerodotusDev/hdp-cairo/tree/main/cairo1_syscall_binding) via Scarb as a dependency.
- Browse [Example Contracts](https://github.com/HerodotusDev/hdp-test/tree/main/contracts) for implementation references.

## 📘 Technical Specifications

### Module Constraints

- **Stateless Execution**: No persistent storage between executions.
- **Limited Syscalls**: Standard StarkNet syscalls are not supported.
- **HDP Syscall Interface**: Exclusive access to cross-chain data, including:
  - Ethereum block headers
  - Account states
  - Storage slots
  - Transactions & receipts

## 🚀 API Deployment

Once the module is working, it can be deployed to the program registry and then invoked via the API. This enables the on-chain decommitment of the module's result.

### 1. Deploy to Program Registry

Use the following command to deploy your compiled contract class to the program registry:

```sh
curl --location 'https://sharp.api.herodotus.cloud/submit-program?apiKey={API_KEY}' \
--form 'programFile=@"custom_module_custom_module.compiled_contract_class.json"'
```

Verify the deployment:

```sh
curl --location 'http://program-registery.api.herodotus.cloud/get-metadata?program_hash=YOUR_PROGRAM_HASH'
```

This request returns a program hash, for example:

```json
{
  "programHash": "0xaae117f9cdfa4fa4d004f84495c942adebf17f24aec8f86e5e6ea29956b47e"
}
```

### 2. Submit Module Request

Use the following command to submit a module request:

```sh
curl --location 'https://hdp.api.herodotus.cloud/submit-batch-query?apiKey={API_KEY}' \
--header 'Content-Type: application/json' \
--data '{
  "destinationChainId": "ETHEREUM_SEPOLIA",
  "tasks": [{
    "type": "Module",
    "programHash": "YOUR_PROGRAM_HASH",
    "inputs": [
      {"visibility": "public", "value": "0x3"},
      {"visibility": "public", "value": "0x5222A4"}
      // Additional inputs as needed
    ]
  }]
}'
```

**Note**: Remove the comments in the JSON data before executing the command, as JSON does not support comments.

## 🛠️ Tool Versions

Ensure that you are using compatible versions of the tools:

```
scarb 2.6.5 (d49f54394 2024-06-11)
cairo: 2.6.4 (https://crates.io/crates/cairo-lang-compiler/2.6.4)
sierra: 1.5.0
```
