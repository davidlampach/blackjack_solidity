# Description

This code implements two smart contracts that enables players to play Black Jack or Coin Flip.  Both Black Jack and Coin Flip are games of chance where players place wagers on the outcome of the game.  The games are entirely playable in the smart contracts and do not rely on any particular user interface.  We provide a Streamlit interface for example purposes.

This code uses recent block hashes to generate "pseudorandom" numbers.  Do not deploy this contract for real money use.  Miners can manipulate the block hashes and control the outcome of the game.  If you wish to deploy this contract for real money use, you must swap out the pseudorandom number generator for a true random number generator.  True randomness is not possible on a block chain, so an off chain oracle is needed.  

---

## Dependencies

[![Python](https://img.shields.io/badge/Python-3.9.12-blue)](https://www.python.org/downloads/release/python-3912/)

[![Solidity](https://img.shields.io/badge/Solidity-0.8.17-blue)](https://docs.soliditylang.org/en/v0.8.9/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

### Python libraries

[![OS](https://img.shields.io/badge/OS-Windows%2010%20Pro%20x64-blue)](https://www.microsoft.com/en-us/software-download/windows10)

[![Random](https://img.shields.io/badge/Random_Number-0.0.3-blue)](https://pypi.org/project/random-number/)

[![Web3](https://img.shields.io/badge/Web3-5.24.0-blue)](https://web3py.readthedocs.io/en/stable/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

[![JSON](https://img.shields.io/badge/Json-2.0.9-blue)](https://docs.python.org/3/library/json.html)

[![PIL](https://img.shields.io/badge/PIL-1.1.6-blue)](https://pypi.org/project/PIL/)

---

## Installation

1. ###  [deploy.py](https://github.com/davidlampach/blackjack_solidity/blob/master/deploy.py) will also require the [sol_c_x Python compiler](https://solcx.readthedocs.io/en/latest/)

        pip install py-solc-x

2. ### The entirety of these games run with smart contracts written in solidity.  They are [blackjack.sol](https://github.com/davidlampach/blackjack_solidity/blob/master/blackjack.sol) and [coinflip.sol](https://github.com/davidlampach/blackjack_solidity/blob/master/blackjack.sol) respectively.  It is best to familiarize oneself with these contracts in a GUI compiler like remix  

3. ### Install Git

   [![Git](https://img.shields.io/badge/Git-2.33.1-blue)](https://git-scm.com/downloads) is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

   Download and install Git from [here](https://git-scm.com/downloads).

## Running just the Solidity contracts

1. ### No GUI is necessary to play the games.  You can load the blackjack.sol and coinflip.sol files in the compiler of your choice.  They both use [![Solidity](https://img.shields.io/badge/Solidity-0.8.17-blue)](https://docs.soliditylang.org/en/v0.8.9/)

2. ### After you've compiled the contracts you can deploy them on any Ethereum network

3. ### blackjack.sol usage

- #### To play this game, you must first fund the House portion of the contract.  Call the fundContract() payable function with 0 as the player parameter, and some amount of ethereum as the payable value.  This will deposit money into the house side of the contract.  You can check how much the house has in the contract by calling houseBalance()  

- #### Next fund the player side, but call the same function with parameter 1 and however much you want the player to buy into the game for.  You are now ready to play a game.  You can check how much the player has in the contract by calling playerBalance()

- #### To play a hand, bet as much as you like using the placeBet() function.  Only player 1 (hot house) can call this function

- #### After the bet is placed, you can hit deal()

- #### After the cards are dealt you can see them by viewing the playersCards() array and the dealersCards() array.  For each card a player is dealt, there are two values, one for the card rank (A-K), and the other for suit.  For example, to view the players first card you would call '1,0' to see the rank, and '1,1' to see the suit.  Player card ranks range from 1-13 with 1 being ace and 13 being a king.  Suits are represented as 1-4 with the ascending order being clubs(1), diamonds(2), hearts(3), and spades(4).  The player is initially dealt two cards, and the dealer is dealt one card representing the up card.  You can also see the calculated values of the hands by calling dealerHandValue(), playerHandValue(), dealerFinalCount(), and playerFinalCount().  playerFinalCount() and dealerFinalCount() will give you the maximum value of the hands.  The handValue arrays have two values called as (1,0) and (1,0).  If either hand has an ace, there will be two values in the handValue() arrays.  hand (1,0) will show the value of the hand with aces counted as one, and the second (1,1) will show the hand value with aces counted as 11

- #### Once you know the value of the hands, it is the player's turn to act.  On the first play, the player can doubleDown(), hitPlayer(), or playerStand().  On all subsequent plays the player can only hit or stand.  If the player busts, the hand will be over (check gameInProgress()), but the dealers cards will be dealt out, even though the player has already lost.  If the player stands, the dealer's card will be automatically dealt out.  You can check the cards that were dealt to the dealer in the dealersCards() array.   If the player doubles down, they will be dealt one card and then it will be the dealer's turn  

- #### After the player's final action, the hand will end quickly and the winners will be paid out.  The player can then place another bet, or withdraw funds from the contract.  You can see the game outcome at gameOutcome().  A result of 0 means there has been no game.  1 means the dealer won.  2 means the player won, and 3 means there was a push

---

## Running in Streamlit

1. ### To run the games in streamlit, you must first install streamlit.  You can do this by running the following command in your terminal

```bash
pip install streamlit
```

2. ### After streamlit is installed, you can run the games by running the following command in your terminal

```bash
streamlit run streamlit.py
```

---

## Contributors

[![Python](https://img.shields.io/badge/David_Lampach-LinkedIn-blue)](https://www.linkedin.com/in/david-lampach-1b21133a/)

[![Python](https://img.shields.io/badge/Michael_Dionne-LinkedIn-blue)](https://www.linkedin.com/in/michael-dionne-b2a1b61b/)
