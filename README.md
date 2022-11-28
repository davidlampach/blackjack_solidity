## Description

This code implements two smart contracts that enables players to play Black Jack or Coin Flip.  Both Black Jack and Coin Flip are games of chance where players place wagers on the outcome of the game.  The games are entirely playable in the smart contracts and do not rely on any particular user interface.  We provide a Streamlit interface for example purposes.

This code uses recent block hashes to generate "pseudorandom" numbers.  Do not deploy this contract for real money use.  Miners can manipulate the block hashes and control the outcome of the game.  If you wish to deploy this contract for real money use, you must swap out the pseudorandom number generator for a true random number generator.  True randomness is not possible on a block chain, so an off chain oracle is needed.  


## Dependencies

[![Python](https://img.shields.io/badge/Python-3.9.12-blue)](https://www.python.org/downloads/release/python-3912/)

[![Solidity](https://img.shields.io/badge/Solidity-0.8.9-blue)](https://docs.soliditylang.org/en/v0.8.9/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

### Python libraries

[![OS](https://img.shields.io/badge/OS-Windows%2010%20Pro%20x64-blue)](https://www.microsoft.com/en-us/software-download/windows10)

[![Random](https://img.shields.io/badge/Random-True%20Random-blue)](https://www.random.org/)
     
[![Web3](https://img.shields.io/badge/Web3-5.24.0-blue)](https://web3py.readthedocs.io/en/stable/)

[![Streamlit](https://img.shields.io/badge/Streamlit-0.88.0-blue)](https://docs.streamlit.io/en/stable/)

[![Time](https://img.shields.io/badge/Time-2021--12--15%2016%3A00%3A00-blue)](https://www.timeanddate.com/worldclock/)

[![Json](https://img.shields.io/badge/Json-2.0.9-blue)](https://docs.python.org/3/library/json.html)
=

# get PIL 





other Python libraries:

- [web3](https://web3py.readthedocs.io/en/stable/)
- [eth-brownie](https://eth-brownie.readthedocs.io/en/stable/)
- [streamlit](https://docs.streamlit.io/en/stable/)
- [os] 
- [random]
- [time]
- [json]

os  
json  
time  
PIL  

deploy.py will also require the sol_c_x Python compiler.


## Installation

The entirety of these games run with smart contracts written in solidity.  They are **blackjack.sol** and **coinflip.sol** respectively.  It is best to familiarize oneself with these contracts in a GUI compiler like remix.  

INPUT GIT INSTALL INSTRUCTIONS HERE





## Running just the Solidity contracts

No GUI is necessary to play the games.  You can load the blackjack.sol and coinflip.sol files in the compiler of your choice.  They both use Solidity Pragma 0.8.17.  

After you've compiled the contracts you can deploy them on any Ethereum network.  

blackjack.sol usage:

1)  To play this game, you must first fund the House portion of the contract.  Call the fundContract() payable function with 0 as the player parameter, and some amount of ethereum as the payable value.  This will deposit money into the house side of the contract.  You can check how much the house has in the contract by calling houseBalance().  

2)  Next fund the player side, but call the same function with parameter 1 and however much you want the player to buy into the game for.  You are now ready to play a game.  You can check how much the player has in the contract by calling playerBalance().

3)  To play a hand, bet as much as you like using the placeBet() function.  Only player 1 (hot house) can call this function.

4)  After the bet is placed, you can hit deal().

5)  After the cards are dealt you can see them by viewing the playersCards() array and the dealersCards() array.  For each card a player is dealt, there are two values, one for the card rank (A-K), and the other for suit.  For example, to view the players first card you would call '1,0' to see the rank, and '1,1' to see the suit.  Player card ranks range from 1-13 with 1 being ace and 13 being a king.  Suits are represented as 1-4 with the ascending order being clubs(1), diamonds(2), hearts(3), and spades(4).  The player is initially dealt two cards, and the dealer is dealt one card representing the up card.  You can also see the calculated values of the hands by calling dealerHandValue(), playerHandValue(), dealerFinalCount(), and playerFinalCount().  playerFinalCount() and dealerFinalCount() will give you the maximum value of the hands.  The handValue arrays have two values called as (1,0) and (1,0).  If either hand has an ace, there will be two values in the handValue() arrays.  hand (1,0) will show the value of the hand with aces counted as one, and the second (1,1) will show the hand value with aces counted as 11.

6)  Once you know the value of the hands, it is the player's turn to act.  On the first play, the player can doubleDown(), hitPlayer(), or playerStand().  On all subsequent plays the player can only hit or stand.  If the player busts, the hand will be over (check gameInProgress()), but the dealers cards will be dealt out, even though the player has already lost.  If the player stands, the dealer's card will be automatically dealt out.  You can check the cards that were dealt to the dealer in the dealersCards() array.   If the player doubles down, they will be dealt one card and then it will be the dealer's turn.  

7)  After the player's final action, the hand will end quickly and the winners will be paid out.  The player can then place another bet, or withdraw funds from the contract.  You can see the game outcome at gameOutcome().  A result of 0 means there has been no game.  1 means the dealer won.  2 means the player won, and 3 means there was a push.


## Running in Streamlit

To run in Streamlit, first deploy the contracts.

then run 'streamlit run streamlit.py'

---

## Contributors

[![Python](https://img.shields.io/badge/David_Lampach-LinkedIn-blue)](https://www.linkedin.com/in/david-lampach-1b21133a/)

[![Python](https://img.shields.io/badge/Michael_Dionne-LinkedIn-blue)](https://www.linkedin.com/in/michael-dionne-b2a1b61b/)


