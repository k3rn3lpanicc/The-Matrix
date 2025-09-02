# Exmodules Metaverse Contracts

A Collection of different contracts developed for Exmodules Metaverse

# Blockable ERC20 token

## Usage

### Getting started

Run `npm install` to install the needed packages.

### Compile contracts

Run `npm run compile` to compile all the contracts.

### Deploy the contract to testnet

First create a `.env` file in the root directory; it should contain these values:

- `MUMBAI_API_KEY` : the api key for mumbai block explorer (you can fetch yours from <https://mumbai.polygonscan.com/>), this api key is used to verify the contract after deployment
  
- `PRIVATE_KEY`: your mumbai account's private key. this account is used to deploy the contract to chain.

Then run this command: `npm run deployBlacklistable:mumbai` and it would start building contracts, deployment and verification steps and you can relax till the job gets done. The results would be like this:

```bash
➜ npm run deployBlacklistable:mumbai

> metaverse-contracts@1.0.0 deployBlacklistable:mumbai
> npx hardhat run --network polygonMumbai ./scripts/deployBlacklistable.ts

[ ☕️ ] Deploying the Exmodules Marketplace to chain ...
[ ✅ ] Exmodule token deployed to: 0xb4C164097d449d5f86122E33dCd70f5E0AcE9910 with Token name: Exmodule Token, Symbol: exm, initial supply: 100000000000000000000000000
[ ☕️ ] Waiting 20 seconds ...
[ ☕️ ] Verifying the contract's source code on block explorer ...
Successfully submitted source code for contract
contracts/Blacklistable.sol:Blacklistable at 0xb4C164097d449d5f86122E33dCd70f5E0AcE9910
for verification on the block explorer. Waiting for verification result...

Successfully verified contract Blacklistable on the block explorer.
https://mumbai.polygonscan.com/address/0xb4C164097d449d5f86122E33dCd70f5E0AcE9910#code
[ ✅ ] Contract's source code verified on block explorer.
```

### Run the tests

To run the tests simply run `npx hardhat test .\test\testBlockable.ts`, the results should be like this:

```bash
➜ npx hardhat test .\test\testBlockable.ts


  BlockableERC20
    ✔ Should allow the owner to block tokens for an account
    ✔ Should allow the owner to unblock tokens for an account
    ✔ Should prevent transfers of blocked tokens
    ✔ Should allow transfers of unblocked tokens (41ms)
    ✔ Should prevent transfers exceeding unblocked balance
    ✔ Should prevent blocking tokens for the zero address


  6 passing (3s)

```

---

# MarketPlace

## Usage

### Getting started

Run `npm install` to install the needed packages.

### Compile contracts

Run `npm run compile` to compile all the contracts.

### Deploy the contract to testnet

First create a `.env` file in the root directory; it should contain these values:

- `MUMBAI_API_KEY` : the api key for mumbai block explorer (you can fetch yours from <https://mumbai.polygonscan.com/>), this api key is used to verify the contract after deployment
  
- `PRIVATE_KEY`: your mumbai account's private key. this account is used to deploy the contract to chain.

Now head to the `scripts/deployMarketPlace.ts` file and change the needed information on the TODO section (first part of the file)

Then run this command: `npm run deployMarketplace:mumbai` and it would start building contracts, deployment and verification steps and you can relax till the job gets done. The results would be like this:

```bash
➜ npm run deployMarketplace:mumbai

> erc20token-example@1.0.0 deployMarketplace:mumbai
> npx hardhat run --network polygonMumbai ./scripts/deployMarketPlace.ts

[ ☕️ ] Deploying the Exmodules Marketplace to chain ...
[ ✅ ] Exmodule Marketplace deployed to: 0xbB9069f7Cd70a70a0F230c8D9de19859F7FAFb5F with fee: 100, feeReceiver: 0x2cBFC23A609a34AafB7DDA667dbA883f9f224571, paymentToken: 0x76f4732ab033696eD9Fb4B328Ec63c3c7495517b
[ ☕️ ] Waiting 20 seconds ...
[ ☕️ ] Verifying the contract's source code on block explorer ...
Successfully submitted source code for contract
contracts/ExmodulesMarketplace.sol:ExmodulesMarketPlace at 0xbB9069f7Cd70a70a0F230c8D9de19859F7FAFb5F
for verification on the block explorer. Waiting for verification result...

Successfully verified contract ExmodulesMarketPlace on the block explorer.
https://mumbai.polygonscan.com/address/0xbB9069f7Cd70a70a0F230c8D9de19859F7FAFb5F#code
[ ✅ ] Contract's source code verified on block explorer.
```

### Run the tests

To run the tests simply run `npx hardhat test .\test\testMarketplace.ts`, the results should be like this:

```bash
➜ npx hardhat test .\test\testMarketplace.ts


  Exmodules Marketplace
    Deployment
      ✔ Should deploy the contract (1538ms)
      ✔ Should change the fee rate (149ms)
      ✔ Should change the fee receiver (120ms)
      ✔ Should not change the fee rate if not owner (106ms)
      ✔ Should not change the fee receiver if not owner (96ms)
      ✔ Should Mint a NFT and list it in marketplace (142ms)
      ✔ Should emit error if not approved for marketplace (112ms)
      ✔ Should emit error if not owner of token (107ms)
      ✔ Should emit error if price is zero (106ms)
      ✔ Should emit error if attempted to list twice (138ms)
      ✔ Should cancel a listing in marketplace (196ms)
      ✔ Should emit error if cancelling a not listed item (115ms)
      ✔ Should update a price in marketplace (154ms)
      ✔ Should buy an item in marketplace (149ms)


  14 passing (3s)

```

---

# ERC20/BEP20 token contract

## Usage

### Getting started

Run `npm install` to install the needed packages to work with.

### Compile contracts

Run `npm run compile` to compile the solidity contracts.

### Deploy the contract to tesnet

First create a `.env` file in the root directory; it should contain these values:

- `BINANCE_API_KEY` : the api key for binance block explorer (you can fetch yours from <https://testnet.bscscan.com>), this api key is used to verify the contract after deployment
  
- `BINANCE_PRIVATE_KEY`: your binance account's private key. this account is used to deploy the contract to chain.

Then run this command: `npm run deploy:binance` and it would start building contracts, deployment and verification steps and you can relax till the job gets done. The results would be like this:

```bash
➜ npm run deploy:binance

> erc20token-example@1.0.0 deploy:binance
> npx hardhat run --network bscTestnet ./scripts/deploy.ts

[ ☕️ ] Deploying the Exmodules token to chain ...
[ ✅ ] Exmodule token deployed to: 0x958b6EfEa4f3C05cB42378E4E6B8d0a3fa591ef2 with initial supply: 1000000000
[ ☕️ ] Waiting 20 seconds ...
[ ☕️ ] Verifying the contract's source code on block explorer ...
The contract 0x958b6EfEa4f3C05cB42378E4E6B8d0a3fa591ef2 has already been verified.
https://testnet.bscscan.com/address/0x958b6EfEa4f3C05cB42378E4E6B8d0a3fa591ef2#code
[ ✅ ] Contract's source code verified on block explorer.
```

### Run the tests

To run the tests simply run `npm run test`, the results should be like this:

```bash
➜ npm run test

> erc20token-example@1.0.0 test
> npx hardhat test



  Exmodules
    Deployment
      ✔ Should deploy the contract (1347ms)
      ✔ Should have the right initial value (1e9) (52ms)
      ✔ Should transfer 1 token to another person (54ms)
      ✔ Should mint 100 more tokens (45ms)


  4 passing (2s)
```

---

# Staking token example

This is a simple contract that users stake their tokens and receive `fixed` stake rewards based on the time they've staked their tokens in.

The rewards are calculated as so: `amountOfStaked * timeStaked ( currentTime - lastInteractionTime ) / secondsToRewardOneToken`

## Usage

### Getting started

Run `npm install` to install the needed packages to work with.

### Compile contracts

Run `npm run compile` to compile the solidity contracts.

### Deploy the contract to tesnet

First create a `.env` file in the root directory; it should contain these values:

- `BINANCE_API_KEY` : the api key for binance block explorer (you can fetch yours from <https://testnet.bscscan.com>), this api key is used to verify the contract after deployment
  
- `BINANCE_PRIVATE_KEY`: your binance account's private key. this account is used to deploy the contract to chain.

Then run this command: `npm run deployStake:binance` and it would start building contracts, deployment and verification steps and you can relax till the job gets done. The results would be like this:

- Note: you can deploy to mumbai network by this command: `npm run deployStake:mumbai`

```bash
➜ npm run deployStake:binance

> erc20token-example@1.0.0 deployStake:binance
> npx hardhat run --network bscTestnet ./scripts/deployStaking.ts

[ ☕️ ] Deploying the Exmodules staking token to chain ...
[ ✅ ] Exmodule staking token deployed to: 0x29aE535bc25d69Fd299eD0211a5E4b245eaB5e0c with initial supply: 1000000000
[ ☕️ ] Waiting 20 seconds ...
[ ☕️ ] Verifying the contract's source code on block explorer ...
Successfully submitted source code for contract
contracts/ExmoduleStaking.sol:ExmoduleStaking at 0x29aE535bc25d69Fd299eD0211a5E4b245eaB5e0c
for verification on the block explorer. Waiting for verification result...

Successfully verified contract ExmoduleStaking on the block explorer.
https://testnet.bscscan.com/address/0x29aE535bc25d69Fd299eD0211a5E4b245eaB5e0c#code
[ ✅ ] Contract's source code verified on block explorer.
```

### Run the tests

To run the tests simply run `npm run test`, the results should be like this:

```bash
➜ npm run test 

> erc20token-example@1.0.0 test
> npx hardhat test



  Exmodules
    Deployment
      ✔ Should deploy the contract (1547ms)
      ✔ Should have the right initial value (1e9) (64ms)
      ✔ Should transfer 1 token to another person (53ms)
      ✔ Should mint 100 more tokens (52ms)

  Exmodules Staking
    Deployment
      ✔ Should deploy the contract (44ms)
      ✔ Should have the right initial value (1e9) (42ms)
      ✔ Should transfer 1 token to another person (82ms)
      ✔ Should mint 100 more tokens (76ms)
      ✔ First user should be able to stake 1 tokens (76ms)
      ✔ First user should be able to unstake 1 tokens (79ms)
The reward amount:  31709791983n
      ✔ First user should be able to stake 1 tokens and receive rewards after 1 seconds (1080ms)


  11 passing (3s)
```
