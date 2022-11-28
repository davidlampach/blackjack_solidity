# BLACK JACK IN SOLIDITY AND STREAMLIT

## Description

This code implements a smart contract that enables players to play Black Jack.  Black Jack is a game of chance where players place wagers on the outcome of the game.  This game is entirely playable in the smart contract and does not rely on any particular user interface.  We provide a Streamlit interface for example purposes.

The following rules are used for the Black Jack contract:

No splitting
No insurance
Black Jack pays 3/2
Dealer must stay on soft 17

## Warning - Insecure Code
This code uses recent block hashes to generate "pseudorandom" numbers.  Do not deploy this contract for real money use.  Miners can manipulate the block hashes and control the outcome of the game.  If you wish to deploy this contract for real money use, you must swap out the pseudorandom number generator for a true random number generator.  True randomness is not possible on a block chain, so an off chain oracle is needed.  

---

## Dependencies

[![Python](https://img.shields.io/badge/Python-3.9.12-blue)](https://www.python.org/downloads/release/python-3912/)

[![Solidity](https://img.shields.io/badge/Solidity-0.8.17-blue)](https://docs.soliditylang.org/en/v0.8.9/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

[![Web3](https://img.shields.io/badge/Web3-5.24.0-blue)](https://web3py.readthedocs.io/en/stable/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

[![JSON](https://img.shields.io/badge/Json-2.0.9-blue)](https://docs.python.org/3/library/json.html)

[![PIL](https://img.shields.io/badge/PIL-1.1.6-blue)](https://pypi.org/project/PIL/)

---

## Installation

1. To install, clone this git repo to your local machine.  You will be able to copile and deploy the smart contracts directly in Remix.  Alternatively, you can compile and deploy them by running deploy.py.  Deploy.py will compile and deploy the contract at the command line, but you need to update the deploying address and secret key in the .env file. Deploy.py will automatically update the contract address in the .env file. 

2. If you choose to use deploy.py, you will need the sol-c-x compiler.

        pip install py-solc-x

3. The entirety of this game runs with a smart contract written in solidity.  It is best to familiarize oneself with the contract in a GUI compiler like remix before deploying the game in Streamlit.  You can use a test ethereum network, but this program will not run on the Remix test network due to limitations on what kind of code can be called on Remix.  Ganache-CLI was used for our deployment, but the Ganache-GUI works as well (much slower).



## Running just the Solidity contracts

1. No GUI is necessary to play the game.  You can load the blackjack.sol in the compiler of your choice.  It uses [![Solidity](https://img.shields.io/badge/Solidity-0.8.17-blue)](https://docs.soliditylang.org/en/v0.8.9/)

2. After you've compiled the contract you can deploy it on any Ethereum network (with the exception of the Remix test network)

3. blackjack.sol usage

- To play this game, you must first fund the House portion of the contract.  Call the fundContract() payable function with 0 as the player parameter, and some amount of ethereum as the payable value.  This will deposit money into the house side of the contract.  You can check how much the house has in the contract by calling houseBalance()  

- Next fund the player side, but call the same function with parameter 1 and however much you want the player to buy into the game for.  You are now ready to play a game.  You can check how much the player has in the contract by calling playerBalance()

- To play a hand, bet as much as you like using the placeBet() function.  Only player 1 (hot house) can call this function

- After the bet is placed, you can hit deal()

- After the cards are dealt you can see them by viewing the playersCards() array and the dealersCards() array.  For each card a player is dealt, there are two values, one for the card rank (A-K), and the other for suit.  For example, to view the players first card you would call '1,0' to see the rank, and '1,1' to see the suit.  Player card ranks range from 1-13 with 1 being ace and 13 being a king.  Suits are represented as 1-4 with the ascending order being clubs(1), diamonds(2), hearts(3), and spades(4).  The player is initially dealt two cards, and the dealer is dealt one card representing the up card.  You can also see the calculated values of the hands by calling dealerHandValue(), playerHandValue(), dealerFinalCount(), and playerFinalCount().  playerFinalCount() and dealerFinalCount() will give you the maximum value of the hands.  The handValue arrays have two values called as (1,0) and (1,0).  If either hand has an ace, there will be two values in the handValue() arrays.  hand (1,0) will show the value of the hand with aces counted as one, and the second (1,1) will show the hand value with aces counted as 11

- Once you know the value of the hands, it is the player's turn to act.  On the first play, the player can doubleDown(), hitPlayer(), or playerStand().  On all subsequent plays the player can only hit or stand.  If the player busts, the hand will be over (check gameInProgress()), but the dealers cards will be dealt out, even though the player has already lost.  If the player stands, the dealer's card will be automatically dealt out.  You can check the cards that were dealt to the dealer in the dealersCards() array.   If the player doubles down, they will be dealt one card and then it will be the dealer's turn  

- After the player's final action, the hand will end quickly and the winners will be paid out.  The player can then place another bet, or withdraw funds from the contract.  You can see the game outcome at gameOutcome().  A result of 0 means there has been no game.  1 means the dealer won.  2 means the player won, and 3 means there was a push

---

## Running in Streamlit

1. To run the game in streamlit, you must first install streamlit.  You can do this by running the following command in your terminal

```bash
pip install streamlit
```

2. You must also update the .env file with the deployed contract address.  If you used deploy.py to compile and deploy the contract, the .env will have been updated for you.

2. After streamlit is installed, you can run the game by running the following command in your terminal

```bash
streamlit run streamlit.py
```

When the main streamlit page loads, you will see a drop down on the left to select the player account.  Select an account, but be aware that you may not use the same account you used to deploy the contract.  Use the 'Fund' and 'Withdraw' buttons to add playing funds to the contract.  

Once funds are deposited, select an amount to bet and click "Place Bet"

Now click deal and wait for the cards to be dealt.  This can take up to ten seconds.  

**This is because the gas amounts for the transaction are not hard coded, but instead each transaction estimates the gas amount every time it is called.  You can speed it up by changing 'w3.eth.gas_price' values with real known gas amount.

Play Black Jack as usual.  Once you've placed a bet, you can rebet without placing a new bet.  

---

## Contributors

[![Python](https://img.shields.io/badge/David_Lampach-LinkedIn-blue)](https://www.linkedin.com/in/david-lampach-1b21133a/)

[![Python](https://img.shields.io/badge/Michael_Dionne-LinkedIn-blue)](https://www.linkedin.com/in/michael-dionne-b2a1b61b/)


