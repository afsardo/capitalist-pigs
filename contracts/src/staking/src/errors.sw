library errors;

pub enum InitError {
    CannotReinitialize: (),
    PigsIsNone: (),
    PigletsIsNone: (),
    FeeTokenIsNone: (),
    FeeDistributorIsNone: (),
    TrufflesIsNone: (),
    InvalidFeesPerSecond: (),
    InvalidTrufflesPerSecond: ()
}

pub enum InputError {
    CannotAssingToThisContract: (),
    IndexExceedsArrayLength: (),
    PigletAlreadyDelegated: (),
    PigProvidedNotStaked: (),
    NullArray: (),
    InvalidPig: ()
}

pub enum AccessControlError {
    CallerNotPigletOwner: (),
    CallerNotPigletContract: ()
}
