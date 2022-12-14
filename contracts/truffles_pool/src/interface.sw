library interface;

dep data_structures;

use data_structures::{
    PoolInfo,
    PositionInfo,
    PreviewAddLiquidityInfo,
    PreviewInfo,
    RemoveLiquidityInfo,
};

use std::contract_id::ContractId;

abi TrufflesPool {
    ////////////////////
    // Read only
    ////////////////////
    /// Return the current balance of given token on the contract
    #[storage(read)]
    fn get_balance(asset_id: ContractId) -> u64;
    /// Get information on the liquidity pool.
    #[storage(read)]
    fn get_pool_info() -> PoolInfo;
    /// Get add liquidity preview
    #[storage(read)]
    fn get_add_liquidity(amount: u64, asset_id: b256) -> PreviewAddLiquidityInfo;
    /// Get current positions
    #[storage(read)]
    fn get_position(amount: u64) -> PositionInfo;
    ////////////////////
    // Actions
    ////////////////////
    /// Deposit coins for later adding to liquidity pool.
    #[storage(read, write)]
    fn deposit();
    /// Withdraw coins that have not been added to a liquidity pool yet.
    #[storage(read, write)]
    fn withdraw(amount: u64, asset_id: ContractId);
    /// Deposit ETH and Truffle at current ratio to mint TruffleLP tokens.
    #[storage(read, write)]
    fn add_liquidity(min_liquidity: u64, deadline: u64) -> u64;
    /// Burn TruffleLP tokens to withdraw ETH and Truffle at current ratio.
    #[storage(read, write)]
    fn remove_liquidity(min_eth: u64, min_tokens: u64, deadline: u64) -> RemoveLiquidityInfo;
    /// Swap ETH <-> Truffle and tranfers to sender.
    #[storage(read, write)]
    fn swap_with_minimum(min: u64, deadline: u64) -> u64;
    /// Swap ETH <-> Truffle and tranfers to sender.
    #[storage(read, write)]
    fn swap_with_maximum(amount: u64, deadline: u64) -> u64;
    /// Get the minimum amount of coins that will be received for a swap_with_minimum.
    #[storage(read, write)]
    fn get_swap_with_minimum(amount: u64) -> PreviewInfo;
    /// Get required amount of coins for a swap_with_maximum.
    #[storage(read, write)]
    fn get_swap_with_maximum(amount: u64) -> PreviewInfo;
}
