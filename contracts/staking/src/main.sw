contract;

dep errors;
dep interface;
dep constants;

use errors::*;
use interface::{Staking};
use constants::{ZERO, ONE, HUNDRED, MAX_DELEGATED_PIGLETS};

use std::{
    context::{
        *,
        call_frames::*,
    },
    chain::auth::*,
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
    fee_distributor: Option<ContractId> = Option::None,
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
    /// All piglets delegated to a pig
    delegated_piglets_to_pig: StorageMap<u64, Vec<u64>> = StorageMap {},
    /// The commission offered to delegators of a specific pig
    fee_commission: StorageMap<u64, u64> = StorageMap {},
    /// Total amount of fees distributed per second to each staked pig
    fees_per_second: u64 = ZERO,
    /// Amount of new truffles that can be minted each second for a staked pig
    truffles_per_second: u64 = ZERO,
    /// The last timestamp when a pig staker claimed fees
    last_pig_fee_claim: StorageMap<u64, u64> = StorageMap {},
    /// The last timestamp when a pig staker minted accrued truffles
    last_pig_truffle_mint: StorageMap<u64, u64> = StorageMap {},
}

//////////////////
// Data Structures
//////////////////
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
    fn claim_fees(receiver: Identity, amount: u64);
}

///////////////////
// Internal Methods
///////////////////
/// Calculate and return the accrued fees for a staked pig
#[storage(read)]
fn _accrued_pig_fees(pig: u64) -> u64 {
    let pigs_contract = abi(Pigs, storage.pigs.unwrap().into());
    require(
        storage.pig_owner.get(pig) != Identity::ContractId(~ContractId::from(ZERO_B256)) &&
        storage.pig_owner.get(pig) != Identity::Address(~Address::from(ZERO_B256)) &&
        pigs_contract.owner_of(pig) == Identity::ContractId(contract_id()),
        InputError::PigProvidedNotStaked
    );

    let last_pig_fee_claim: u64 = storage.last_pig_fee_claim.get(pig);
    if (pig == ZERO || storage.fees_per_second == ZERO || last_pig_fee_claim == timestamp() || last_pig_fee_claim == ZERO) {
        ZERO
    } else {
        let remaining_fee_for_staker: u64 = HUNDRED - storage.fee_commission.get(pig);
        ((timestamp() - last_pig_fee_claim) * storage.fees_per_second * (storage.staking_power.get(pig) + ONE)) * remaining_fee_for_staker / HUNDRED
    }
}

/// Calculate and return the accrued fees for a delegated piglet
#[storage(read)]
fn _accrued_piglet_fees(pig: u64) -> u64 {
    let pig_fees: u64 = _accrued_pig_fees(pig);
    if (pig_fees == ZERO) {
        ZERO
    } else {
        let all_fees: u64 = ((timestamp() - storage.last_pig_fee_claim.get(pig)) * storage.fees_per_second * (storage.staking_power.get(pig) + ONE));
        all_fees - pig_fees
    }
}

/// Calculate and return the accrued fees for a delegated piglet using precalculated pig fees
#[storage(read)]
fn _accrued_piglet_fees_using_pig_fees(pig: u64, pig_fees: u64) -> u64 {
    if (pig_fees == ZERO) {
        ZERO
    } else {
        let all_fees: u64 = ((timestamp() - storage.last_pig_fee_claim.get(pig)) * storage.fees_per_second * (storage.staking_power.get(pig) + ONE));
        all_fees - pig_fees
    }
}

