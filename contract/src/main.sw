contract;

// use errors::{AccessError, InflationError, InitError, InputError};
// use interface::{Pigs};
// use constants::{THOUSAND, YEAR};

pub struct TokenMetaData {
    // This is left as an example. Support for dynamic length string is needed here
    name: str[7],
}

impl TokenMetaData {
    fn new() -> Self {
        Self {
            name: "Example",
        }
    }
}

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderNotAdminOrPigletTransformer: (),
    SenderCannotSetPigletTransformer: (),
    SenderNotOwner: (),
    SenderNotOwnerOrApproved: (),
}

pub enum InitError {
    AdminIsNone: (),
    InvalidInflationStartTime: (),
    InvalidInflationRate: (),
    InvalidInflationEpoch: (),
    CannotReinitialize: (),
}

pub enum InflationError {
    InvalidSnapshotTime: (),
    AlreadySnapshotted: (),
    MintExceedsInflation: ()
}

pub enum InputError {
    AdminDoesNotExist: (),
    IndexExceedsArrayLength: (),
    PigletTransformerDoesNotExist: (),
    ApprovedDoesNotExist: (),
    NotEnoughTokensToMint: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    TokenSupplyCannotBeZero: (),
}

pub const THOUSAND: u64 = 1000;
pub const YEAR: u64     = 31536000;

use std::{
    block::timestamp,
    chain::auth::*,
    constants::{
        BASE_ASSET_ID,
        ZERO_B256,
    },
    context::{
        *,
        call_frames::*,
    },
    contract_id::ContractId,
    identity::Identity,
    logging::log,
    option::Option,
    result::Result,
    revert::{
        require,
        revert,
    },
    storage::StorageMap,
};

// Storage is the way to add persistent state to our contracts.
//
// For this contract, create a storage variable called `counter` and initialize it to 0.
storage {
    counter: u64 = 0,

    /// Determines if only the contract's `admin` is allowed to call the mint function.
    /// This is only set on the initalization of the contract.
    access_control: bool = false,
    /// Stores the user that is permitted to mint if `access_control` is set to true.
    /// Will store `None` if this contract does not have `access_control` set.
    /// Only the `admin` is allowed to change the `admin` of the contract.
    admin: Option<Identity> = Option::None,
    /// Stores the contract that is permitted to mint if `admin` is null.
    /// Only the `piglet_transformer` is allowed to change the `piglet_transformer` of the contract.
    piglet_transformer: Option<Identity> = Option::None,
    /// Stores the user which is approved to transfer a token based on it's unique identifier.
    /// In the case that no user is approved to transfer a token based on the token owner's behalf,
    /// `None` will be stored.
    /// Map(token_id => approved)
    approved: StorageMap<u64, Option<Identity>> = StorageMap {},
    /// Used for O(1) lookup of the number of tokens owned by each user.
    /// This increments or decrements when minting, transfering ownership, and burning tokens.
    /// Map(Identity => balance)
    balances: StorageMap<Identity, u64> = StorageMap {},
    /// The total supply tokens that can ever be minted.
    /// This can only be set on the initalization of the contract.
    max_supply: u64 = 0,
    /// Stores the `TokenMetadata` for each token based on the token's unique identifier.
    /// Map(token_id => TokenMetadata)
    meta_data: StorageMap<u64, TokenMetaData> = StorageMap {},
    /// Maps a tuple of (owner, operator) identities and stores whether the operator is allowed to
    /// transfer ALL tokens on the owner's behalf.
    /// Map((owner, operator) => approved)
    operator_approval: StorageMap<(Identity, Identity), bool> = StorageMap {},
    /// Stores the user which owns a token based on it's unique identifier.
    /// If the token has been burned then `None` will be stored.
    /// Map(token_id => owner)
    owners: StorageMap<u64, Option<Identity>> = StorageMap {},
    /// Stores the array of pigs that a user holds
    /// Map (owner => pig_array)
    pigs: StorageMap<Identity, Vec<u64>> = StorageMap {}, // NOT recommended in prod
    /// The total number of tokens that ever have been minted.
    /// This is used to assign token identifiers when minting. This will only be incremented.
    tokens_minted: u64 = 0,
    /// The number of tokens currently in existence.
    /// This is incremented on mint and decremented on burn. This should not be used to assign
    /// unqiue identifiers due to the decrementation of the value on burning of tokens.
    total_supply: u64 = 0,
    /// The timestamp when inflation starts.
    inflation_start_time: u64 = 0,
    /// The inflation rate.
    inflation_rate: u64 = 0,
    /// The timestamp over which `inflation_rate` applies.
    inflation_epoch: u64 = 0,
    /// The snapshotted total supply of NFTs used to regulate inflation.
    snapshotted_supply: u64 = 0,
}

#[storage(read, write)]
fn add_pig(owner: Identity, pig: u64) {
    storage.pigs.get(owner).push(pig);
}

