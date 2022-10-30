library interface;

abi BaconDistributor {
    /// Initialize the contract
    ///
    /// # Arguments
    ///
    /// * `bacon` - The address of the bacon token contract
    /// * `staking` - The address of the pig staking contract (that can claim bacon)
    #[storage(read, write)]
    fn constructor(bacon: ContractId, staking: ContractId);

    /// Claim bacon (callable only by the staking contract)
    #[storage(read, write)]
    fn claim_fees(receiver: Identity, amount: u64);
}
