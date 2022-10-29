library errors;

pub enum AccessError {
    SenderCannotSetAccessControl: (),
    SenderCannotSetPigletMinter: (),
    SenderNotOwner: (),
    SenderNotOwnerOrApproved: (),
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
}
