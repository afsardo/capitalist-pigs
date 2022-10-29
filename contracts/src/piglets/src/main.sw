contract;

dep errors;
dep constants;
dep interface;
dep data_structures;

use data_structures::TokenMetaData;
use errors::{AccessError, InitError, InputError};
use constants::{};
use interface::{PigletNFT};
use std::{
    chain::auth::msg_sender,
    identity::Identity,
    contract_id::ContractId,
    logging::log,
    option::Option,
    result::Result,
    revert::{require, revert},
    storage::StorageMap,
    block::timestamp,
    constants::{ZERO_B256, BASE_ASSET_ID}
};

storage {
    admin: Option<Identity> = Option::None,
    piglet_minter: Option<Identity> = Option::None,
    approved: StorageMap<u64, Option<Identity>> = StorageMap {},
    balances: StorageMap<Identity, u64> = StorageMap {},
    meta_data: StorageMap<u64, TokenMetaData> = StorageMap {},
    operator_approval: StorageMap<(Identity, Identity), bool> = StorageMap {},
    owners: StorageMap<u64, Option<Identity>> = StorageMap {},
    total_supply: u64 = 0,
}

impl PigletNFT for Contract {
    #[storage(read, write)]
    fn constructor(admin: Identity, piglet_minter: Identity) {
        let admin         = Option::Some(admin);
        let piglet_minter = Option::Some(piglet_minter);
        
        require(storage.piglet_minter, InitError::CannotReinitialize);
        require(admin.is_some(), InitError::AdminIsNone);
        require(piglet_minter.is_some(), InitError::PigletMinterIsNone);

        storage.admin           = admin;
        storage.piglet_minter   = piglet_minter;
    }

    /// GETS
    #[storage(read)]
    fn admin() -> Identity {
        let admin = storage.admin;
        require(admin.is_some(), InputError::AdminDoesNotExist);
        return admin.unwrap()
    }
    
    #[storage(read)]
    fn total_supply() -> u64 {
        return storage.total_supply
    }

    #[storage(read)]
    fn piglet_minter() -> Identity {
        return storage.piglet_minter
    }

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64 {
        return storage.balances.get(owner)
    }

    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool {
        return storage.operator_approval.get((owner, operator, ))
    }

    #[storage(read)]
    fn meta_data(token_id: u64) -> TokenMetaData {
        let token_metadata = storage.meta_data.get(token_id)
        require(token_metadata.is_some(), InputError::TokenDoesNotExist);
        return token_metadata
    }

    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity {
        let owner = storage.owners.get(token_id);
        require(owner.is_some(), InputError::OwnerDoesNotExist);
        return owner.unwrap()
    }

    #[storage(read)]
    fn approved(token_id: u64) -> Identity {
        let approved = storage.approved.get(token_id);
        require(approved.is_some(), InputError::ApprovedDoesNotExist);
        return approved.unwrap()
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
        storage.balances.insert(sender, storage.balances.get(sender) - 1);
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
        require(storage.piglet_minter == sender, AccessError::SenderNotOwner);

        // TODO create Nfts
    }

    #[storage(read, write)]
    fn mintPigs(piglets: [u64]) -> [u64] {
        
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

        storage.balances.insert(from, storage.balances.get(from) - 1);
        storage.balances.insert(to, storage.balances.get(to) + 1);
    }
    /// END ACTIONS
 
}