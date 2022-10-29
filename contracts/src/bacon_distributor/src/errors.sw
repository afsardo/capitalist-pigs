library errors;

pub enum InitError {
    InvalidBaconID: (),
    InvalidStakingID: ()
}

pub enum AccessControlError {
    NotStakingContract: ()
}
