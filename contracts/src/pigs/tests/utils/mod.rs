use fuels::{contract::contract::CallResponse, prelude::*};

abigen!(Pigs, "out/debug/pigs-abi.json");

pub struct Metadata {
    pub contract: Pigs,
    pub wallet: WalletUnlocked,
}

pub mod abi_calls {

    use super::*;

    pub async fn admin(contract: &Pigs) -> Identity {
        contract.methods().admin().call().await.unwrap().value
    }

    pub async fn approve(approved: &Identity, contract: &Pigs, token_id: u64) -> CallResponse<()> {
        contract
            .methods()
            .approve(approved.clone(), token_id)
            .call()
            .await
            .unwrap()
    }

    pub async fn approved(contract: &Pigs, token_id: u64) -> Identity {
        contract
            .methods()
            .approved(token_id)
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn balance_of(contract: &Pigs, wallet: &Identity) -> u64 {
        contract
            .methods()
            .balance_of(wallet.clone())
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn burn(contract: &Pigs, token_id: u64) -> CallResponse<()> {
        contract.methods().burn(token_id).call().await.unwrap()
    }

    pub async fn constructor(
        access_control: bool,
        contract: &Pigs,
        owner: &Identity,
        piglet_transformer: &Identity,
        token_supply: u64,
        inflation_start_time: u64,
        inflation_rate: u64,
        inflation_epoch: u64,
    ) -> CallResponse<()> {
        contract
            .methods()
            .constructor(access_control, owner.clone(), piglet_transformer.clone(), token_supply, inflation_start_time, inflation_rate, inflation_epoch)
            .call()
            .await
            .unwrap()
    }

    pub async fn is_approved_for_all(
        contract: &Pigs,
        operator: &Identity,
        owner: &Identity,
    ) -> bool {
        contract
            .methods()
            .is_approved_for_all(operator.clone(), owner.clone())
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn max_supply(contract: &Pigs) -> u64 {
        contract.methods().max_supply().call().await.unwrap().value
    }

    pub async fn mint(amount: u64, contract: &Pigs, owner: &Identity) -> CallResponse<()> {
        contract
            .methods()
            .mint(amount, owner.clone())
            .call()
            .await
            .unwrap()
    }

    pub async fn meta_data(contract: &Pigs, token_id: u64) -> TokenMetaData {
        contract
            .methods()
            .meta_data(token_id)
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn owner_of(contract: &Pigs, token_id: u64) -> Identity {
        contract
            .methods()
            .owner_of(token_id)
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn set_approval_for_all(
        approve: bool,
        contract: &Pigs,
        operator: &Identity,
    ) -> CallResponse<()> {
        contract
            .methods()
            .set_approval_for_all(approve, operator.clone())
            .call()
            .await
            .unwrap()
    }

    pub async fn set_admin(contract: &Pigs, minter: &Identity) -> CallResponse<()> {
        contract
            .methods()
            .set_admin(minter.clone())
            .call()
            .await
            .unwrap()
    }

    pub async fn total_supply(contract: &Pigs) -> u64 {
        contract
            .methods()
            .total_supply()
            .call()
            .await
            .unwrap()
            .value
    }

    pub async fn transfer_from(
        contract: &Pigs,
        from: &Identity,
        to: &Identity,
        token_id: u64,
    ) -> CallResponse<()> {
        contract
            .methods()
            .transfer_from(from.clone(), to.clone(), token_id)
            .call()
            .await
            .unwrap()
    }
}

pub mod test_helpers {
    use super::*;

    pub async fn setup() -> (Metadata, Metadata, Metadata) {
        let num_wallets = 3;
        let coins_per_wallet = 1;
        let amount_per_coin = 1_000_000;

        let mut wallets = launch_custom_provider_and_get_wallets(
            WalletsConfig::new(
                Some(num_wallets),
                Some(coins_per_wallet),
                Some(amount_per_coin),
            ),
            None,
        )
        .await;

        // Get the wallets from that provider
        let wallet1 = wallets.pop().unwrap();
        let wallet2 = wallets.pop().unwrap();
        let wallet3 = wallets.pop().unwrap();

        let pig_id = Contract::deploy(
            "./out/debug/pigs.bin",
            &wallet1,
            TxParameters::default(),
            StorageConfiguration::with_storage_path(Some(
                "./out/debug/pigs-storage_slots.json".to_string(),
            )),
        )
        .await
        .unwrap();

        let deploy_wallet = Metadata {
            contract: Pigs::new(Bech32ContractId::from(ContractId::from(&pig_id)), wallet1.clone()),
            wallet: wallet1.clone(),
        };

        let owner1 = Metadata {
            contract: Pigs::new(Bech32ContractId::from(ContractId::from(&pig_id)), wallet2.clone()),
            wallet: wallet2.clone(),
        };

        let owner2 = Metadata {
            contract: Pigs::new(Bech32ContractId::from(ContractId::from(&pig_id)), wallet3.clone()),
            wallet: wallet3.clone(),
        };

        (deploy_wallet, owner1, owner2)
    }
}
