library staking_interface;

use std::{identity::Identity, vec::Vec};

abi StakingABI {
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
    fn constructor(pigs: ContractId, fee_token: ContractId, fee_distributor: ContractId, truffles: ContractId, fees_per_second: u64, truffles_per_second: u64);

    /// Returns the address of the Pig NFT contract
    #[storage(read)]
    fn pigs() -> ContractId;

    /// Returns the address of the fee token offered for staking
    #[storage(read)]
    fn fee_token() -> ContractId;

    /// Returns the address of the fee distributor
    fn fee_distributor() -> Identity;

    /// Returns the address of the Truffes token contract
    fn truffles() -> ContractId;

    /// Returns the address of the user that has a specific NFT staked
    #[storage(read)]
    fn owner_of(pig: u64) -> Identity;

    /// Returns the array of staked pigs for a specified user
    ///
    /// # Arguments
    ///
    /// * `user` - The staker for which we return all staked pigs
    #[storage(read)]
    fn staked_pigs(user: Identity, index: u64) -> u64;

    /// Returns the balance of the `user`
    ///
    /// # Arguments
    ///
    /// * `user` - The user whose staked balance should be returned.
    #[storage(read)]
    fn balance_of(user: Identity) -> u64;

    /// Returns the total amount of piglets that a user currently delegates
    ///
    /// # Arguments
    ///
    /// * `user` - The user whose delegated piglet balance we return
    #[storage(read)]
    fn delegate_balance_of(delegator: Identity) -> u64;

    /// Return the staking power of a pig (taking into account delegated piglets)
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig whose staking power we return
    #[storage(read)]
    fn staking_power(pig: u64) -> u64;

    /// Return a piglet at an index in a delegator's piglet array
    ///
    /// # Arguments
    ///
    /// * `delegator` - The delegator for which we query the piglet
    /// * `index` - The index at which to query for the piglet
    #[storage(read)]
    fn delegated_piglets(delegator: Identity, index: u64) -> u64;

    /// Returns the pig to which a piglet is delegated
    ///
    /// # Arguments
    ///
    /// * `piglet` - The piglet for which we return the pig to which it got delegated
    #[storage(read)]
    fn piglet_to_pig(piglet: u64) -> u64;

    /// Return the commission offered to delegators of a specific pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the commission
    #[storage(read)]
    fn fee_commission(pig: u64) -> u64;

    /// Return the amount of truffles minted each second for a staked pig
    #[storage(read)]
    fn truffles_per_second() -> u64;

    /// Return the amount of accrued and unminted truffles for a staked pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the accrued and unminted truffles
    #[storage(read)]
    fn accrued_truffles(pig: u64) -> u64;

    /// Return the accrued and unclaimed fees for a staked pig
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig for which we return the accrued and unclaimed fees
    #[storage(read)]
    fn accrued_pig_fees(pig: u64) -> u64;

    /// Return the accrued and unclaimed fees for a delegated piglet
    ///
    /// # Arguments
    ///
    /// * `piglet` - The piglet for which we return the accrued and unclaimed fees
    #[storage(read)]
    fn accrued_piglet_fees(piglet: u64) -> u64;

    /// Delegate piglets to a pig
    ///
    /// # Arguments
    ///
    /// * `delegator` - The address that receives the delegated piglet inside the staking contract
    /// * `pig` - The pig to delegate piglets to
    /// * `piglets` - The piglets that are delegated to the `pig`
    #[storage(read, write)]
    fn delegate(delegator: Identity, pig: u64, piglets: Vec<u64>);

    /// Undelegate piglets from a pig
    ///
    /// # Arguments
    ///
    /// * `delegator` - The address that receives the undelegated piglet
    /// * `pig` - The pig to undelegate piglets to
    /// * `piglets` - The piglets that are undelegated from the `pig`
    #[storage(read, write)]
    fn undelegate(delegator: Identity, pig: u64, piglets: Vec<u64>);

    /// Stake a pig in the contract
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to stake
    /// * `user` - The user that will receive the pig inside the staking contract
    #[storage(read, write)]
    fn stake(pig: u64, user: Identity);

    /// Unstake a pig from the contract
    ///
    /// # Arguments
    ///
    /// * `pig` - The pig to unstake
    #[storage(read, write)]
    fn unstake(pig: u64);

    /// Claim fees (for the pig staker and the delegates of that pig)
    ///
    /// * `pig` - The pig from which to claim accrued fees
    #[storage(read, write)]
    fn claim_fees(pig: u64);

    /// Set the commission offered to piglet delegators
    ///
    /// * `pig` - The pig from which to set the commission
    /// * `commission` - The commission offered to piglet delegators
    #[storage(read, write)]
    fn set_fee_commission(pig: u64, commission: u64);
}
