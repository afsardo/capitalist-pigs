library data_structures;

pub struct RemoveLiquidityInfo {
    eth_amount: u64,
    truffle_amount: u64,
}

pub struct PositionInfo {
    eth_amount: u64,
    truffle_amount: u64,
    eth_reserve: u64,
    truffle_reserve: u64,
    lp_truffle_supply: u64,
}

pub struct PoolInfo {
    eth_reserve: u64,
    truffle_reserve: u64,
    lp_truffle_supply: u64,
}

pub struct PreviewInfo {
    amount: u64,
    has_liquidity: bool,
}

pub struct PreviewAddLiquidityInfo {
    truffle_amount: u64,
    lp_truffle_received: u64,
}
