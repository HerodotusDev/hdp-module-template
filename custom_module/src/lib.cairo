#[starknet::contract]
mod custom_module {
    use hdp_cairo::memorizer::header_memorizer::HeaderMemorizerTrait;
    // use hdp_cairo::memorizer::account_memorizer::AccountMemorizerTrait;
    // use hdp_cairo::memorizer::storage_memorizer::StorageMemorizerTrait;
    use hdp_cairo::{HDP, memorizer::header_memorizer::{HeaderKey, HeaderMemorizerImpl}};
    // use hdp_cairo::{memorizer::account_memorizer::{AccountKey, AccountMemorizerImpl}};
    // use hdp_cairo::{memorizer::storage_memorizer::{StorageKey, StorageMemorizerImpl}};
    use starknet::syscalls::call_contract_syscall;
    use starknet::{ContractAddress, SyscallResult, SyscallResultTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    pub fn main(
        ref self: ContractState, hdp: HDP, block_number: u32, address: felt252, storage_slot: u256
    ) -> u256 {
        let result = hdp
            .header_memorizer
            .get_parent(HeaderKey { chain_id: 11155111, block_number: block_number.into() });

         
        // *Note* the following line is to demonstrate how to use account and storage memorizers. 
        // If want to try account / storage memorizers, try uncomment import line also

        // let result = hdp
        //     .account_memorizer
        //     .get_nonce(
        //         AccountKey { chain_id: 11155111, block_number: block_number.into(), address }
        //     );

        // let result = hdp
        //     .storage_memorizer
        //     .get_slot(
        //         StorageKey {
        //             chain_id: 11155111, block_number: block_number.into(), address, storage_slot
        //         }
        //     );

        // For now we can only able to return `u256` type!
        result
    }
}
