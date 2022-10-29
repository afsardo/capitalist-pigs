library errors;

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderCannotSetPigletMinter: (),
    SenderNotOwner: (),
    SenderNotOwnerOrApproved: (),
    SenderNotPigletMinter: (),
}

pub enum InitError {
    AdminIsNone: (),
    NotEnoughPiglets: (),
    InvalidNumberOfPiglets: (),
    PigletMinterIsNone: (),
    CannotReinitialize: (),
}

pub enum InputError {
    AdminDoesNotExist: (),
    ApprovedDoesNotExist: (),
    OwnerDoesNotExist: (),
    TokenDoesNotExist: (),
    InvalidTokenSize: (),
}
