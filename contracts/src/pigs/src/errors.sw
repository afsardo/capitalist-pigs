library errors;

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderNotAdminOrPigletTransformer: (),
    SenderCannotSetPigletTransformer: (),
    SenderNotOwner: (),
    SenderNotOwnerOrApproved: (),
}

pub enum InitError {
    AdminIsNone: (),
    InvalidInflationStartTime: (),
    InvalidInflationRate: (),
    InvalidInflationEpoch: (),
    CannotReinitialize: (),
}

pub enum InflationError {
    InvalidSnapshotTime: (),
    AlreadySnapshotted: (),
    MintExceedsInflation: ()
}

pub enum InputError {
    AdminDoesNotExist: (),
    IndexExceedsArrayLength: (),
    PigletTransformerDoesNotExist: (),
    ApprovedDoesNotExist: (),
    NotEnoughTokensToMint: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    TokenSupplyCannotBeZero: (),
}
