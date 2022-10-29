library interface;

dep data_structures;

use data_structures::TokenMetaData;
use std::{
    identity::Identity,
    contract_id::ContractId,
    vec::Vec
};

abi PigletNFT {
    /// Returns the current admin for the contract.
    ///
    /// # Reverts
    ///
    /// * When the contract does not have an admin.
    #[storage(read)]
    fn admin() -> Identity;
    /// Gives approval to the `approved` user to transfer a specific token on another user's behalf.
    ///
    /// To revoke approval the approved user should be `None`.
    ///
    /// # Arguments
    ///
    /// * `approved` - The user which will be allowed to transfer the token on the owner's behalf.
    /// * `token_id` - The unique identifier of the token which the owner is giving approval for.
    ///
    /// # Reverts
    ///
    /// * When `token_id` does not map to an existing token.
    /// * When the sender is not the token's owner.
    #[storage(read, write)]
    fn approve(approved: Identity, token_id: u64);
    /// Returns the user which is approved to transfer the given token.
    ///
    /// If there is no approved user or the unique identifier does not map to an existing token,
    /// the function will return `None`.
    ///
    /// # Arguments
    ///
    /// * `token_id` - The unique identifier of the token which the approved user should be returned.
    ///
    /// # Reverts
    ///
    /// * When there is no approved for the `token_id`.
    #[storage(read)]
    fn approved(token_id: u64) -> Identity;
    /// Returns the balance of the `owner` user.
    ///
    /// # Arguments
    ///
    /// * `owner` - The user of which the balance should be returned.
    #[storage(read)]
    fn balance_of(owner: Identity) -> u64;
    /// Burns the specified token.
    ///
    /// When burned, the metadata of the token is removed. After the token has been burned, no one
    /// will be able to fetch any data about this token or have control over it.
    ///
    /// # Arguments
    ///
    /// * `token_id` - The unique identifier of the token which is to be burned.
    ///
    /// * Reverts
    ///
    /// * When `token_id` does not map to an existing token.
    /// * When sender is not the owner of the token.
    #[storage(read, write)]
    fn burn(token_id: u64);
    /// Sets the inital state and unlocks the functionality for the rest of the contract.
    ///
    /// This function can only be called once.
    ///
    /// # Arguments
    ///
    /// * `factory` - The original contract that generates this contract
    /// * `admin` - The user which is admin
    /// * `piglet_minter` - The contract that has the ability to mint new piglet NFTs if the `admin` is null.
    /// * `piglets_to_pigs_ratio` - the ratio at which X piglets will convert into a pig
    ///
    /// # Reverts
    ///
    /// * When the constructor function has already been called.
    /// * When the `token_supply` is set to 0.
    #[storage(read, write)]
    fn constructor(staking_factory: ContractId, factory: ContractId, admin: Identity, piglet_minter: Identity, piglets_to_pigs_ratio: u64);
    /// Delegate the piglets of sender to a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig NFT where the Piglets will be delegated to
    /// * `piglets` - The Piglets which will be delegated
    ///
    /// # Reverts
    ///
    /// * When pig is not staked
    /// * When piglets are not owned by sender
    #[storage(read, write)]
    fn delegate(pig: u64, piglets: Vec<u64>);
    /// Removes the piglets delegation from pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The Pig which will have the piglets undelegated
    /// * `piglets` - The Piglets which will be undelegated
    ///
    /// # Reverts
    ///
    /// * When pig is not staked
    /// * When Staking contract fails
    #[storage(read, write)]
    fn remove_delegation(pig: u64, piglets: Vec<u64>);
    /// Returns whether the `operator` user is approved to transfer all tokens on the `owner`
    /// user's behalf.
    ///
    /// # Arguments
    ///
    /// * `operator` - The user which has recieved approval to transfer all tokens on the `owner`s behalf.
    /// * `owner` - The user which has given approval to transfer all tokens to the `operator`.
    #[storage(read)]
    fn is_approved_for_all(operator: Identity, owner: Identity) -> bool;
    /// Mints `amount` number of tokens to the `to` `Identity`.
    ///
    /// Once a token has been minted, it can be transfered and burned.
    ///
    /// # Arguments
    ///
    /// * `amount` - The number of tokens to be minted in this transaction.
    /// * `to` - The user which will own the minted tokens.
    ///
    /// # Reverts
    ///
    /// * When the minter is is not the trufflers Identity.
    #[storage(read, write)]
    fn mint(amount: u64, to: Identity);
    
    /// Mints Pigs based on the amount of piglets given
    /// Once a Pig token has been minted, it gets transfered to the sender and piglets get burned
    ///
    /// # Arguments
    ///
    /// * `piglets` - The Piglets that will be transformed into Pigs
    ///
    /// # Reverts
    ///
    /// * When one of the piglets sent is invalid token_id
    /// * When the minter does not own all the piglets at `piglets`
    /// * When the minter does not have enough Piglets to mint at least 1 Pig
    /// * When the Pig Contract fails
    #[storage(read, write)]
    fn mintPigs(piglets: Vec<u64>);

    /// Returns the user which owns the specified token.
    ///
    /// # Arguments
    ///
    /// * `token_id` - The unique identifier of the token.
    ///
    /// # Reverts
    ///
    /// * When there is no owner for the `token_id`.
    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    // Return the piglets_to_pigs_ratio
    #[storage(read)]
    fn piglets_to_pigs_ratio() -> u64;
    /// Returns the whole array of piglets that a user holds.
    ///
    /// # Arguments
    ///
    /// * `owner` - The owner for which we return the whole array of piglets they currently hold
    #[storage(read)]
    fn piglets(owner: Identity) -> Vec<u64>;

    /// Returns the factory contract.
    #[storage(read)]
    fn get_factory() -> ContractId;

    /// Returns the staking factory contract.
    #[storage(read)]
    fn get_staking_factory() -> ContractId;

    /// Returns the piglet minter for the contract.
    #[storage(read)]
    fn piglet_minter() -> Identity;
    /// Changes the contract's admin.
    ///
    /// # Arguments
    ///
    /// * `admin` - The user which is to be set as the new admin.
    ///
    /// # Reverts
    ///
    /// * When the sender is not the `admin` in storage.
    #[storage(read, write)]
    fn set_admin(admin: Identity);
    /// Changes the contract's piglet minter.
    ///
    /// This new piglet minter will have access to minting if `admin` is null.
    ///
    /// # Arguments
    ///
    /// * `piglet_minter` - The user which can transform trufflers currency into piglet NFTs.
    ///
    /// # Reverts
    ///
    /// * When the sender is not the `admin` or the current `piglet_minter` in storage.
    #[storage(read, write)]
    fn set_piglet_minter(piglet_minter: Identity);
    /// Gives the `operator` user approval to transfer ALL tokens owned by the `owner` user.
    ///
    /// This can be dangerous. If a malicous user is set as an operator to another user, they could
    /// drain their wallet.
    ///
    /// # Arguments
    ///
    /// * `approve` - Represents whether the user is giving or revoking operator status.
    /// * `operator` - The user which may transfer all tokens on the owner's behalf.
    #[storage(read, write)]
    fn set_approval_for_all(approve: bool, operator: Identity);
    /// Returns the total supply of tokens which are currently in existence.
    #[storage(read)]
    fn total_supply() -> u64;
    /// Transfers ownership of the specified token from one user to another.
    ///
    /// Transfers can occur under one of three conditions:
    /// 1. The token's owner is transfering the token.
    /// 2. The token's approved user is transfering the token.
    /// 3. The token's owner has a user set as an operator and is transfering the token.
    ///
    /// # Arguments
    ///
    /// * `from` - The user which currently owns the token to be transfered.
    /// * `to` - The user which the ownership of the token should be set to.
    /// * `token_id` - The unique identifier of the token which should be transfered.
    ///
    /// # Reverts
    ///
    /// * When the `token_id` does not map to an existing token.
    /// * When the sender is not the owner of the token.
    /// * When the sender is not approved to transfer the token on the owner's behalf.
    /// * When the sender is not approved to transfer all tokens on the owner's behalf.
    #[storage(read, write)]
    fn transfer_from(from: Identity, to: Identity, token_id: u64);

    /// Returns the current piglet minter for the contract.
    ///
    /// # Reverts
    ///
    /// * When the contract does not have a piglet minter.
    #[storage(read)]
    fn piglet_minter() -> Identity;
}
