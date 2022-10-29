contract;

dep errors;
dep interface;
dep constants;

use errors::*;
use interface::{Staking};
use constants::{MAX_DELEGATORS};

use std::{
    chain::auth::msg_sender,
    identity::Identity,
    logging::log,
    option::Option,
    result::Result,
    revert::{require, revert},
    storage::StorageMap,
    block::timestamp,
    constants::{ZERO_B256, BASE_ASSET_ID}
};

storage {
    /// The pig NFT contract address
    pigs: Option<ContractId> = Option::None,
    /// The fee token contract address
    fee_token: Option<ContractId> = Option::None,
    /// The fee distributor contract
    fee_distributor: Option<Identity> = Option::None,
    /// The address of the truffles token contract
    truffles: Option<ContractId> = Option::None,
    /// The mapping of all pig owners
    pig_owner: StorageMap<u64, Identity> = StorageMap {},
    /// The pigs a user currently stakes
    staked_pigs: StorageMap<Identity, Vec<u64>> = StorageMap {},
    /// The total staking power a pig staker has
    staking_power: StorageMap<Identity, u64> = StorageMap {},
    /// The mapping of all piglet owners
    piglet_owner: StorageMap<u64, Identity> = StorageMap {},
    /// The piglets a user currently delegates
    delegated_piglets: StorageMap<Identity, Vec<u64>> = StorageMap {},
    /// The piglets delegated to each pig
    piglet_to_pig: StorageMap<u64, u64> = StorageMap {},
    /// The commission offered to delegators of a specific pig
    fee_commission: StorageMap<u64, u64> = StorageMap {},
    /// Total amount of fees distributed per second to each staked pig
    fees_per_second: u64 = 0,
    /// Amount of new truffles that can be minted each second for a staked pig
    truffles_per_second: u64 = 0,
    /// The last timestamp when a pig staker claimed fees
    last_pig_fee_claim: StorageMap<u64, u64> = StorageMap {},
    /// The last timestamp when a pig staker minted accrued truffles
    last_pig_truffle_mint: StorageMap<u64, u64> = StorageMap {}
};

///////
// ABIs
///////
abi Piglet {
    #[storage(read)]
    fn admin() -> Identity;

    #[storage(read, write)]
    fn approve(approved: Identity, token_id: u64);

    #[storage(read)]
    fn approved(token_id: u64) -> Identity;

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64;

    #[storage(read, write)]
    fn burn(token_id: u64);

    #[storage(read, write)]
    fn constructor(access_control: bool, admin: Identity, piglet_minter: Identity, max_supply: u64);

    #[storage(read, write)]
    fn delegate(pig: u64, piglets: [u64]);

    #[storage(read, write)]
    fn remove_delegation(pig: u64, piglets: [u64]);

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool;

    #[storage(read)]
    fn max_supply() -> u64;

    #[storage(read, write)]
    fn mint(amount: u64, to: Identity);

    #[storage(read, write)]
    fn mintPigs(piglets: [u64]) -> [u64];

    #[storage(read)]
    fn meta_data(token_id: u64) -> TokenMetaData;

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    #[storage(read, write)]
    fn set_admin(admin: Identity);

    #[storage(read, write)]
    fn set_piglet_minter(piglet_minter: Identity);

    #[storage(read, write)]
    fn set_approval_for_all(approve: bool, operator: Identity);

    #[storage(read)]
    fn total_supply() -> u64;

    #[storage(read, write)]
    fn transfer_from(from: Identity, to: Identity, token_id: u64);

    #[storage(read)]
    fn piglet_minter() -> Identity;
}

abi Token {
    #[storage(read, write)]
    fn initialize(mint_amount: u64, address: Address);

    #[storage(read, write)]
    fn set_mint_amount(mint_amount: u64);

    #[storage(read)]
    fn get_balance() -> u64;

    #[storage(read)]
    fn get_mint_amount() -> u64;

    #[storage(read)]
    fn get_token_balance(asset_id: ContractId) -> u64;

    #[storage(read)]
    fn mint_coins(mint_amount: u64);

    #[storage(read)]
    fn burn_coins(burn_amount: u64);

    #[storage(read)]
    fn transfer_coins(coins: u64, address: Address);

    #[storage(read)]
    fn transfer_token_to_output(coins: u64, asset_id: ContractId, address: Address);

    #[storage(read, write)]
    fn mint();
}

