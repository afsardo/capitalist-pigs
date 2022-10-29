library errors;

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderCannotSetPigletMinter: (),
    SenderNotOwnerOrApproved: (),
    SenderNotPigletMinter: (),
    SenderNotOwner: (),
}

pub enum InitError {
    AdminIsNone: (),
    PigletMinterIsNone: (),
    CannotReinitialize: (),
    PigletsToPigRatioCannotBeZero: (),
    InvalidFactory: (),
}

pub enum InputError {
    AdminDoesNotExist: (),
    ApprovedDoesNotExist: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    InvalidTokenSize: (),
    NotEnoughPiglets: (),
    InvalidNumberOfPiglets: (),
}
