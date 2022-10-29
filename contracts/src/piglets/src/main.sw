contract;

dep errors;
dep constants;
dep interface;
dep data_structures;

use data_structures::TokenMetaData;
use errors::{AccessError, InitError, InputError};
use constants::{};
use interface::{PigletNFT};
use factory_interface::{NFT};
use std::{
    chain::auth::msg_sender,
    identity::Identity,
    option::Option,
    contract_id::ContractId,
    revert::{require},
    storage::StorageMap,
    constants::{BASE_ASSET_ID}
};

storage {
    admin: Option<Identity> = Option::None,
    pig_contract: Option<Identity> = Option::None,
    factory: ContractId = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000)
    approved: StorageMap<u64, Option<Identity>> = StorageMap {},
    balances: StorageMap<Identity, u64> = StorageMap {},
    meta_data: StorageMap<u64, TokenMetaData> = StorageMap {},
    operator_approval: StorageMap<(Identity, Identity), bool> = StorageMap {},
    owners: StorageMap<u64, Option<Identity>> = StorageMap {},
    total_supply: u64 = 0,
    tokens_minted: u64 = 0,
    piglets_to_pigs_ratio: u64 = 0,
    // not recomended in prod lol stefan fault im just copy pasta peasant
    piglets: StorageMap<Identity, Vec<u64>> = StorageMap {}, 
}

///////////////////
// Internal Methods
///////////////////
#[storage(read, write)]
fn add_piglet_to_owner_map(owner: Identity, piglet_id: u64) {
    storage.piglets.get(owner).push(piglet_id);
    storage.balances.insert(owner, storage.balances.get(to) + 1);
    
}

#[storage(read, write)]
fn remove_piglet_from_owner_map(owner: Identity, piglet_id: u64) {
    let i: u64 = 0;
    let owned_piglets: Vec<u64> = storage.piglets.get(owner);

    while (i < owned_piglets.len()) {
        if (owned_piglets.get(i).unwrap() == piglet_id) {
            storage.pigs.get(owner).remove(i);
            storage.balances.insert(owner, storage.balances.get(from) - 1);
            break;
        }
    }
}

impl PigletNFT for Contract {
    #[storage(read, write)]
    fn constructor(factory: ContractId, admin: Identity, piglet_minter: Identity) {
        let admin         = Option::Some(admin);
        let piglet_minter = Option::Some(piglet_minter);

        require(storage.piglet_minter, InitError::CannotReinitialize);
        require(factory != BASE_ASSET_ID, ParamError::InvalidFactory);
        require(admin.is_some(), InitError::AdminIsNone);
        require(piglet_minter.is_some(), InitError::PigletMinterIsNone);

        storage.admin                   = admin;
        storage.pig_contract            = pig_contract;
        storage.piglet_minter           = piglet_minter;
        storage.piglets_to_pigs_ratio   = piglets_to_pigs_ratio;
    }

    /// GETS
    #[storage(read)]
    fn admin() -> Identity {
        let admin = storage.admin;
        require(admin.is_some(), InputError::AdminDoesNotExist);
        return admin.unwrap();
    }
    
    #[storage(read)]
    fn approved(token_id: u64) -> Identity {
        let approved = storage.approved.get(token_id);
        require(approved.is_some(), InputError::ApprovedDoesNotExist);
        return approved.unwrap();
    }
   
    #[storage(read)]
    fn balance_of(owner: Identity) -> u64 {
        return storage.balances.get(owner);
    }

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool {
        return storage.operator_approval.get((owner, operator, ));
    }

    #[storage(read)]
    fn meta_data(token_id: u64) -> TokenMetaData {
        let token_metadata = storage.meta_data.get(token_id)
        require(token_metadata.is_some(), InputError::TokenDoesNotExist);
        return token_metadata;
    }

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity {
        let owner = storage.owners.get(token_id);
        require(owner.is_some(), InputError::OwnerDoesNotExist);
        return owner.unwrap();
    }

    #[storage(read)]
    fn piglets_to_pigs_ratio() -> u64 {
        return storage.piglets_to_pigs_ratio;
    }

    #[storage(read)]
    fn piglet_minter() -> Identity {
        return storage.piglet_minter;
    }

