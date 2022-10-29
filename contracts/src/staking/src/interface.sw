library interface;

use std::{identity::Identity, vec::Vec};

abi Staking {
    /// Initialize the contract
    ///
    /// # Arguments
    ///
    /// * `pigs` - The pig NFT contract address
    /// * `fee_token` - The address of the fee token contract
    /// * `fee_distributor` - The address of the fee distributor contract
    /// * `truffles` - The address of the truffles contract
    /// * `fees_per_second` - The amount of fees sent accruing to each staked pig every second
    /// * `truffles_per_second` - The amount of truffles minted per second for each staked pig
    #[storage(read, write)]
    fn constructor(pigs: Identity, fee_token: Identity, fee_distributor: Identity, truffles: Identity, fees_per_second: u64, truffles_per_second: u64);

    /// Returns the address of the Pig NFT contract
    #[storage(read)]
    fn pigs() -> Identity;

    /// Returns the address of the fee token offered for staking
    #[storage(read)]
    fn fee_token() -> Identity;

    /// Returns the address of the fee distributor
    fn fee_distributor() -> Identity;

    /// Returns the address of the Truffes token contract
    fn truffles() -> Identity;

    /// Returns the address of the user that has a specific NFT staked
    #[storage(read)]
    fn owner_of(pig: u64) -> Identity;

    /// Returns the array of staked pigs for a specified user
    ///
    /// # Arguments
    ///
    /// * `user` - The staker for which we return all staked pigs
    fn staked_pigs(user: Identity) -> Vec<u64>;

    /// Returns the balance of the `user`
    ///
    /// # Arguments
    ///
    /// * `user` - The user of which the staked balance should be returned.
    #[storage(read)]
    fn balance_of(user: Identity) -> u64;

    /// Return the staking power of a pig staker
    ///
    /// # Arguments
    ///
    /// * `user` - The staker whose staking power we return
    #[storage(read)]
    fn staking_power(user: Identity) -> u64;

    /// Returns the amount of piglets that a user delegated to a pig
    ///
    /// # Arguments
    ///
    /// * `delegator` - The user that delegated piglets
    /// * `pig` - The pig to which the user delegated piglets
    fn delegate_balance_of(delegator: Identity, pig: u64) -> u64;

    /// Returns the user that delegated a piglet
    ///
    /// # Arguments
    //
    /// * `piglet` - The piglet for which we return the owner/delegator
    fn delegate_owner_of(piglet: u64) -> Identity;

    /// Returns the array of delegated piglets for a specified user
    ///
    /// # Arguments
    ///
    /// * `user` - The delegator for which we return all delegated piglets
    fn delegated_piglets(user: Identity) -> Vec<u64>;

    /// Returns the pig to which a piglet is delegated
    ///
    /// # Arguments
    ///
    /// * `piglet` - The piglet for which we return the pig to which it got delegated
    fn piglet_to_pig(piglet: u64) -> u64;

    /// Return the commission offered to delegators of a specific pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the commission
    fn fee_commission(pig: u64) -> u64;

    /// Return the amount of truffles minted each second for a staked pig
    fn truffles_per_second() -> u64;

    /// Return the amount of accrued and unminted truffles for a staked pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the accrued and unminted truffles
    fn accrued_truffles(pig: u64) -> u64;

    /// Return the accrued and unclaimed fees for a staked pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the accrued and unclaimed fees
    fn accrued_pig_fees(pig: u64) -> u64;

    /// Return the accrued and unclaimed fees for a delegated piglet
    ///
    /// # Arguments
    ///
    /// * `piglet` - The piglet for which we return the accrued and unclaimed fees
    fn accrued_piglet_fees(piglet: u64) -> u64;

    /// Return the delegators of a pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return all delegators
    fn delegators(pig: u64) -> Vec<Identity>;

    /// Delegate piglets to a pig
    ///
    /// # Arguments
    ///
    /// * `delegator` - The address that receives the delegated piglet inside the staking contract
    /// * `pig` - The pig to delegate piglets to
    /// * `piglets` - The piglets that are delegated to the `pig`
    fn delegate(delegator: Identity, pig: u64, piglets: [u64]);

    /// Undelegate piglets from a pig
    ///
    /// # Arguments
    ///
    /// * `delegator` - The address that receives the undelegated piglet
    /// * `pig` - The pig to undelegate piglets to
    /// * `piglets` - The piglets that are undelegated from the `pig`
    fn undelegate(delegator: Identity, pig: u64, piglets: [u64]);

    /// Stake a pig in the contract
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to stake
    /// * `user` - The user that will receive the pig inside the staking contract
    fn stake(pig: u64, user: Identity);

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

    /// Set the commission offered to piglet delegators
    ///
    /// * `pig` - The pig from which to set the commission
    /// * `commission` - The commission offered to piglet delegators
    fn set_fee_commission(pig: u64, commission: u64);
}