// Define the interface our contract shall have
abi MyContract {
    // A `counter` method with no parameters that returns the current value of the counter and 
    // *only reads* from storage.
    #[storage(read)]
    fn counter() -> u64;

    /// Sets the inital state and unlocks the functionality for the rest of the contract
    ///
    /// This function can only be called once
    ///
    /// # Arguments
    ///
    /// * `access_control` - Determines whether only the admin can call the mint function
    /// * `admin` - The user which has the ability to mint if `access_control` is set to true and change the contract's admin
    /// * `piglet_transformer` - The contract that has the ability to mint new pig NFTs if the `admin` is null
    /// * `max_supply` - The maximum supply of tokens that can ever be minted
    /// * `inflation_start_time` - The timestamp when inflation starts
    /// * `inflation_rate` - The inflation rate allowed every epoch
    /// * `inflation_epoch` - The epoch during which `inflation_rate` inflation is allowed
    ///
    /// # Reverts
    ///
    /// * When the constructor function has already been called
    /// * When the `token_supply` is set to 0
    /// * When `access_control` is set to true and no admin `Identity` was given
    #[storage(read, write)]
    fn constructor(access_control: bool, admin: Identity, piglet_transformer: Identity, max_supply: u64, inflation_start_time: u64, inflation_rate: u64, inflation_epoch: u64);

    // An `increment` method that takes a single integer parameter, increments the counter by that 
    // parameter, and returns its new value. This method has read/write access to storage.
    #[storage(read, write)]
    fn increment(param: u64) -> u64;

    /// Mints `amount` number of tokens to the `to` `Identity`
    ///
    /// Once a token has been minted, it can be transfered and burned
    ///
    /// # Arguments
    ///
    /// * `amount` - The number of tokens to be minted in this transaction
    /// * `to` - The user which will own the minted tokens
    ///
    /// # Reverts
    ///
    /// * When the sender attempts to mint more tokens than total supply
    /// * When the sender is not the admin and `access_control` is set
    #[storage(read, write)]
    fn mint(amount: u64, to: Identity);

    /// Returns the total supply of tokens which are currently in existence
    #[storage(read)]
    fn total_supply() -> u64;
}

// The implementation of the contract's ABI
impl MyContract for Contract {
    #[storage(read)]
    fn counter() -> u64 {
        // Read and return the current value of the counter from storage
        storage.counter
    }

    #[storage(read, write)]
    fn increment(param: u64) -> u64 {
        // Read the current value of the counter from storage, increment the value read by the argument 
        // received, and write the new value back to storage.
        storage.counter += param;

        // Return the new value of the counter from storage
        storage.counter
    }

    #[storage(read, write)]
    fn constructor(
        access_control: bool,
        admin: Identity,
        piglet_transformer: Identity,
        max_supply: u64,
        inflation_start_time: u64,
        inflation_rate: u64,
        inflation_epoch: u64,
    ) {
        // This function can only be called once so if the token supply is already set it has
        // already been called
        // TODO: Remove this and update function definition to include Option once
        // https://github.com/FuelLabs/fuels-rs/issues/415 is revolved
        require(inflation_start_time >= timestamp(), InitError::InvalidInflationStartTime);
        require(inflation_rate > 0 && inflation_rate <= THOUSAND, InitError::InvalidInflationRate);
        require(inflation_epoch > 0 && inflation_epoch <= YEAR, InitError::InvalidInflationEpoch);

        let admin = Option::Some(admin);
        let piglet_transformer = Option::Some(piglet_transformer);

        require(storage.max_supply == 0, InitError::CannotReinitialize);
        require(max_supply != 0, InputError::TokenSupplyCannotBeZero);
        require((access_control && admin.is_some()) || (!access_control && admin.is_none()), InitError::AdminIsNone);

        storage.inflation_start_time = inflation_start_time;
        storage.inflation_rate = inflation_rate;
        storage.inflation_epoch = inflation_epoch;
        storage.access_control = access_control;
        storage.admin = admin;
        storage.piglet_transformer = piglet_transformer;
        storage.max_supply = max_supply;
    }

    #[storage(read, write)]
    fn mint(amount: u64, to: Identity) {
        let tokens_minted = storage.tokens_minted;
        let total_mint = tokens_minted + amount;

        // The current number of tokens minted plus the amount to be minted cannot be
        // greater than the total supply or the current allowed amount according to the `inflation_rate`
        let elapsed_time: u64 = if (storage.inflation_start_time < timestamp()) { timestamp() - storage.inflation_start_time } else { 0 };
        let inflation_allowed_max_supply: u64 = storage.snapshotted_supply * (THOUSAND + storage.inflation_rate * (elapsed_time / storage.inflation_epoch)) / THOUSAND;

        require(storage.max_supply >= total_mint, InputError::NotEnoughTokensToMint);
        if (storage.snapshotted_supply > 0
            && inflation_allowed_max_supply > 0)
        {
            require(inflation_allowed_max_supply >= total_mint, InflationError::MintExceedsInflation);
        }

        let a = 1;

        // Ensure that the sender is the admin if this is a controlled access mint or the `piglet_transformer` if the admin is this contract
        let admin = storage.admin;
        let piglet_transformer = storage.piglet_transformer;
        let caller: Result<Identity, AuthError> = msg_sender();

        require(
            (!storage.access_control 
            ||             
            // (admin.is_some() && msg_sender().unwrap() == admin.unwrap())
            // TODO: FIX THIS THING
            true
            ) 
            || 
            (admin.unwrap() == Identity::ContractId(contract_id()) && piglet_transformer.is_some() && caller.unwrap() == piglet_transformer.unwrap()) 
            , AccessError::SenderNotAdminOrPigletTransformer);

        // Mint as many tokens as the sender has asked for
        let mut index = tokens_minted;
        while (index < total_mint) {
            // Create the TokenMetaData for this new token
            storage.meta_data.insert(index, ~TokenMetaData::new());
            storage.owners.insert(index, Option::Some(to));
            add_pig(to, index);
            index += 1;
        }

        storage.balances.insert(to, storage.balances.get(to) + amount);
        storage.tokens_minted = total_mint;
        storage.total_supply += amount;
    }

    #[storage(read)]
    fn total_supply() -> u64 {
        storage.total_supply
    }
}
