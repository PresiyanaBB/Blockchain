// SPDX-License-Identifier: GPI3
pragma solidity > 0.7.0 <= 0.9.0;

contract Casino{
    address admin;
    uint256 casinoBalance = 0;
    uint8 casinoLimit = 50;

    mapping(address => User) bets;
    address[] participants;

    struct User{
        uint256 amount;
        uint16 num;
    }

    constructor(){
        admin = msg.sender;
    }

    modifier isAdmin{
        require(msg.sender == admin, "You need to be an admin to withdraw the winners!");
        _;
    }

    fallback() external {}

    function acceptBet(uint16 _num) public payable{
        require(participants.length < casinoLimit, "Casino is full.");
        require(!hasBet(msg.sender), "You already placed a bet.");
        require(_num > 0 && _num < 1000, "Number must be between 0 and 1000!");
        require(msg.value > 100 gwei, "Bet amount must be more than 100 Gwei!");

        User memory user = User(msg.value, _num);
        participants.push(msg.sender);
        bets[msg.sender] = user;

        casinoBalance += msg.value;
    }

    function getMagicNum() private view returns(uint16){

    }

    function withdrawWinners() public isAdmin{}

    function determineWinners() private view{}

    function payWinners() private {}

    function reset() private isAdmin{}

    function getBalance() public view returns(uint256){
        return casinoBalance;
    }

    function getCasinoLimit() public view returns(uint8){
        return casinoLimit;
    }

    function numOfBets() public view returns(uint8){
        return uint8(participants.length);
    }

    function getMyBet() public view returns(User memory){
        require(hasBet(msg.sender), "You are yet to bet.");
        return bets[msg.sender];
    }

    function hasBet(address _player) private view returns(bool){
        uint8 participantsCount = uint8(participants.length);

        for (uint8 i = 0; i < participantsCount; i++){
            if(_player == participants[i]){
                return true;
            }
        }

        return false;
    }
}