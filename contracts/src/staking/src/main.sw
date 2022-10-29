contract;

dep errors;
dep interface;
dep constants;

use errors::*;
use interface::{Staking};
use constants::{ZERO, MAX_DELEGATORS};

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
    /// The piglet NFT contract address
    piglets: Option<ContractId> = Option::None,
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
    staking_power: StorageMap<u64, u64> = StorageMap {},
    /// The mapping of all piglet owners
    piglet_owner: StorageMap<u64, Identity> = StorageMap {},
    /// The piglets a user currently delegates
    delegated_piglets: StorageMap<Identity, Vec<u64>> = StorageMap {},
    /// The piglets delegated to each pig
    piglet_to_pig: StorageMap<u64, u64> = StorageMap {},
    /// The commission offered to delegators of a specific pig
    fee_commission: u64 = 0,
    /// Total amount of fees distributed per second to each staked pig
    fees_per_second: u64 = 0,
    /// Amount of new truffles that can be minted each second for a staked pig
    truffles_per_second: u64 = 0,
    /// The last timestamp when a pig staker claimed fees
    last_pig_fee_claim: StorageMap<u64, u64> = StorageMap {},
    /// The last timestamp when a pig staker minted accrued truffles
    last_pig_truffle_mint: StorageMap<u64, u64> = StorageMap {},
}

pub struct TokenMetaData {
    // This is left as an example. Support for dynamic length string is needed here
    name: str[7],
}

///////
// ABIs
///////
abi Pigs {
    #[storage(read)]
    fn admin() -> Identity;

    #[storage(read)]
    fn piglet_transformer() -> Identity;

    #[storage(read, write)]
    fn approve(approved: Identity, token_id: u64);

    #[storage(read)]
    fn approved(token_id: u64) -> Identity;

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64;

    #[storage(read)]
    fn pigs(owner: Identity, index: u64) -> u64;

    #[storage(read, write)]
    fn burn(token_id: u64);

    fn constructor(access_control: bool, admin: Identity, piglet_transformer: Identity, max_supply: u64, inflation_start_time: u64, inflation_rate: u64, inflation_epoch: u64);

    #[storage(read, write)]
    fn snapshot_supply();

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool;

    #[storage(read)]
    fn max_supply() -> u64;

    #[storage(read, write)]
    fn mint(amount: u64, to: Identity);

    #[storage(read)]
    fn meta_data(token_id: u64) -> TokenMetaData;

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    #[storage(read, write)]
    fn set_admin(admin: Identity);

    #[storage(read, write)]
    fn set_piglet_transformer(piglet_transformer: Identity);

    #[storage(read, write)]
    fn set_approval_for_all(approve: bool, operator: Identity);

    #[storage(read)]
    fn total_supply() -> u64;

    #[storage(read, write)]
    fn transfer_from(from: Identity, to: Identity, token_id: u64);
}

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
    fn constructor(staking_factory: ContractId, factory: ContractId, admin: Identity, piglet_minter: Identity, piglets_to_pigs_ratio: u64);

    #[storage(read, write)]
    fn delegate(pig: u64, piglets: Vec<u64>);

    #[storage(read, write)]
    fn remove_delegation(pig: u64, piglets: Vec<u64>);

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool;

    #[storage(read, write)]
    fn mint(amount: u64, to: Identity);

    #[storage(read, write)]
    fn mintPigs(piglets: Vec<u64>);

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    #[storage(read)]
    fn piglets_to_pigs_ratio() -> u64;

    #[storage(read)]
    fn piglets(owner: Identity) -> Vec<u64>;

    #[storage(read)]
    fn get_factory() -> ContractId;

    #[storage(read)]
    fn get_staking_factory() -> ContractId;

    #[storage(read)]
    fn piglet_minter() -> Identity;

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

///////////////////
// Internal Methods
///////////////////
/// Claim fees for the pig staker and users who delegated piglets to the target pig
#[storage(read, write)]
fn _claim_fees(pig: u64) {

}




impl Staking for Contract {
    #[storage(read, write)]
    fn constructor(pigs: ContractId, piglets: ContractId, fee_token: ContractId, fee_distributor: ContractId, truffles: ContractId, fees_per_second: u64, truffles_per_second: u64) {
        require(fee_distributor == BASE_ASSET_ID, InitError::CannotReinitialize);
        require(pigs != BASE_ASSET_ID, InitError::PigsIsNone);
        require(piglets != BASE_ASSET_ID, InitError::PigletsIsNone);
        require(fee_token != BASE_ASSET_ID, InitError::FeeTokenIsNone);
        require(fee_distributor != BASE_ASSET_ID, InitError::FeeDistributorIsNone);
        require(truffles != BASE_ASSET_ID, InitError::TrufflesIsNone);
        require(fees_per_second > 0, InitError::InvalidFeesPerSecond);
        require(truffles_per_second > 0, InitError::InvalidTrufflesPerSecond);

        storage.pigs                = Option::Some(pigs);
        storage.piglets             = Option::Some(piglets);
        storage.fee_token           = Option::Some(fee_token);
        storage.fee_distributor     = Option::Some(fee_distributor);
        storage.truffles            = Option::Some(truffles);
        storage.fees_per_second     = fees_per_second;
        storage.truffles_per_second = truffles_per_second;
    }

