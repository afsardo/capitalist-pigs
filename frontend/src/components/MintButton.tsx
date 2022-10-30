import { Wallet } from "fuels";
import { PigsAbi__factory } from "../contracts";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const PIGS_CONTRACT_ID =
  "0x597f725c0cd2e1b83e24e324bc37363f0c6bb2a8daf4bd38fb55fcee60c4e479";

const PIGLETS_CONTRACT_ID =
  "0xa344e8a89e0395899301a8d00eda5fe09e992d350d99b4b5af6e3dfdfac7d0ad";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = PigsAbi__factory.connect(PIGS_CONTRACT_ID, wallet);

export default function MintButton() {
  const onMint = async () => {
    const init = await contract.functions
      .constructor(
        true,
        { Address: { value: WALLET_SECRET } },
        { Address: { value: PIGLETS_CONTRACT_ID } },
        100,
        1967084109,
        50,
        3600
      )
      .call();
    console.log("init", init);

    // @TODO
    // Mint a pig´
    const result = await contract.functions
      .mint(1, {
        Address: { value: WALLET_SECRET },
      })
      .call();

    console.log("result", result);
  };

  return (
    <>
      <button
        onClick={onMint}
        className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest animate-bounce"
      >
        CLAIM
      </button>
    </>
  );
}
