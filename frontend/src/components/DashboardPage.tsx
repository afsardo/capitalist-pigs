import { useEffect, useState } from "react";
import { Wallet } from "fuels";
import { PigsAbi__factory, MockContractAbi__factory } from "../contracts";
import Button from "./Button";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0x94ffcc53b892684acefaebc8a3d4a595e528a8cf664eeb3ef36f1020b0809d0d";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0xd1746a58bb5d94e2ac931d515e3ccd87a0cb4f03731f136678c77142dc0409ea";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = PigsAbi__factory.connect(CONTRACT_ID, wallet);
const mockContract = MockContractAbi__factory.connect(
  "0xd97ac31a1a473e6dd6f7dfdaf773a2a4df452ec3445afd291298b48dcea57cd3",
  wallet
);

export default function DashboardPage() {
  const [pigs, setPigs] = useState([]);

  // useEffect(() => {
  //   async function getPigs() {
  //     // GET PIGS FROM SC
  //     // await contract.functions
  //     //   .constructor(
  //     //     true,
  //     //     { Address: { value: WALLET_SECRET } },
  //     //     // TODO: ADD CONTRACTS TO CONSTANT FILE / ENV VARS
  //     //     { Address: { value: WALLET_SECRET } },
  //     //     100,
  //     //     1967084109,
  //     //     50,
  //     //     3600
  //     //   )
  //     //   .call();

  //     const { value: pigs } = await contract.functions
  //       .mint(1, { Address: { value: WALLET_SECRET } })
  //       .call();
  //   }
  //   getPigs();
  // }, []);

  async function increment() {
    // Creates a transactions to call the `increment()` function, passing in
    // the amount we want to increment. Because we're creating a TX that updates
    // the contract state, this requires the wallet to have enough coins to
    // cover the costs and to sign the transaction.
    const { value } = await mockContract.functions.increment(1).call();
    // setCounter(Number(value));
  }

  async function init() {
    // Creates a transactions to call the `increment()` function, passing in
    // the amount we want to increment. Because we're creating a TX that updates
    // the contract state, this requires the wallet to have enough coins to
    // cover the costs and to sign the transaction.
    const { value } = await contract.functions
      .constructor(
        true,
        { Address: { value: WALLET_SECRET } },
        // TODO: ADD CONTRACTS TO CONSTANT FILE / ENV VARS
        { Address: { value: WALLET_SECRET } },
        100,
        1967084109,
        50,
        3600
      )
      .call();
    console.log(value);
  }

  async function mint() {
    // Creates a transactions to call the `increment()` function, passing in
    // the amount we want to increment. Because we're creating a TX that updates
    // the contract state, this requires the wallet to have enough coins to
    // cover the costs and to sign the transaction.
    const { value } = await contract.functions
      .mint(1, { Address: { value: WALLET_SECRET } })
      .call();
    console.log(value);
  }

  return (
    <>
      <p>You have {pigs.length} pigs</p>
      <div className="flex flex-col gap-4">
        <Button onClick={increment}>Increment</Button>
        <Button onClick={init}>Initialize Pig Contract</Button>
        <Button onClick={mint}>Mint</Button>
      </div>
    </>
  );
}
