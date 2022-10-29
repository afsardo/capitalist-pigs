contract;

dep data_structures;
dep errors;
dep interface;
dep constants;

use data_structures::TokenMetaData;
use errors::{AccessError, InflationError, InitError, InputError};
use interface::{Pigs};
use constants::{THOUSAND, YEAR};

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

storage {
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

///////////////////
// Internal Methods
///////////////////
#[storage(read, write)]
fn add_pig(owner: Identity, pig: u64) {
    storage.pigs.get(owner).push(pig);
}

#[storage(read, write)]
fn remove_pig(owner: Identity, pig: u64) {
    let i: u64 = 0;
    let owned_pigs: Vec<u64> = storage.pigs.get(owner);

    while (i < owned_pigs.len()) {
        if (owned_pigs.get(i).unwrap() == pig) {
            storage.pigs.get(owner).remove(i);
            break;
        }
    }
}

impl Pigs for Contract {
    #[storage(read)]
    fn admin() -> Identity {
        let admin = storage.admin;
        require(admin.is_some(), InputError::AdminDoesNotExist);
        admin.unwrap()
    }

    #[storage(read)]
    fn piglet_transformer() -> Identity {
        let piglet_transformer = storage.piglet_transformer;
        require(piglet_transformer.is_some(), InputError::PigletTransformerDoesNotExist);
        piglet_transformer.unwrap()
    }

    #[storage(read, write)]
    fn approve(approved: Identity, token_id: u64) {
        let approved = Option::Some(approved);
        let token_owner = storage.owners.get(token_id);
        require(token_owner.is_some(), InputError::TokenDoesNotExist);

        // Ensure that the sender is the owner of the token to be approved
        let sender = msg_sender().unwrap();
        require(token_owner.unwrap() == sender, AccessError::SenderNotOwner);

        // Set and store the `approved` `Identity`
        storage.approved.insert(token_id, approved);
    }

    #[storage(read)]
    fn approved(token_id: u64) -> Identity {
        // TODO: This should be removed and update function definition to include Option once
        // https://github.com/FuelLabs/fuels-rs/issues/415 is revolved
        // storage.approved.get(token_id)
        let approved = storage.approved.get(token_id);
        require(approved.is_some(), InputError::ApprovedDoesNotExist);
        approved.unwrap()
    }

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64 {
        storage.balances.get(owner)
    }

    #[storage(read, write)]
    fn burn(token_id: u64) {
        // Ensure this is a valid token
        let token_owner = storage.owners.get(token_id);
        require(token_owner.is_some(), InputError::TokenDoesNotExist);

        // Ensure the sender owns the token that is provided
        let sender = msg_sender().unwrap();
        require(token_owner.unwrap() == sender, AccessError::SenderNotOwner);

        remove_pig(token_owner.unwrap(), token_id);
        storage.owners.insert(token_id, Option::None());
        storage.balances.insert(sender, storage.balances.get(sender) - 1);
        storage.total_supply -= 1;
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
    fn snapshot_supply() {
        require(timestamp() >= storage.inflation_start_time, InflationError::InvalidSnapshotTime);
        require(storage.snapshotted_supply == 0, InflationError::AlreadySnapshotted);

        storage.snapshotted_supply = storage.total_supply;
    }

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool {
        storage.operator_approval.get((owner, operator, ))
    }

    #[storage(read)]
    fn max_supply() -> u64 {
        storage.max_supply
    }

    #[storage(read)]
    fn pigs(owner: Identity, index: u64) -> u64 {
        let all_pigs = storage.pigs.get(owner);
        require(index < all_pigs.len(), InputError::IndexExceedsArrayLength);
        all_pigs.get(index).unwrap()
    }

    #[storage(read, write)]
    fn gg(puta_madre: Identity) -> u64 {
        return 1
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

        // Ensure that the sender is the admin if this is a controlled access mint or the `piglet_transformer` if the admin is this contract
        let admin = storage.admin;
        let piglet_transformer = storage.piglet_transformer;
        let caller: Result<Identity, AuthError> = msg_sender();

        require((!storage.access_control || (admin.is_some() && msg_sender().unwrap() == admin.unwrap())) || (admin.unwrap() == Identity::ContractId(contract_id()) && piglet_transformer.is_some() && caller.unwrap() == piglet_transformer.unwrap()), AccessError::SenderNotAdminOrPigletTransformer);

        // Mint as many tokens as the sender has asked for
        let mut index = tokens_minted;
        while index < total_mint {
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
    fn meta_data(token_id: u64) -> TokenMetaData {
        require(token_id < storage.tokens_minted, InputError::TokenDoesNotExist);
        storage.meta_data.get(token_id)
    }

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity {
        // TODO: This should be removed and update function definition to include Option once
        // https://github.com/FuelLabs/fuels-rs/issues/415 is revolved
        //storage.owners.get(token_id).unwrap()
        let owner = storage.owners.get(token_id);
        require(owner.is_some(), InputError::OwnerDoesNotExist);
        owner.unwrap()
    }

    #[storage(read, write)]
    fn set_admin(admin: Identity) {
        // Ensure that the sender is the admin
        let current_admin = storage.admin;
        require(current_admin.is_some() && msg_sender().unwrap() == current_admin.unwrap(), AccessError::SenderCannotSetAccessControl);
        storage.admin = Option::Some(admin);
    }

    #[storage(read, write)]
    fn set_piglet_transformer(piglet_transformer: Identity) {
        let current_admin = storage.admin;
        let new_piglet_transformer = Option::Some(piglet_transformer);
        let current_piglet_transformer = storage.piglet_transformer;

        require((current_piglet_transformer.is_some() && msg_sender().unwrap() == current_piglet_transformer.unwrap()) || (current_admin.is_some() && msg_sender().unwrap() == current_admin.unwrap()), AccessError::SenderCannotSetPigletTransformer);
        storage.piglet_transformer = new_piglet_transformer;
    }

    #[storage(read, write)]
    fn set_approval_for_all(approve: bool, operator: Identity) {
        // Store `approve` with the (sender, operator) tuple
        let sender = msg_sender().unwrap();
        storage.operator_approval.insert((sender, operator, ), approve);
    }

    #[storage(read)]
    fn total_supply() -> u64 {
        storage.total_supply
    }

    #[storage(read, write)]
    fn transfer_from(from: Identity, to: Identity, token_id: u64) {
        // Make sure the `token_id` maps to an existing token
        let token_owner = storage.owners.get(token_id);
        require(token_owner.is_some(), InputError::TokenDoesNotExist);
        let token_owner = token_owner.unwrap();

        // Ensure that the sender is either:
        // 1. The owner of the token
        // 2. Approved for transfer of this `token_id`
        // 3. Has operator approval for the `from` identity and this token belongs to the `from` identity
        let sender = msg_sender().unwrap();
        let approved = storage.approved.get(token_id);
        require(sender == token_owner || (approved.is_some() && sender == approved.unwrap()) || (from == token_owner && storage.operator_approval.get((from, sender, ))), AccessError::SenderNotOwnerOrApproved);

        // Set the new owner of the token and reset the approved Identity
        storage.owners.insert(token_id, Option::Some(to));
        if approved.is_some() {
            storage.approved.insert(token_id, Option::None());
        }

        remove_pig(from, token_id);
        add_pig(to, token_id);

        storage.balances.insert(from, storage.balances.get(from) - 1);
        storage.balances.insert(to, storage.balances.get(to) + 1);
    }
}
