library errors;

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderCannotSetPigletMinter: (),
    SenderNotOwnerOrApproved: (),
    SenderNotPigletMinter: (),
}

pub enum InitError {
    AdminIsNone: (),
    PigletMinterIsNone: (),
    CannotReinitialize: (),
}

pub enum InputError {
    AdminDoesNotExist: (),
    ApprovedDoesNotExist: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    InvalidTokenSize: (),
    NotEnoughPiglets: (),
    InvalidNumberOfPiglets: (),
    SenderNotOwner: (),
}
