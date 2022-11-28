import time
import os
import json
import streamlit as st
import helper_functions
from PIL import Image
from web3 import Web3
from web3.gas_strategies.time_based import medium_gas_price_strategy
from web3 import Web3
from pathlib import Path
import dotenv

if 'last_bet_amount' not in st.session_state:
    st.session_state.last_bet_amount = 0  

dotenv.load_dotenv('.env') 

w3 = Web3(Web3.HTTPProvider('HTTP://127.0.0.1:8545/',request_kwargs={'timeout':60}))
contract_address = os.getenv('CURRENT_CONTRACT_ADDRESS')

def load_contract():
    with open('blackjack_abi.json') as f:
        contract_abi = json.load(f)
        contract = w3.eth.contract(
                address=contract_address,
                abi=contract_abi,
                )
        return contract

contract = load_contract()
accounts = w3.eth.accounts

def get_contract_variables():
    bet_min = contract.functions.BET_MIN().call()
    bet_max = contract.functions.BET_MAX().call()
    house_balance = contract.functions.houseBalance().call()
    player_balance = contract.functions.playerBalance().call()

    bet_amount = contract.functions.betAmount().call()

    game_in_progress = contract.functions.gameInProgress().call()
    dealer_card_count = contract.functions.dealerCardCount().call()
    player_card_count = contract.functions.playerCardCount().call()

    player_busted = contract.functions.playerBusted().call()
    dealer_busted =  contract.functions.dealerBusted().call()

    player_stands = contract.functions.playerStands().call()
    dealer_stands =  contract.functions.dealerStands().call()

    final_player_count = contract.functions.finalPlayerCount().call()
    final_dealer_count =  contract.functions.finalDealerCount().call()

    game_outcome  =  contract.functions.gameOutcome().call()

    return bet_min,\
            bet_max,\
            house_balance,\
            player_balance,\
            bet_amount,\
            game_in_progress,\
            dealer_card_count,\
            player_card_count,\
            player_busted,\
            dealer_busted,\
            player_stands,\
            dealer_stands,\
            final_player_count,\
            final_dealer_count,\
            game_outcome


def fund_contract(player_account, player_balance, amount):
    assert(amount <= player_balance, 'Player Balance Is Too Low')
    contract.functions.fundContract(1).transact({'from': player_account, 'value': amount, 'gasPrice': w3.eth.gas_price,})



contract_variables = get_contract_variables()

with st.sidebar:

    col1, col2, col3, col4, col5 = st.columns(5)

    with col1:
        pass 
    with col2:

        if st.button('Coinflip'):
            print('test')
        if st.button('BlackJack'):
            print('test')
    with col3:
        pass 

    player_account = st.selectbox('Please Select Player Account', (accounts))
    fund_amount = st.number_input('Select Amount Of Ether To Fund')
    st.write(f'Player balance in casino --> ', contract_variables[3])

    wallet_balance = w3.eth.getBalance(player_account)
    st.write('Wallet Balance -->', wallet_balance)
    col1, col2 = st.columns(2)

    with col1:

        if st.button('fund'):
            fund_contract(player_account, int(wallet_balance), int(fund_amount))
            st.experimental_rerun()

    with col2:

        if st.button('Withdraw'):

            nonce = w3.eth.getTransactionCount(player_account)
            call_function = contract.functions.playerWithdraw(contract_variables[3]).transact({"from": player_account, 'gasPrice': w3.eth.gas_price})
            st.experimental_rerun()


    bet_amount = st.number_input('Bet Amount')  
    if st.button('Place Bet'):

        st.session_state.last_bet_amount = bet_amount
        contract.functions.placeBet(int(bet_amount)).transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
        st.experimental_rerun()



def get_players_card_list(card_count=0):

    card_size = 3
    width_multiplier = 25
    height_multiplier = 35


    players_cards = []
    i=1
    while i <= card_count:  #gets player card count from contract_variables

        card_rank =  contract.functions.playersCards(i,0).call()
        card_suit =  contract.functions.playersCards(i,1).call()
        card_path = helper_functions.get_card_image_string(card_rank,card_suit)
        card_image = Image.open(card_path)
        card_image = card_image.resize(((card_size * width_multiplier), (card_size * height_multiplier)))
        players_cards.append([card_rank, card_suit, card_image])  
        i = i + 1

    return players_cards


