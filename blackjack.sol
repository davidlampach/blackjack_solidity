pragma solidity ^0.8.7;

import "Strings.sol";
//import "Strings.sol";
//import "Strings.sol";

contract BlackJack {

    bool internal locked;
    uint public gameInProgress          = 0; //Is a game currently in progress?
    uint constant public BET_MIN        = 1 wei;    // The minimum bet
    uint constant public BET_MAX        = 1 ether; // The maximum bet
    uint public houseBalance            = 0;  //How much money casino has behind the game?
    uint public playerBalance           = 0;  //How much money does the player have in casino?
    uint public betAmount               = 0;  //How much has the player wagered?
    uint randomNum                      = 0;  //A random number
    uint public playerCardCount         = 0;  //How many cards does the player have?
    uint public dealerCardCount         = 0;  //How many cards does the dealer have?
    uint public playerBusted            = 0;  //Did the player bust?
    uint public dealerBusted            = 0;  //Did the dealer bust?
    uint public finalPlayerCount        = 0;  //What is the maximum count of the player's hand?
    uint public finalDealerCount        = 0;  //What is the maximum count of the dealers hand?
    uint public playerStands            = 0;  //Did the player stand?
    uint public dealerStands            = 0;  //Did the dealer stand?
    uint public gameOutcome             = 0;  //Outcome of last game (0-No Outcome 1-House wins  2-Player wins 3- Push
    uint[2][16] public playersCards;
    uint[2][16] public dealersCards;
    
    
    
    uint[2][2] public playerHandValue;
    uint[2][2] public dealerHandValue;
    uint[2][4] dealtCards;

    uint suit                           = 0;  
    uint rank                           = 0;

    uint nonce = 0;
            
    // Players' addresses

    address  playerWallet = address(0x0);
    address  houseWallet = address(0x0);


    function getSlice(uint256 begin, uint256 end, string memory text) internal pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);    
    }

    
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    // Global mutex modifier
    modifier mutex() { //To prevent reentrancy attacks

        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;

    }

    // Returns a pseudorandom number from 0 to the largest integer allowed in Solidity
    function getRandom() internal returns(uint) {
        // increase nonce
        nonce++; 
        randomNum =  uint(keccak256(abi.encodePacked((block.number+(nonce*3)), msg.sender, nonce))) % 1157920892373161954235709850086879078532699846656405640394575840079131296399;
        nonce++;
        return randomNum;
    }
 
    // Player registration function
    modifier validPlayer(uint house_or_player) {

        require(houseWallet == address(0x0) || playerWallet == address(0x0) || msg.sender == houseWallet || msg.sender == playerWallet, "Registration address is not valid");
        require(house_or_player == 0 || house_or_player == 1, "Player must be house(0) or player(1)");
        _;

    }
    
    //Add ethereum to the contract
    function fundContract(uint house_or_player) public payable validPlayer(house_or_player) {
        
            
        if (house_or_player == 0) {
            
            require((msg.sender == houseWallet || houseWallet == address(0x0)) && msg.sender != playerWallet, "Sender address must be houseWallet");
            houseWallet = msg.sender;
            houseBalance = houseBalance + msg.value;
        }

        if (house_or_player == 1) {

            require((msg.sender == playerWallet || playerWallet == address(0x0)) && msg.sender != houseWallet, "Sender address must be playerWallet");
            playerWallet  = msg.sender;
            playerBalance = playerBalance + msg.value;               
        }
    }

    //Player withdraw money function.  Player can withdraw all funds at any time, except fund already bet in a game in progress
    modifier canPlayerWithdraw(uint amount) {

        require(playerBalance > 0, "Player has no balance to withdraw");
        require(msg.sender == playerWallet, "Only player can use this function withdraw");
        require(amount <= playerBalance, "You are requesting more than the player wallet contains");
        _;
    }

    modifier isPlayer() {

        require(msg.sender == playerWallet);
        _;

    }
    
    function playerWithdraw(uint amount) public payable canPlayerWithdraw(amount) mutex() {

        playerBalance = playerBalance - amount;
        payable(playerWallet).transfer(amount);

    }

    // Player place bet function

    modifier validBet(uint _betAmount) {
   
        require(_betAmount >= BET_MIN && _betAmount <= BET_MAX);
        require(_betAmount <= playerBalance, "Bet amount is more than player balance");
        require(msg.sender == playerWallet, "Only player can place bet");
        require(betAmount == 0, "Bet has already been placed");
        _;

    }

    modifier _gameNotInProgress {

        require(gameInProgress == 0, "You cannot bet while game is in progress");
        _;
    }

    function placeBet(uint _betAmount) public validBet(_betAmount) mutex() {

        playerBalance = playerBalance - _betAmount;
        betAmount = _betAmount;

    }


    //Get numCards amount of cards
    function getCards(uint numCards) internal {

        string memory ranNumAsString = "";
        string memory slicedString = "";
        uint ranNumStringLength;
        uint j = 1;
        uint cardInt = 0;


        while (j <= numCards) {

            uint start = 3;
            uint end = 4;
            rank = 0;
            suit = 0;
            
            randomNum = getRandom();
            ranNumAsString = Strings.toString(randomNum);
            slicedString = getSlice(start, end, ranNumAsString);
            cardInt = stringToUint(slicedString);
            ranNumStringLength = bytes(ranNumAsString).length;

            while ((cardInt < 1 || cardInt > 13) && (start < (ranNumStringLength - 3))) {

                start = start + 2;
                end = end + 2;
                slicedString = getSlice(start, end, ranNumAsString);
                cardInt = stringToUint(slicedString);

                if (start > (ranNumStringLength - 3)) {
            
                    start = 3;
                    end = 4;
                    randomNum = getRandom();
                    ranNumAsString = Strings.toString(randomNum);
                    slicedString = getSlice(start, end, ranNumAsString);
                    cardInt = stringToUint(slicedString);
                    ranNumStringLength = bytes(ranNumAsString).length;
            
                }
            }

            rank = cardInt;
            start = start + 2;
            end = end + 2;
            slicedString = getSlice(start, end, ranNumAsString);
            cardInt = stringToUint(slicedString);



            while ((cardInt < 1 || cardInt > 4) && (start < (ranNumStringLength - 3))) {

                start = start + 1;
                end = start;
                slicedString = getSlice(start, end, ranNumAsString);
                cardInt = stringToUint(slicedString);

                if (start > (ranNumStringLength - 3)) {
            
                    start = 4;
                    end = 4;
                    randomNum = getRandom();
                    ranNumAsString = Strings.toString(randomNum);
                    slicedString = getSlice(start, end, ranNumAsString);
                    cardInt = stringToUint(slicedString);
                    ranNumStringLength = bytes(ranNumAsString).length;
                }
            }
            



            suit = cardInt;  

            dealtCards[j][0] = rank;
            dealtCards[j][1] = suit;
            j = j + 1;

        }
    }       

    function numCardsInArray (uint[2][16] memory array) internal pure returns(uint) {

        uint i = 0;
        uint count = 0;
           
        while (i < 16) {
            if (array[i][0] != 0) {
                count = count + 1;                           
            }
            i = i + 1;
        }

        return count;
        
    } 



    function pushToPlayer(uint _rank, uint _suit, uint index) internal {

        playersCards[index][0] = _rank;
        playersCards[index][1] = _suit;
        playerCardCount = numCardsInArray(playersCards);

    }


    function pushToDealer(uint _rank, uint _suit, uint index) internal {

        dealersCards[index][0] = _rank;
        dealersCards[index][1] = _suit;
        dealerCardCount = numCardsInArray(dealersCards);

    }

    modifier playerHasBet() {

        require(betAmount > 0, "you must bet before the cards are dealt");
        _;
    }

    function deal() public mutex() playerHasBet {
        
        //Reset the state variables for new hand
        gameOutcome = 0;
        gameInProgress = 1;
        playerStands = 0;
        playerBusted = 0;
        dealerBusted = 0;
        playerStands = 0;
        dealerStands = 0;
        finalDealerCount = 0;
        finalPlayerCount = 0;
        playerHandValue[1][0] = 0;
        playerHandValue[1][1] = 0;

        //Everything in this FOR statement resets all the player and dealer cards to 0
        for (uint256 i = 1; i <= 15; i++) {  
            
            playersCards[i][0] = 0;
            playersCards[i][1] = 0;
            dealersCards[i][0] = 0;
            dealersCards[i][1] = 0;

            if (i < 4) {

                dealtCards[i][0] = 0;
                dealtCards[i][1] = 0;

            }

        }



        getCards(3);   //Only first deal gets 3 cards  --  2 for player and 1 (up card) for dealer
        dealtCards = replaceDuplicates(dealtCards);  //Scans the frist 3 dealt cards for duplicates and redraws cards if any two cards are exactly the same (rank and suit).
        pushToPlayer(dealtCards[1][0], dealtCards[1][1], 1);
        pushToDealer(dealtCards[2][0], dealtCards[2][1], 1);
        pushToPlayer(dealtCards[3][0], dealtCards[3][1], 2);
        sumPlayersCards();
        sumDealersCards();
        evaluateDealerHand();  
        evaluatePlayerHand();  

        if (playerHandValue[1][1] == 21) {   // Evaluates if player is dealt blackjack.  If TRUE, game is ended.

            playerHasBlackJack();
        }
        

    }

    modifier _gameInProgress() {
        require(gameInProgress == 1, "Game must be in progress");
        _;
    }

    modifier _playerBusted() {
        require(playerBusted == 0, "You've already busted");
        _;
    }

    //Function to draw one card for the player.  Evaluates the new hand.
    function hitPlayer() public _gameInProgress() _playerBusted() didPlayerStand() {
        
        uint index = numCardsInArray(playersCards);
        getCards(1);
        
        for (uint256 i = 1; i <= 11; i++) {

            while (((playersCards[i][0] == dealtCards[1][0])  &&  (playersCards[i][0] == dealtCards[1][1])) || ((dealersCards[i][0] == dealtCards[1][0]) && (dealersCards[i][1] == dealtCards[1][1]))) {

                    getCards(1);

            }
        }     
    
        pushToPlayer(dealtCards[1][0], dealtCards[1][1], (index + 1));
        sumPlayersCards();
        evaluatePlayerHand();

    }
    
    
    //Function to draw one card for the dealer.  Evaluates the new hand.
    modifier dealerMustStay() {
        require(finalDealerCount < 17, "Dealer must stand on 17 and higher");
        _;
    }

    modifier playerBustedOrStood () {

        require((playerBusted == 1) || (playerStands == 1));
        _;
    }

    function hitDealer() public dealerMustStay() playerBustedOrStood() {
        
        uint index = numCardsInArray(dealersCards);
        getCards(1);
    
        for (uint256 i = 1; i <= 11; i++) {

            while (((playersCards[i][0] == dealtCards[1][0])  &&  (playersCards[i][0] == dealtCards[1][1])) || ((dealersCards[i][0] == dealtCards[1][0]) && (dealersCards[i][1] == dealtCards[1][1]))) {

                    getCards(1);

            }
        }    
    
        pushToDealer(dealtCards[1][0], dealtCards[1][1], (index + 1));
        sumDealersCards();
        evaluateDealerHand();

    }  

    //Counts the players hand value.  Creates [i][0] where aces are 1 and [i][1] where aces are 11.
    function sumPlayersCards() internal {

        uint result = 0;
        uint aceAlready = 0;

        playerCardCount = numCardsInArray(playersCards);

        for (uint256 i = 1; i <= playerCardCount; i++) {

            if (playersCards[i][0] > 9) {
                result = result + 10;
            }
            if (playersCards[i][0] < 10) { 
                result = result + playersCards[i][0];
            }
            if (playersCards[i][0] == 1) {
                aceAlready = 1;           
            }
        }

        playerHandValue[1][0] = result;
        playerHandValue[1][1] = result;
        
        if (aceAlready == 1) {
            
            playerHandValue[1][1] = playerHandValue[1][1] + 10;
        }
    }

    //Counts the dealers hand value.  Creates [i][0] where aces are 1 and [i][1] where aces are 11.
    function sumDealersCards() internal {

        uint result = 0;
        uint aceAlready = 0;

        dealerCardCount = numCardsInArray(dealersCards);

        for (uint256 i = 1; i <= dealerCardCount; i++) {

            if (dealersCards[i][0] > 9) {
                result = result + 10;
            }
            if (dealersCards[i][0] < 10) { 
                result = result + dealersCards[i][0];
            }
            if (dealersCards[i][0] == 1) {
                aceAlready = 1;           
            }
        }

        dealerHandValue[1][0] = result;
        dealerHandValue[1][1] = result;
        
        if (aceAlready == 1) {
            
            dealerHandValue[1][1] = dealerHandValue[1][1] + 10;
        }
    }

    function evaluatePlayerHand() internal {



        if ((playerHandValue[1][0] > 21) && (playerHandValue[1][1] > 21)) {

            playerBusted = 1;
            gameInProgress = 0;

            if (playerHandValue[1][0] <= playerHandValue[1][1]) {
                finalPlayerCount = playerHandValue[1][0];
            }
            if (playerHandValue[1][0] > playerHandValue[1][1]) {
                finalPlayerCount = playerHandValue[1][1];
            }

            houseBalance = houseBalance + betAmount;
            betAmount = 0;
            gameOutcome = 1;

            while (finalDealerCount < 17) {

                hitDealer();

            } 

        }
        if ((playerHandValue[1][0] <= 21) && (playerHandValue[1][1] > 21)) {
            finalPlayerCount = playerHandValue[1][0];
        }
        if ((playerHandValue[1][0] > 21) && (playerHandValue[1][1] <= 21)) {
            finalPlayerCount = playerHandValue[1][1];
        }
        if ((playerHandValue[1][0] <= 21) && (playerHandValue[1][1] <= 21)) {
            if (playerHandValue[1][0] > playerHandValue[1][1]) {
                 finalPlayerCount = playerHandValue[1][0];
            }
            if (playerHandValue[1][0] <= playerHandValue[1][1]) {
                finalPlayerCount = playerHandValue[1][1];
            }
        }
    }

    function evaluateDealerHand() internal {


        if ((dealerHandValue[1][0] <= 21) && (dealerHandValue[1][1] > 21)) {
            finalDealerCount = dealerHandValue[1][0];
        }
        if ((dealerHandValue[1][0] > 21) && (playerHandValue[1][1] <= 21)) {
            finalDealerCount = dealerHandValue[1][1];
        }
        if ((dealerHandValue[1][0] <= 21) && (dealerHandValue[1][1] <= 21)) {
            
            if (dealerHandValue[1][0] > dealerHandValue[1][1]) {
                 finalDealerCount = dealerHandValue[1][0];
            }
            if (dealerHandValue[1][0] <= dealerHandValue[1][1]) {
                finalDealerCount = dealerHandValue[1][1];
            }
        }

        if ((dealerHandValue[1][0] > 16) || (dealerHandValue[1][1] > 16)) {

            if ((dealerHandValue[1][0] > 21) && (dealerHandValue[1][1] > 21)) {

                dealerBusted = 1;
                gameInProgress = 0;
                
                if (dealerHandValue[1][0] <= dealerHandValue[1][1]) {
                finalDealerCount = dealerHandValue[1][0];
                }
                if (dealerHandValue[1][0] > dealerHandValue[1][1]) {
                finalDealerCount = dealerHandValue[1][1];
                }
                if ((playerBusted == 0) && (playerStands == 1)) {
                
                    playerBalance = playerBalance + (betAmount * 2);
                    houseBalance = houseBalance - betAmount;
                    betAmount = 0;
                    gameOutcome = 2;
                }
            }

            if (dealerBusted != 1) {

                gameInProgress = 0;
                dealerStands = 1;
                evaluateWinner();

            }

            
        }
    }

    function evaluateWinner() internal {


        if (playerBusted == 1) {

            houseBalance = houseBalance + betAmount;
            betAmount = 0;
            gameOutcome = 1;

        }
        if ((finalDealerCount > finalPlayerCount) && (playerBusted == 0)) {

            houseBalance = houseBalance + betAmount;
            betAmount = 0;
            gameOutcome = 1;

        }

        if ((finalPlayerCount > finalDealerCount) && (playerBusted == 0)) {

            playerBalance = playerBalance + (betAmount * 2);
            houseBalance = houseBalance - betAmount;
            betAmount = 0;
            gameOutcome = 2;
        }

        if ((finalDealerCount == finalPlayerCount) && (playerBusted == 0)) {

            gameIsPushed();
            gameOutcome = 3;

        }

    }

    modifier didPlayerStand() {

        require(playerStands == 0, "Player has already stood");
        _;
    }

    function playerStand() public didPlayerStand() _playerBusted() _gameInProgress() {

        playerStands = 1;
        evaluatePlayerHand();

        while (gameInProgress == 1) {

            hitDealer();

        }

    }


    modifier didDealerStand() {

        require(dealerStands == 0, "Dealer has already stood");
        _;
    }

    function dealerStand() internal didDealerStand() {

        gameInProgress = 0;
        dealerStands = 1;
        evaluateDealerHand();

    }

    function replaceDuplicates(uint[2][4] memory array) internal returns (uint[2][4] memory) {


        while ((array[1][0] == array[2][0]) && (array[1][1] == array[2][1])) {

            getCards(1);
            array[2][0] = dealtCards[1][0];
            array[2][1] = dealtCards[1][1];
                
        }
            
        while ((array[2][0] == array[3][0]) && (array[2][1] == array[3][1])) {

            getCards(1);
            array[3][0] = dealtCards[1][0];
            array[3][1] = dealtCards[1][1];
                           
        }

        return array;

    }

    function playerHasBlackJack() internal {


        if ((dealersCards[1][0] == 1) || (dealerHandValue[1][0] == 10)) {

            getCards(1);
            for (uint256 i = 1; i <= 1; i++) {
            while ((playersCards[i][0] == dealtCards[1][0]) || (dealersCards[i][0] == dealtCards[1][0])) {
	            if ((playersCards[i][1] == dealtCards[1][1]) || (dealersCards[i][1] == dealtCards[1][1])) {
                    getCards(1);
                }
            }
            }

            pushToDealer(dealtCards[1][0], dealtCards[1][1], 2);
            sumDealersCards();
            evaluateDealerHand();

            if (dealerHandValue[1][1] == 21) {

                gameIsPushed();
                gameOutcome = 3;

            }

            if (dealerHandValue[1][1] != 21) {

                playerBalance = playerBalance + betAmount + ((betAmount * 3) / 2);
                houseBalance = houseBalance - ((betAmount * 3) / 2);
                betAmount = 0;
                gameOutcome = 2;

            }  

        }    
    }
    


    
    function gameIsPushed() internal {

        playerBalance = playerBalance + betAmount;
        betAmount = 0;
        gameOutcome = 3;
    }


    modifier _playerHasFunds() {

        require(playerBalance >= (betAmount * 2), "You don't have enough funds.");
        _;

    }
    
    modifier _playerFirstAction() {

        require(playerCardCount == 2, "You can only double down on first action");
        _;

    }

    function doubleDown() public _gameInProgress() _playerFirstAction() _playerHasFunds {

        playerBalance = playerBalance - betAmount;
        betAmount = betAmount * 2;

        hitPlayer();
        playerStand();

    }



// End Contract    
}