    #[storage(read)]
    fn get_factory() -> ContractId {
        storage.factory
    }

    #[storage(read)]
    fn piglets(owner: Identity) -> Vec<u64> {
        storage.piglets.get(owner);
    }
    
    #[storage(read)]
    fn total_supply() -> u64 {
        return storage.total_supply;
    }
    /// END GETS


    /// SETS
    #[storage(read, write)]
    fn set_admin(admin: Identity) {
        let current_admin = storage.admin;
        require(current_admin.is_some() && msg_sender().unwrap() == current_admin.unwrap(), AccessError::SenderCannotSetAccessControl);
        storage.admin = Option::Some(admin);
    }

    #[storage(read, write)]
    fn set_piglet_minter(piglet_minter: Identity) {
        let current_admin = storage.admin;
        require(current_admin.is_some() && msg_sender().unwrap() == current_admin.unwrap(), AccessError::SenderCannotSetPigletMinter);
        storage.piglet_minter = Option::Some(piglet_minter);
    }

    #[storage(read, write)]
    fn set_approval_for_all(approve: bool, operator: Identity) {
        // Store `approve` with the (sender, operator) tuple
        let sender = msg_sender().unwrap();
        storage.operator_approval.insert((sender, operator, ), approve);
    }
    /// END SETS


    /// ACTIONS
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

    #[storage(read, write)]
    fn burn(token_id: u64) {
        // Ensure this is a valid token
        let token_owner = storage.owners.get(token_id);
        require(token_owner.is_some(), InputError::TokenDoesNotExist);

        // Ensure the sender owns the token that is provided
        let sender = msg_sender().unwrap();
        require(token_owner.unwrap() == sender, AccessError::SenderNotOwner);

        storage.owners.insert(token_id, Option::None());
        remove_piglet_from_owner_map(sender, token_id);
        storage.total_supply -= 1;
    }
    
    #[storage(read, write)]
    fn delegate(pig: u64, piglets: [u64]) {
        
    }

    #[storage(read, write)]
    fn remove_delegation(pig: u64, piglets: [u64]) {
        
    }

    #[storage(read, write)]
    fn mint(amount: u64, to: Identity) {
        let sender = msg_sender().unwrap();
        require(storage.piglet_minter == sender, AccessError::SenderNotPigletMinter);

        let mut index = tokens_minted;
        let total_minted_after_execution = tokens_minted + amount;
        while index < total_minted_after_execution {
            // Create the TokenMetaData for this new token
            storage.meta_data.insert(index, ~TokenMetaData::new());
            storage.owners.insert(index, Option::Some(to));
            add_piglet_to_owner_map(to, index);
            index += 1;
        }

        storage.tokens_minted = total_minted_after_execution;
        storage.total_supply += amount;
    }

    #[storage(read, write)]
    fn mintPigs(piglets: [u64]) {
        let sender = msg_sender().unwrap();

        // validate pigslets len > 1
        require(piglets.len() > 0, InputError::InvalidTokenSize);
        
        // validate if piglets >= piglets_to_pig_conversation 
        require(piglets.len() > storage.piglets_to_pigs_ratio, InputError::NotEnoughPiglets)
        
        // validate if piglets len is a common divisor of piglets_to_pigs_ratio
        require(piglets.len() % storage.piglets_to_pigs_ratio == 0, InputError::InvalidNumberOfPiglets)
        
        // validate if all piglets exists + if piglet belongs to sender
        let mut index = 0;
        while index < piglets.len() {
            token_id = piglets[index];
            let token_owner = storage.owners.get(token_id);
            require(token_owner.is_some(), InputError::TokenDoesNotExist);
            require(token_owner == sender, InputError::SenderNotOwner);
            index += 1;
        }

        let pigs_to_mint = piglets.len()/storage.piglets_to_pigs_ratio;
        
        let factory_id: b256  = storage.factory.into();
        let factory_contract  = abi(NFT, factory_id);
        factory_contract.mint(pigs_to_mint, sender)
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

        add_piglet_to_owner_map(to, token_id);
        remove_piglet_from_owner_map(from, token_id);
    }
    /// END ACTIONS
}