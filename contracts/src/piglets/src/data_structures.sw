library data_structures;

dep constants;

use constants::{NULLSTRING};

pub struct TokenMetaData {
    // This is left as an example. Support for dynamic length string is needed here
    name: str[7],
}

impl TokenMetaData {
    fn new() -> Self {
        Self {
            name: NULLSTRING,
        }
    }
}
