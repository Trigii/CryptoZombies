# CryptoZombies

This repo contains the full [CryptoZombies](https://cryptozombies.io/en/course) course completed by Trigii.

## Quickstart

```sh
git clone https://github.com/Trigii/CryptoZombies
cd CryptoZombies
yarn
```

## Usage

Deploy:

```sh
yarn truffle migrate
```

### Testing:

```sh
yarn truffle test
```

## Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your SEPOLIA_RPC_URL and PRIVATE_KEY as environment variables. You can add them to a .env file, similar to what you see in .env.example.

- `SEPOLIA_PRIVATE_KEY`: The private key of your account (like from metamask). NOTE: FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.

- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from Alchemy

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link) and get some tesnet ETH & LINK. You should see the ETH and LINK show up in your metamask.

3. Deploy the contract

Run:

```sh
yarn truffle migrate --network sepolia
```

## Completion Certificate Links

- Chapter 1:
  - [Lesson 1](https://share.cryptozombies.io/en/lesson/1/share/Trist%C3%A1n?id=Y3p8NjI3Mzc0)
  - [Lesson 2](https://share.cryptozombies.io/en/lesson/2/share/Trist%C3%A1n?id=Y3p8NjI3Mzc0)
  - [Lesson 3](https://share.cryptozombies.io/en/lesson/3/share/Trist%C3%A1n?id=Y3p8NjI3Mzc0)
  - [Lesson 4](https://share.cryptozombies.io/en/lesson/4/share/Trist%C3%A1n?id=WyJjenw2MjczNzQiLDEsMTRd)
  - [Lesson 5](https://share.cryptozombies.io/en/lesson/5/share/H4XF13LD_MORRIS_%F0%9F%92%AF%F0%9F%92%AF%F0%9F%98%8E%F0%9F%92%AF%F0%9F%92%AF?id=Y3p8NjI3Mzc0)
  - [Lesson 6](https://share.cryptozombies.io/en/lesson/6/share/The_Phantom_of_Web3?id=Y3p8NjI3Mzc0)
