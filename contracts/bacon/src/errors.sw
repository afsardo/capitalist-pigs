library errors;

pub enum Error {
    AddressAlreadyMinted: (),
    CannotReinitialize: (),
    MintIsClosed: (),
    NotOwner: (),
}
