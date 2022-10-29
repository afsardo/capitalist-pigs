use crate::utils::{
    abi_calls::{constructor, max_supply, total_supply},
    test_helpers::setup,
};
use fuels::{prelude::Identity, signers::Signer};

mod success {
    use super::*;

    #[tokio::test]
    async fn initalizes_with_access_control() {
        let (deploy_wallet, owner1, _owner2) = setup().await;

        assert_eq!(total_supply(&owner1.contract).await, 0);
        assert_eq!(max_supply(&owner1.contract).await, 0);

        let admin = Identity::Address(owner1.wallet.address().into());
        constructor(true, &deploy_wallet.contract, &admin, &Identity::ContractId(ContractId::from([2u8; 32])), 1, 4102444800, 50, 3600).await;

        assert_eq!(total_supply(&owner1.contract).await, 0);
        assert_eq!(max_supply(&owner1.contract).await, 1);
    }

    #[tokio::test]
    #[ignore]
    async fn initalizes_without_access_control() {
        let (_deploy_wallet, owner1, _owner2) = setup().await;

        assert_eq!(total_supply(&owner1.contract).await, 0);
        assert_eq!(max_supply(&owner1.contract).await, 0);

        assert_eq!(total_supply(&owner1.contract).await, 0);
        assert_eq!(max_supply(&owner1.contract).await, 1);
    }
}

mod reverts {
    use super::*;

    #[tokio::test]
    #[should_panic(expected = "Revert(42)")]
    async fn when_initalized_twice() {
        let (deploy_wallet, owner1, _owner2) = setup().await;

        let admin = Identity::Address(owner1.wallet.address().into());
        constructor(true, &deploy_wallet.contract, &admin, &Identity::ContractId(ContractId::from([2u8; 32])), 1, 4102444800, 50, 3600).await;
        constructor(true, &deploy_wallet.contract, &admin, &Identity::ContractId(ContractId::from([2u8; 32])), 1, 4102444800, 50, 3600).await;
    }

    #[tokio::test]
    #[should_panic(expected = "Revert(42)")]
    async fn when_token_supply_is_zero() {
        let (deploy_wallet, owner1, _owner2) = setup().await;

        let admin = Identity::Address(owner1.wallet.address().into());
        constructor(true, &deploy_wallet.contract, &admin, &Identity::ContractId(ContractId::from([2u8; 32])), 1, 4102444800, 50, 3600).await;
    }

    #[tokio::test]
    #[should_panic(expected = "Revert(42)")]
    #[ignore]
    async fn when_access_control_set_but_no_admin() {
        let (_deploy_wallet, _owner1, _owner2) = setup().await;
    }
}
