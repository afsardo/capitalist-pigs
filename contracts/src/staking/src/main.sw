contract;

dep errors;
dep interface;
dep constants;

use interface::{Staking};
use constants::{MAX_DELEGATEES};
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
    pigs: Identity;
    /// The fee token contract address
    fee_token: Identity;
    /// The fee distributor contract
    fee_distributor: Identity;
    /// The address of the truffles token contract
    truffles: Identity;
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
    total_fees_per_second: u64 = 0
    /// The last timestamp when a pig staker claimed fees
    last_pig_fee_claim: StorageMap<u64, u64> = StorageMap {}
};
