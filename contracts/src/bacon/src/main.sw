contract;

dep errors;
dep interface;

use errors::*;
use interface::Bacon;

use std::{
    address::*,
    chain::auth::*,
    context::{
        *,
        call_frames::*,
    },
    contract_id::ContractId,
    revert::require,
    storage::*,
    token::*,
    constants::{ZERO_B256}
};

storage {
    mint_amount: u64 = 0,
    owner: Address = Address { value: ZERO_B256 },
    mint_list: StorageMap<Address, bool> = StorageMap {},
}

/////////////////
// Access Control
/////////////////
/// Return the sender as an address or panic
fn get_msg_sender_address_or_panic() -> Address {
    let sender: Result<Identity, AuthError> = msg_sender();
    if let Identity::Address(address) = sender.unwrap() {
        address
    } else {
        revert(0);
    }
}

#[storage(read)]
fn validate_owner() {
    let sender = get_msg_sender_address_or_panic();
    require(storage.owner == sender, Error::NotOwner);
}

impl Bacon for Contract {
    ////////////////
    // Owner Methods
    ////////////////
    #[storage(read, write)]
    fn initialize(mint_amount: u64, address: Address) {
        require(storage.owner.into() == ZERO_B256, Error::CannotReinitialize);
        // Start the next message to be signed
        storage.owner = address;
        storage.mint_amount = mint_amount;
    }

    #[storage(read, write)]
    fn set_mint_amount(mint_amount: u64) {
        validate_owner();
        storage.mint_amount = mint_amount;
    }

    #[storage(read)]
    fn mint_coins(mint_amount: u64) {
        validate_owner();
        mint(mint_amount);
    }

    #[storage(read)]
    fn burn_coins(burn_amount: u64) {
        validate_owner();
        burn(burn_amount);
    }

    #[storage(read)]
    fn transfer_coins(coins: u64, address: Address) {
        validate_owner();
        transfer_to_address(coins, contract_id(), address);
    }

    #[storage(read)]
    fn transfer_token_to_output(coins: u64, asset_id: ContractId, address: Address) {
        validate_owner();
        transfer_to_address(coins, asset_id, address);
    }

    /////////////////////
    // Mint Public Method
    /////////////////////
    #[storage(read, write)]
    fn mint() {
        require(storage.mint_amount > 0, Error::MintIsClosed);

        // Enable an address to mint only once
        let sender = get_msg_sender_address_or_panic();
        require(storage.mint_list.get(sender) == false, Error::AddressAlreadyMinted);

        storage.mint_list.insert(sender, true);
        mint_to_address(storage.mint_amount, sender);
    }

    ////////////////////
    // Read-Only Methods
    ////////////////////
    #[storage(read)]
    fn get_mint_amount() -> u64 {
        storage.mint_amount
    }

    fn get_balance() -> u64 {
        balance_of(contract_id(), contract_id())
    }

    fn get_token_balance(asset_id: ContractId) -> u64 {
        balance_of(asset_id, contract_id())
    }
}