abi BaconDistributor {
    #[storage(read, write)]
    fn constructor(bacon: ContractId, staking: ContractId);

    #[storage(read, write)]
    fn claim_fees(amount: u64);
}

impl Staking for Contract {
    #[storage(read, write)]
    fn constructor(pigs: ContractId, fee_token: ContractId, fee_distributor: ContractId, truffles: ContractId, fees_per_second: u64, truffles_per_second: u64) {
        require(fee_distributor == BASE_ASSET_ID, InitError::CannotReinitialize);
        require(pigs != BASE_ASSET_ID, InitError::PigsIsNone);
        require(fee_token != BASE_ASSET_ID, InitError::FeeTokenIsNone);
        require(fee_distributor != BASE_ASSET_ID, InitError::FeeDistributorIsNone);
        require(truffles != BASE_ASSET_ID, InitError::TrufflesIsNone);
        require(fees_per_second > 0, InitError::InvalidFeesPerSecond);
        require(truffles_per_second > 0, InitError::InvalidTrufflesPerSecond);

        storage.pigs                = Option::Some(pigs);
        storage.fee_token           = Option::Some(fee_token);
        storage.fee_distributor     = Option::Some(fee_distributor);
        storage.truffles            = Option::Some(truffles);
        storage.fees_per_second     = fees_per_second;
        storage.truffles_per_second = truffles_per_second;
    }

    #[storage(read)]
    fn pigs() -> ContractId {
        storage.pigs
    }

    #[storage(read)]
    fn fee_token() -> ContractId {
        storage.fee_token
    }

    fn fee_distributor() -> Identity {
        storage.fee_distributor
    }

    fn truffles() -> ContractId {
        storage.truffles
    }

    #[storage(read)]
    fn owner_of(pig: u64) -> Identity {
        storage.pig_owner.get(pig)
    }

    #[storage(read)]
    fn staked_pigs(user: Identity, index: u64) -> u64 {
        let all_pigs = storage.staked_pigs;
        require(index < all_pigs.len(), InputError::IndexExceedsArrayLength);
        all_pigs.get(index)
    }

    #[storage(read)]
    fn balance_of(user: Identity) -> u64 {
        storage.staked_pigs.get(user).len()
    }

    #[storage(read)]
    fn staking_power(user: Identity) -> u64 {
        storage.staking_power.get(user)
    }

    #[storage(read)]
    fn delegated_piglets(delegator: Identity, index: u64) -> u64 {
        let all_piglets = storage.delegated_piglets.get(delegator);
        require(index < all_piglets.len(), InputError::IndexExceedsArrayLength);
        all_piglets.get(index).unwrap()
    }

    #[storage(read)]
    fn delegate_balance_of(delegator: Identity) -> u64 {
        storage.delegated_piglets.get(delegator).len()
    }

    #[storage(read)]
    fn piglet_to_pig(piglet: u64) -> u64 {
        storage.piglet_to_pig.get(piglet)
    }

    #[storage(read)]
    fn fee_commission(pig: u64) -> u64 {
        storage.fee_commission
    }

    #[storage(read)]
    fn truffles_per_second() -> u64 {
        storage.truffles_per_second
    }

    #[storage(read)]
    fn accrued_truffles(pig: u64) -> u64 {
        
    }

    #[storage(read)]
    fn accrued_pig_fees(pig: u64) -> u64;

    #[storage(read)]
    fn accrued_piglet_fees(piglet: u64) -> u64;

    #[storage(read)]
    fn delegators(pig: u64) -> Vec<Identity>;

    #[storage(read, write)]
    fn delegate(delegator: Identity, pig: u64, piglets: [u64]);

    #[storage(read, write)]
    fn undelegate(delegator: Identity, pig: u64, piglets: [u64]);

    #[storage(read, write)]
    fn stake(pig: u64, user: Identity);

    #[storage(read, write)]
    fn unstake(pig: u64);

    #[storage(read, write)]
    fn claim_fees(pig: u64);

    #[storage(read, write)]
    fn set_fee_commission(pig: u64, commission: u64);
}
