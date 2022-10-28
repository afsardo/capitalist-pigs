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
    CannotReinitialize: (),
}

pub enum InputError {
    AdminDoesNotExist: (),
    PigletTransformerDoesNotExist: (),
    ApprovedDoesNotExist: (),
    NotEnoughTokensToMint: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    TokenSupplyCannotBeZero: (),
}
