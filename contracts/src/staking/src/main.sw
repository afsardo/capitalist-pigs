contract;

dep errors;
dep interface;
dep constants;

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
    pigs: Option<Identity> = Option::None,
    /// The fee token contract address
    fee_token: Option<Identity> = Option::None,
    /// The fee distributor contract
    fee_distributor: Option<Identity> = Option::None,
    /// The address of the truffles token contract
    truffles: Option<Identity> = Option::None,
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

///////////////////
// Internal Methods
///////////////////

impl Staking for Contract {
    #[storage(read, write)]
    fn constructor(pigs: Identity, fee_token: Identity, fee_distributor: Identity, truffles: Identity, fees_per_second: u64, truffles_per_second: u64) {

    }

    #[storage(read)]
    fn pigs() -> Identity;

    #[storage(read)]
    fn fee_token() -> Identity;

    fn fee_distributor() -> Identity;

    fn truffles() -> Identity;

    #[storage(read)]
    fn owner_of(pig: u64) -> Identity;

    fn staked_pigs(user: Identity) -> Vec<u64>;

    #[storage(read)]
    fn balance_of(user: Identity) -> u64;

    #[storage(read)]
    fn staking_power(user: Identity) -> u64;

    fn delegate_balance_of(delegator: Identity, pig: u64) -> u64;

    fn delegate_owner_of(piglet: u64) -> Identity;

    fn delegated_piglets(user: Identity) -> Vec<u64>;

    fn piglet_to_pig(piglet: u64) -> u64;

    fn fee_commission(pig: u64) -> u64;

    fn truffles_per_second() -> u64;

    fn accrued_truffles(pig: u64) -> u64;

    fn accrued_pig_fees(pig: u64) -> u64;

    fn accrued_piglet_fees(piglet: u64) -> u64;

    fn delegators(pig: u64) -> Vec<Identity>;

    fn delegate(delegator: Identity, pig: u64, piglets: [u64]);

    fn undelegate(delegator: Identity, pig: u64, piglets: [u64]);

    fn stake(pig: u64, user: Identity);

    fn unstake(pig: u64);

    fn claim_fees(pig: u64);

    fn set_fee_commission(pig: u64, commission: u64);
}
