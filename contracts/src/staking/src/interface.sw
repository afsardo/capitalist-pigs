library interface;

use std::{identity::Identity, vec::Vec};

abi Staking {
    /// Returns the address of the Pig NFT contract.
    #[storage(read)]
    fn pigs() -> Identity;

    /// Returns the address of the fee token offered for staking.
    #[storage(read)]
    fn fee_token() -> Identity;

    /// Returns the address of the contract that delegates piglets to staked pigs.
    #[storage(read)]
    fn piglet_delegator() -> Identity;

    /// Returns the address of the Truffes token contract.
    fn truffles() -> Identity;

    /// Returns the address of the user that has a specific NFT staked.
    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    /// Returns the balance of the `staker` user.
    ///
    /// # Arguments
    ///
    /// * `staker` - The user of which the staked balance should be returned.
    #[storage(read)]
    fn balance_of(owner: Identity) -> u64;

    /// Return the staking power of a staker.
    ///
    /// # Arguments
    ///
    /// * `user` - The staker whose staking power we return.
    #[storage(read)]
    fn staking_power(user: Identity) -> u64;

    /// Returns the owner of a staked NFT.
    ///
    /// # Arguments
    ///
    /// * `token_id` - The id of the token whose owner we want to return.
    #[storage(read)]
    fn owner_of(token_id: u64) -> Identity;

    /// Returns the amount of piglets that a user delegated to a pig
    ///
    /// # Arguments
    ///
    /// * `delegatee` - The user that delegated piglets
    /// * `pig` - The pig to which the user delegated piglets
    fn delegate_balance_of(delegatee: Identity, pig: u64) -> u64;

    /// Returns the user that delegated a piglet
    ///
    /// # Arguments
    //
    /// * `piglet` - The piglet for which we return the owner/delegatee
    fn delegate_owner_of(piglet: u64) -> Identity;

    /// Returns the pig to which a piglet is delegated
    ///
    /// # Arguments
    ///
    /// * `piglet` - The piglet for which we return the pig to which it got delegated
    fn piglet_to_pig(piglet: u64) -> u64;

    /// Return the commission offered to delegatees of a specific pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the commission
    fn fee_commission(pig: u64) -> u64;

    /// Returns the total amount of piglets delegated to a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the total delegated piglets
    fn total_delegated(pig: u64)  -> u64;

    /// Return the delegatees of a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return all delegatees
    fn delegatees(pig: u64) -> Vec<Identity>;

    /// Delegate piglets to a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to delegate piglets to
    /// * `piglets` - The piglets that are delegated to the `pig`
    fn delegate(pig: u64, piglets: [u64]);

    /// Undelegate piglets from a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to undelegate piglets to
    /// * `piglets` - The piglets that are undelegated from the `pig`
    fn undelegate(pig: u64, piglets: [u64]);

    /// Stake a pig in the contract
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to stake
    /// * `staker` - The user that will receive the pig inside the staking contract
    fn stake(pig: u64, staker: Identity);

    /// Unstake a pig from the contract
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to unstake
    fn unstake(pig: u64);

    /// Claim fees (for the pig staker and the delegates of that pig)
    ///
    /// * `pig` - The pig from which to claim accrued fees
    fn claim_fees(pig: u64);

    /// Set the commission offered to piglet delegatees
    ///
    /// * `pig` - The pig from which to set the commission
    /// * `commission` - The commission offered to piglet delegatees
    fn set_fee_commission(pig: u64, commission: u64);
}
