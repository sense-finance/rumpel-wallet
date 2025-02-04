import { ethers } from "ethers";
import dotenv from "dotenv";
import path from "path";
import fs from "fs";

// Load .env from the parent directory
dotenv.config({ path: path.resolve(__dirname, "../.env") });


const rpc = process.env.MAINNET_RPC_URL;
console.log(`rpc: ${rpc}`)

const provider = new ethers.JsonRpcProvider();

const configPath = path.resolve(__dirname, "../script/RumpelConfig.sol");
const configCode = fs.readFileSync(configPath, "utf8");
const contractNameRegex = /address\s+public\s+constant\s+(\w+)\s*=\s*(0x[a-fA-F0-9]{40})\s*;/g;
const functionRegex = /function\s+([^\s(]+)\s*\(([^)]*)\)/g;

const addressToVariableMap: Record<string, string> = {};
let match;
while ((match = contractNameRegex.exec(configCode)) !== null) {
    const [_, variableName, address] = match;
    console.log(variableName);
    console.log(address);
    addressToVariableMap[address.toLowerCase()] = variableName;
}

const functionSelectorToFunction: Record<string, string> = {};
while ((match = functionRegex.exec(configCode)) !== null) {
  const functionName = match[1].trim();
  const functionParams = match[2]
      .split(",")
      .map(param => param.trim().split(" ")[0])
      .filter(param => param.length > 0)
      .join(",");

  const fullSignature = `${functionName}(${functionParams})`;
  functionSelectorToFunction[ethers.id(fullSignature).slice(0, 10)] = fullSignature.replace(/,/g, ".");
};
functionSelectorToFunction[ethers.id("transfer(address,uint256)").slice(0, 10)] = "transfer(address.uint256)";
functionSelectorToFunction[ethers.id("approve(address,uint256)").slice(0, 10)] = "approve(address.uint256)";

const guardAddress = "0x9000FeF2846A5253fD2C6ed5241De0fddb404302";
const moduleAddress = "0x28c3498B4956f4aD8d4549ACA8F66260975D361a";

const guardAbi = [
    "event SetCallAllowed(address indexed target, bytes4 indexed functionSelector, uint8 allowListState)"
];

const moduleAbi = [
    "event SetModuleCallBlocked(address indexed target, bytes4 indexed functionSelector)"
];

const guardInterface = new ethers.Interface(guardAbi);
const moduleInterface = new ethers.Interface(moduleAbi);


const printCurrentState = async() => {
  const currentState: Record<string, Record<string, bigint>> = {};

  const fromBlock = 0;
  const toBlock = await provider.getBlockNumber();

  const setCallAllowedTopic = guardInterface.getEvent("SetCallAllowed")?.topicHash || null;

  // const setModuleCallBlocked = {
  //   moduleAddress,
  //   topics: [moduleInterface.getEvent("SetModuleCallBlocked")?.topicHash]
  // }

  const guardAllowedLogs = await provider.getLogs({address: guardAddress, topics: [setCallAllowedTopic], fromBlock, toBlock })
  guardAllowedLogs.forEach(log => {
    const contract = addressToVariableMap["0x"+log.topics[1].slice(26, 66)] || "0x"+log.topics[1].slice(26, 66);
    const functionName = functionSelectorToFunction[log.topics[2].slice(0, 10)] || log.topics[2].slice(0, 10) ;
    const state = BigInt(log.data);
    if(!currentState[contract]){
      currentState[contract] = {}
    }
    currentState[contract][functionName] = state;
  });

  console.log("contract,name,state");
  let i = 0;
  for(const contract in currentState){
    for(const functionName in currentState[contract]){
      console.log(`${i++}, ${contract}, ${functionName}, ${currentState[contract][functionName]}`)
    }
  }

}

printCurrentState();