/// Claim fees for the pig staker and users who delegated piglets to the staked pig
#[storage(read, write)]
fn _claim_fees(pig: u64) {
    let pig_staker_fees: u64         = _accrued_pig_fees(pig);

    if (pig_staker_fees > ZERO) {
        let fee_distributor_contract = abi(BaconDistributor, storage.fee_distributor.unwrap().into());
        fee_distributor_contract.claim_fees(storage.pig_owner.get(pig), pig_staker_fees);

        let mut j: u64                 = 0;
        let mut total_piglet_fees: u64 = _accrued_piglet_fees_using_pig_fees(pig, pig_staker_fees);
        let delegated_piglets_to_pig   = storage.delegated_piglets_to_pig.get(pig);
        let fee_per_piglet: u64        = total_piglet_fees / delegated_piglets_to_pig.len();

        while (j < delegated_piglets_to_pig.len()) {
            if (j == delegated_piglets_to_pig.len() - 1) {
                fee_distributor_contract.claim_fees(storage.piglet_owner.get(delegated_piglets_to_pig.get(j).unwrap()), total_piglet_fees);
            } else {
                if (fee_per_piglet > 0) {
                  fee_distributor_contract.claim_fees(storage.piglet_owner.get(delegated_piglets_to_pig.get(j).unwrap()), fee_per_piglet);
                }

                total_piglet_fees -= fee_per_piglet;
            }

            j += 1;
        }
    }
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
        require(fees_per_second > ZERO, InitError::InvalidFeesPerSecond);
        require(truffles_per_second > ZERO, InitError::InvalidTrufflesPerSecond);

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

    #[storage(read)]
    fn fee_distributor() -> ContractId {
        storage.fee_distributor.unwrap()
    }

    #[storage(read)]
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
        all_pigs.get(index).unwrap()
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
    fn delegated_piglets_to_pig(pig: u64, index: u64) -> u64 {
        let all_piglets = storage.delegated_piglets_to_pig.get(pig);
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
        storage.fee_commission.get(pig)
    }

    #[storage(read)]
    fn truffles_per_second() -> u64 {
        storage.truffles_per_second
    }

    #[storage(read)]
    fn accrued_truffles(pig: u64) -> u64 {
        let pigs_contract = abi(Pigs, storage.pigs.unwrap().into());
        require(
            storage.pig_owner.get(pig) != Identity::ContractId(~ContractId::from(ZERO_B256)) &&
            storage.pig_owner.get(pig) != Identity::Address(~Address::from(ZERO_B256)) &&
            pigs_contract.owner_of(pig) == Identity::ContractId(contract_id()),
            InputError::PigProvidedNotStaked
        );

        let last_pig_truffle_mint: u64 = storage.last_pig_truffle_mint.get(pig);
        if (pig == ZERO || storage.truffles_per_second == ZERO || last_pig_truffle_mint == timestamp() || last_pig_truffle_mint == ZERO) {
            ZERO
        } else {
            (timestamp() - last_pig_truffle_mint) * storage.truffles_per_second
        }
    }

    #[storage(read)]
    fn accrued_pig_fees(pig: u64) -> u64 {
        _accrued_pig_fees(pig)
    }

    #[storage(read)]
    fn accrued_piglet_fees(pig: u64) -> u64 {
        _accrued_piglet_fees(pig)
    }

    #[storage(read, write)]
    fn delegate(delegator: Identity, pig: u64, piglets: Vec<u64>) {
        let caller: Identity = msg_sender().unwrap();

        require(pig > ZERO, InputError::InvalidPig);
        require(piglets.len() > ZERO, InputError::NullArray);
        require(delegator != Identity::ContractId(contract_id()), InputError::CannotAssingToThisContract);
        require(caller == Identity::ContractId(storage.piglets.unwrap()), AccessControlError::CallerNotPigletContract);
        require(storage.delegated_piglets_to_pig.get(pig).len() < MAX_DELEGATED_PIGLETS, DelegationError::ExceedsDelegationLimit);

        // Check if the target pig is in this contract
        let pigs_contract = abi(Pigs, storage.pigs.unwrap().into());
        let piglet_contract = abi(Piglet, storage.piglets.unwrap().into());
        require(
            storage.pig_owner.get(pig) != Identity::ContractId(~ContractId::from(ZERO_B256)) &&
            storage.pig_owner.get(pig) != Identity::Address(~Address::from(ZERO_B256)) &&
            pigs_contract.owner_of(pig) == Identity::ContractId(contract_id()),
            InputError::PigProvidedNotStaked
        );

        _claim_fees(pig);
        storage.staking_power.insert(pig, storage.staking_power.get(pig) + piglets.len());

        let mut i: u64 = ZERO;
        while (i < piglets.len()) {
            require(piglet_contract.owner_of(piglets.get(i).unwrap()) != Identity::ContractId(contract_id()), InputError::PigletAlreadyDelegated);

            storage.piglet_owner.insert(piglets.get(i).unwrap(), delegator);
            storage.delegated_piglets.get(delegator).push(piglets.get(i).unwrap());
            storage.piglet_to_pig.insert(piglets.get(i).unwrap(), pig);
            storage.delegated_piglets_to_pig.get(pig).push(piglets.get(i).unwrap());

            piglet_contract.transfer_from(delegator, Identity::ContractId(contract_id()), piglets.get(i).unwrap());

            i += ONE;
        }
    }

    #[storage(read, write)]
    fn undelegate(delegator: Identity, pig: u64, piglets: Vec<u64>) {
        let caller: Identity = msg_sender().unwrap();

        require(pig > ZERO, InputError::InvalidPig);
        require(piglets.len() > ZERO, InputError::NullArray);
        require(caller == Identity::ContractId(storage.piglets.unwrap()), AccessControlError::CallerNotPigletContract);

        let mut i: u64       = ZERO;
        let mut j: u64       = ZERO;
        let caller: Identity = msg_sender().unwrap();
        let piglet_contract  = abi(Piglet, storage.piglets.unwrap().into());

        _claim_fees(pig);
        storage.staking_power.insert(pig, storage.staking_power.get(pig) - piglets.len());

        while (i < piglets.len()) {
            require(storage.piglet_owner.get(piglets.get(i).unwrap()) == delegator, AccessControlError::CallerNotPigletOwner);

            storage.piglet_to_pig.insert(piglets.get(i).unwrap(), ZERO);

            let delegated_piglets = storage.delegated_piglets.get(storage.piglet_owner.get(piglets.get(i).unwrap()));
            while (j < delegated_piglets.len()) {
                if (delegated_piglets.get(j).unwrap() == piglets.get(i).unwrap()) {
                    storage.delegated_piglets.get(storage.piglet_owner.get(piglets.get(i).unwrap())).remove(j);
                    break;
                }
                j += ONE;
            }

            j = ZERO;
            let delegated_piglets_to_pig = storage.delegated_piglets_to_pig.get(pig);
            while (j < delegated_piglets_to_pig.len()) {
                if (delegated_piglets_to_pig.get(j).unwrap() == piglets.get(i).unwrap()) {
                    storage.delegated_piglets_to_pig.get(pig).remove(j);
                    break;
                }
                j += ONE;
            }

            piglet_contract.transfer_from(Identity::ContractId(contract_id()), delegator, piglets.get(i).unwrap());

            j = ZERO;
            i += ONE;
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
        let caller: Identity = msg_sender().unwrap();

        require(storage.pig_owner.get(pig) == caller, AccessControlError::SenderNotPigOwner);
        require(commission < HUNDRED, InputError::InvalidComissionValue);

        storage.fee_commission.insert(pig, commission);
    }
}