def get_dealers_card_list(card_count=0):

    card_size = 3
    width_multiplier = 25
    height_multiplier = 35


    dealers_cards = []
    i=1
    while i <= card_count:  #gets dealer card count from contract_variables

        card_rank =  contract.functions.dealersCards(i,0).call()
        card_suit =  contract.functions.dealersCards(i,1).call()
        card_path = helper_functions.get_card_image_string(card_rank,card_suit)
        card_image = Image.open(card_path)
        card_image = card_image.resize(((card_size * width_multiplier), (card_size * height_multiplier)))
        dealers_cards.append([card_rank, card_suit, card_image])  
        i = i + 1

    return dealers_cards



####################################################
###               Main Page Views               ####
####################################################



if (contract_variables[5] == 0) & (contract_variables[6] < 2): #contract_variables[5] is game_in_progress. [6] is deal_card_count

    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.markdown('<center>Pseudorandom Casino</center>', unsafe_allow_html=True)


    col1, col2, col3, col4, col5, col6, col7 = st.columns(7)

    with col4:

        st.write('')
        if st.button('Deal'):

            contract.functions.deal().transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
            st.experimental_rerun()

    st.write('')
    st.write('')
    st.write('')
    st.write('')
    st.markdown(f'<center>Current Bet Amount --> {contract_variables[4]}</center>', unsafe_allow_html=True)


if (contract_variables[5] == 0) & (contract_variables[6] > 1):  #contract_variables[5] is game_in_progress. [6] is deal_card_count




    players_cards = get_players_card_list(contract_variables[7])
    dealers_cards = get_dealers_card_list(contract_variables[6])



    st.subheader(f'Dealer Has {contract_variables[13]}')

    col1, col2, col3, col4, col5, col6, col7, col8 = st.columns(8)
    i=1
    for card in dealers_cards:

        exec('col' + str(i) + '.image(card[2])')
        time.sleep(.5) 
        i=i+1



    st.subheader(f'Player Has {contract_variables[12]}')
    col1, col2, col3, col4, col5, col6, col7, col8 = st.columns(8)


    i=1
    for card in players_cards:

        exec('col' + str(i) + '.image(card[2])')
        i=i+1

    if st.button('Rebet'):

        if contract_variables[4] > 0:

            last_bet_amount = bet_amount

        else:

            last_bet_amount = st.session_state.last_bet_amount
            contract.functions.placeBet(int(last_bet_amount)).transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})

        contract.functions.deal().transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
        st.experimental_rerun()


if contract_variables[5] == 1:  #contract_variables[5] is game outcome

    st.markdown(f'</center>bet amount is --> {contract_variables[4]}', unsafe_allow_html=True)

    players_cards = get_players_card_list(contract_variables[7])
    dealers_cards = get_dealers_card_list(contract_variables[6])



    st.subheader(f'Dealer Has {contract_variables[13]}')

    col1, col2, col3, col4, col5, col6, col7 , col8 = st.columns(8)
    i=1
    for card in dealers_cards:

        exec('col' + str(i) + '.image(card[2])')
        time.sleep(.5) 
        i=i+1




    st.subheader(f'Player Has {contract_variables[12]}')
    col1, col2, col3, col4, col5, col6, col7, col8 = st.columns(8)


    i=1
    for card in players_cards:

        exec('col' + str(i) + '.image(card[2])')
        i=i+1



    if  st.button('Hit'):

        contract.functions.hitPlayer().transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
        st.experimental_rerun()

    if  st.button('Double Down'):

        contract.functions.doubleDown().transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
        st.experimental_rerun()


    if st.button('Stand'):

        contract.functions.playerStand().transact({'from': player_account, 'gasPrice': w3.eth.gas_price,})
        st.experimental_rerun()

if contract_variables[14] == 0:

    st.subheader('Play a game')

if contract_variables[14] == 1:

    st.subheader('Dealer Wins')

if contract_variables[14] == 2:

    st.subheader('Player Wins')

if contract_variables[14] == 3:

    st.subheader('Game is a push')
