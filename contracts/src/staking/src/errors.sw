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
    InvalidComissionValue: (),
    NullArray: (),
    InvalidPig: ()
}

pub enum AccessControlError {
    SenderNotPigOwner: (),
    CallerNotPigletOwner: (),
    CallerNotPigletContract: ()
}

pub enum DelegationError {
    ExceedsDelegationLimit: ()
}
