// This is example contract of using HDP with account memorizer 
// Sum of balances of accounts in block number list and returns that value.
// Full HDP supports header, account and storage. 

#[starknet::contract]
mod get_parent {
    use hdp_cairo::memorizer::header_memorizer::HeaderMemorizerTrait;
    use hdp_cairo::{HDP, memorizer::header_memorizer::{HeaderKey, HeaderMemorizerImpl}};

    #[storage]
    struct Storage {}

    #[external(v0)]
    pub fn main(ref self: ContractState, hdp: HDP, block_number: u32) -> u256 {
        hdp
            .header_memorizer
            .get_parent(HeaderKey { chain_id: 11155111, block_number: block_number.into() })
    }
}
