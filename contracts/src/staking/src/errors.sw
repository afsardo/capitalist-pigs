library errors;

pub enum InitError {
    CannotReinitialize: (),
    PigsIsNone: (),
    FeeTokenIsNone: (),
    FeeDistributorIsNone: (),
    TrufflesIsNone: (),
    InvalidFeesPerSecond: (),
    InvalidTrufflesPerSecond: ()
}

pub enum InputError {
    IndexExceedsArrayLength: ()
}
