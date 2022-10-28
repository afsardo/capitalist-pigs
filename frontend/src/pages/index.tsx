import { Wallet } from "fuels";
import { useEffect, useState } from "react";
import { ContractsAbi__factory } from "../contracts";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0xd97ac31a1a473e6dd6f7dfdaf773a2a4df452ec3445afd291298b48dcea57cd3";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = ContractsAbi__factory.connect(CONTRACT_ID, wallet);

export default function Home() {
  const [counter, setCounter] = useState(0);

  useEffect(() => {
    async function main() {
      // Executes the `counter()` function to query the current contract state.
      // the `.get()` method is read-only. Therefore, doesn't spend coins.
      const { value } = await contract.functions.counter().get();
      setCounter(Number(value));
    }
    main();
  }, []);

  async function increment() {
    // Creates a transactions to call the `increment()` function, passing in
    // the amount we want to increment. Because we're creating a TX that updates
    // the contract state, this requires the wallet to have enough coins to
    // cover the costs and to sign the transaction.
    const { value } = await contract.functions.increment(1).call();
    setCounter(Number(value));
  }

  return (
    <div>
      <header>
        <h1>CapitalistPigs</h1>
      </header>

      <main>
        <p>Counter: {counter}</p>
        <button onClick={increment}>Increment</button>
      </main>

      <footer>Powered b Degens, BlazinglyFast™</footer>
    </div>
  );
}
