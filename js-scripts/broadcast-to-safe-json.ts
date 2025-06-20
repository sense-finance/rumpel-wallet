import { ZeroAddress } from "ethers";
import fs from "fs";
import path from "path";
import readline from "readline";
import { TxBuilder } from "@morpho-labs/gnosis-tx-builder";

const RUMPEL_ADMIN_SAFE = "0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06";
const RUMPEL_ADMIN_SAFE_HYPEREVM = "0x3ffd3d3695Ee8D51A54b46e37bACAa86776A8CDA";

// Function to get user input
const getUserInput = async (question: string): Promise<string> => {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
};

// Function to list JSON files in the dry-run folder
const listJsonFiles = (dirPath: string): string[] => {
  return fs
    .readdirSync(dirPath)
    .filter((file) => file.endsWith(".json"))
    .map((file) => path.join(dirPath, file));
};

// Main function
async function main() {
  // Get the tag name from command line arguments
  const tagName = process.argv[2];
  if (!tagName) {
    console.error("Please provide a tag name as an argument.");
    process.exit(1);
  }

  const chainId = Number(process.argv[3]);
  let rumpelAdminSafe;
  if (rumpelAdminSafe == 1) {
    rumpelAdminSafe = RUMPEL_ADMIN_SAFE;
  } else if (rumpelAdminSafe == 999) {
    rumpelAdminSafe = RUMPEL_ADMIN_SAFE_HYPEREVM;
  }

  const dryRunPath =
    process.env.DRYRUN_PATH ||
    path.join(
      process.cwd(),
      "..",
      "broadcast",
      "RumpelWalletFactory.s.sol",
      chainId.toString(),
      "dry-run"
    );
  const jsonFiles = listJsonFiles(dryRunPath);

  console.log("Available JSON files:");
  jsonFiles.forEach((file, index) => {
    console.log(`${index + 1}. ${path.basename(file)}`);
  });

  const selection = await getUserInput(
    "Enter the number of the file you want to use: "
  );
  const selectedFile = jsonFiles[parseInt(selection) - 1];

  if (!selectedFile) {
    console.error("Invalid selection. Exiting.");
    process.exit(1);
  }

  const runLatestContent = fs.readFileSync(selectedFile, "utf-8");
  const runLatestData = JSON.parse(runLatestContent);

  // Extract and format transactions
  const transactions = runLatestData.transactions.map((tx: any) => ({
    to: tx.transaction.to || ZeroAddress,
    value: tx.transaction.value,
    data: tx.transaction.input,
  }));

  // Display transactions for confirmation
  console.log("\nTransactions to be processed:");
  transactions.forEach((tx, index) => {
    console.log(`\nTransaction ${index + 1}:`);
    console.log(`To: ${tx.to}`);
    console.log(`Value: ${tx.value}`);
    console.log(`Data: ${tx.data.slice(0, 50)}...`);
  });

  const confirm = await getUserInput(
    "\nDo you want to proceed with these transactions? (y/n): "
  );

  if (confirm.toLowerCase() !== "y") {
    console.log("Operation cancelled. Exiting.");
    process.exit(0);
  }

  const batchJson = TxBuilder.batch(RUMPEL_ADMIN_SAFE, transactions, {
    chainId: Number(chainId),
  });
  batchJson.meta.description = tagName;

  // Create safe-batches folder one level up from the current working directory if it doesn't exist
  const safeBatchesFolder = path.join(process.cwd(), "..", "safe-batches");
  if (!fs.existsSync(safeBatchesFolder)) {
    fs.mkdirSync(safeBatchesFolder);
  }

  // Write the result to a file in the safe-batches folder
  const outputPath = path.join(safeBatchesFolder, `${tagName}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(batchJson, null, 2));

  console.log(`Transactions have been written to ${outputPath}`);
}

// Modify the main function call to pass any errors to console.error
main().catch((error) => {
  console.error("An error occurred:", error);
  process.exit(1);
});
