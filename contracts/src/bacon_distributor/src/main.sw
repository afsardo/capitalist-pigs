contract;

dep errors;
dep interface;

use errors::*;
use interface::BaconDistributor;

use std::{
    address::*,
    chain::auth::*,
    context::{ *, call_frames::* },
    identity::Identity,
    contract_id::ContractId,
    revert::require,
    storage::*,
    token::*,
    constants::{BASE_ASSET_ID}
};

storage {
    /// The ID of the bacon token contract
    bacon: ContractId           = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000),
    /// The address of the staking contract which can claim bacon
    staking: Option<ContractId> = Option::None
}

///////
// ABIs
///////
abi Bacon {
    /// Initialize contract
    #[storage(read, write)]
    fn initialize(mint_amount: u64, address: Address);
    /// Set mint amount for each address
    #[storage(read, write)]
    fn set_mint_amount(mint_amount: u64);
    /// Get balance of the contract coins
    fn get_balance() -> u64;
    /// Return the mint amount
    #[storage(read)]
    fn get_mint_amount() -> u64;
    /// Get balance of a specified token on contract
    fn get_token_balance(asset_id: ContractId) -> u64;
    /// Mint token coins
    #[storage(read)]
    fn mint_coins(mint_amount: u64);
    /// Burn token coins
    #[storage(read)]
    fn burn_coins(burn_amount: u64);
    /// Transfer a contract coins to a given output
    #[storage(read)]
    fn transfer_coins(coins: u64, address: Address);
    /// Transfer a specified token from the contract to a given output
    #[storage(read)]
    fn transfer_token_to_output(coins: u64, asset_id: ContractId, address: Address);
    /// Method called from address to mint coins
    #[storage(read, write)]
    fn mint();
}

/////////////////
// Access Control
/////////////////
/// Return the sender as a contract ID or panic
fn get_msg_sender_id_or_panic() -> ContractId {
    let sender: Result<Identity, AuthError> = msg_sender();
    if let Identity::ContractId(id) = sender.unwrap() {
        id
    } else {
        revert(0);
    }
}

/// Check that the method caller is the staking contract and if not, revert
#[storage(read)]
fn only_staking() {
    let sender = get_msg_sender_id_or_panic();
    require(storage.staking.unwrap() == sender, AccessControlError::NotStakingContract);
}

impl BaconDistributor for Contract {
    #[storage(read, write)]
    fn constructor(bacon: ContractId, staking: ContractId) {
        require(bacon != BASE_ASSET_ID, InitError::InvalidBaconID);
        require(staking != BASE_ASSET_ID, InitError::InvalidStakingID);

        let staking     = Option::Some(staking);
        storage.staking = staking;
        storage.bacon   = bacon;
    }

    #[storage(read, write)]
    fn claim_fees(receiver: Identity, amount: u64) {
        only_staking();
        transfer(amount, storage.bacon, receiver);
    }
}