    #[storage(read)]
    fn pigs() -> ContractId {
        storage.pigs.unwrap()
    }

    #[storage(read)]
    fn piglets() -> ContractId {
        storage.piglets.unwrap()
    }

    #[storage(read)]
    fn fee_token() -> ContractId {
        storage.fee_token.unwrap()
    }

    fn fee_distributor() -> Identity {
        storage.fee_distributor.unwrap()
    }

    fn truffles() -> ContractId {
        storage.truffles.unwrap()
    }

    #[storage(read)]
    fn owner_of(pig: u64) -> Identity {
        storage.pig_owner.get(pig)
    }

    #[storage(read)]
    fn staked_pigs(user: Identity, index: u64) -> u64 {
        let all_pigs = storage.staked_pigs.get(user);
        require(index < all_pigs.len(), InputError::IndexExceedsArrayLength);
        all_pigs.get(index)
    }

    #[storage(read)]
    fn balance_of(user: Identity) -> u64 {
        let all_pigs = storage.staked_pigs.get(user);
        all_pigs.len()
    }

    #[storage(read)]
    fn staking_power(pig: u64) -> u64 {
        storage.staking_power.get(pig)
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
        //temp 
        return 1
    }

    #[storage(read)]
    fn accrued_pig_fees(pig: u64) -> u64 {
        //temp 
        return 1
    }

    #[storage(read)]
    fn accrued_piglet_fees(piglet: u64) -> u64{
        //temp 
        return 1
    }

    #[storage(read, write)]
    fn delegate(delegator: Identity, pig: u64, piglets: Vec<u64>) {
        let caller: Identity = msg_sender().unwrap();
        
        require(pig > ZERO, InputError::InvalidPig);
        require(piglets.len() > ZERO, InputError::NullArray);
        require(delegator != Identity::ContractId(contract_id()), InputError::CannotAssingToThisContract);
        require(caller == Identity::ContractId(storage.piglets.unwrap()), AccessControlError::CallerNotPigletContract);

        // Check if the target pig is in this contract
        let pigs_contract = abi(Pigs, storage.pig.unwrap().into());
        let piglet_contract = abi(Piglet, storage.piglets.unwrap().into());
        require(
            storage.pig_owner.get(pig) != Identity::ContractId(~ContractId::from(ZERO_B256)) &&
            storage.pig_owner.get(pig) != Identity::Address(~Address::from(ZERO_B256)) &&
            pigs_contract.owner_of(pig) == Identity::ContractId(contract_id()),
            InputError::PigProvidedNotStaked
        );

        _claim_fees(pig);
        storage.staking_power.insert(pig, storage.staking_power.get(pig) + piglets.len());

        let mut i: u64 = 0;
        while (i < piglets.len()) {
            require(piglet_contract.owner_of(piglets.get(i).unwrap()) != Identity::ContractId(contract_id()), InputError::PigletAlreadyDelegated);

            storage.piglet_owner.insert(piglets.get(i).unwrap(), delegator);
            storage.delegated_piglets.get(delegator).push(piglets.get(i).unwrap());
            storage.piglet_to_pig.insert(piglets.get(i).unwrap(), pig);

            piglet_contract.transfer_from(msg_sender().unwrap(), Identity::ContractId(~ContractId::from(contract_id())), piglets.get(i).unwrap());

            i += 1;
        }
    }

    #[storage(read, write)]
    fn undelegate(delegator: Identity, pig: u64, piglets: Vec<u64>) {
        let caller: Identity = msg_sender().unwrap();

        require(pig > ZERO, InputError::InvalidPig);
        require(piglets.len() > ZERO, InputError::NullArray);
        require(caller == Identity::ContractId(storage.piglets.unwrap()), AccessControlError::CallerNotPigletContract);

        let mut i: u64           = 0;
        let mut j: u64           = 0;
        let caller: Identity = msg_sender().unwrap();
        let piglet_contract  = abi(Piglet, storage.piglets.unwrap().into());

        _claim_fees(pig);
        storage.staking_power.insert(pig, storage.staking_power.get(pig) - piglets.len());

        while (i < piglets.len()) {
            require(storage.piglet_owner.get(piglets.get(i).unwrap()) == delegator, AccessControlError::CallerNotPigletOwner);

            storage.piglet_to_pig.insert(piglets.get(i).unwrap(), ZERO);
            while (j < storage.delegated_piglets.get(storage.piglet_owner.get(piglets.get(i).unwrap()))) {
                j += 1;
            }

            piglet_contract.transfer_from(Identity::ContractId(~ContractId::from(contract_id())), delegator, piglets.get(i).unwrap());

            j = 0;
            i += 1;
        }
    }

    #[storage(read, write)]
    fn stake(pig: u64, user: Identity) {
        require(pig > ZERO, InputError::InvalidPig);
    }

    #[storage(read, write)]
    fn unstake(pig: u64) {

    }

    #[storage(read, write)]
    fn claim_fees(pig: u64) {
        _claim_fees(pig);
    }

    #[storage(read, write)]
    fn set_fee_commission(pig: u64, commission: u64) {

    }
}
