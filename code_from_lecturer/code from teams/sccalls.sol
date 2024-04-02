// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Sender {

    uint256 dfasdfasdf = 0;

    event MoneySent(uint256 _amount);
    event ReturnedData(bool _success, bytes _data);
    
    fallback() external payable {}
    receive()  external payable {}
    
    function getNum() public view returns(uint256){
        return dfasdfasdf;
    }

    // .transfer() high level func - sends 2300! terminates execution ina case of error; cascades exceptions
    function transferMoney(address  _receiverAddr, uint256 _amount) public {
       payable(_receiverAddr).transfer(_amount);
       emit MoneySent(_amount);
    }

    // .send() low level func (boolean result); sends 2300 gas
    function sendMoney(address payable _receiverAddr, uint256 _amount) public  returns(bool){
       bool success = _receiverAddr.send(_amount);    

        if(success) {
            emit MoneySent(_amount);
        }
        else {
           // require(success,"s4upi se!");
        }

       return success;
    }

    function callSC(address payable _receiverAddr, uint256 _amount, uint256 _gas) public {
        (bool success, bytes memory data) = 
            _receiverAddr.call
                {value: _amount , gas: _gas}(abi.encodeWithSignature("increment()"));
        
        emit ReturnedData(success, data);
    }

    function callFunc(address payable _receiverAddr, uint256 _num1, uint256 _num2) public returns(uint256){
        (bool success, bytes memory data) = 
            _receiverAddr.call
                (abi.encodeWithSignature("sum(uint256,uint256)",_num1,_num2));
        
        emit ReturnedData(success, data);
        return abi.decode(data, (uint256));
    }

    function dcall(address payable _receiverAddr) public {
       (bool success, bytes memory data) = 
            _receiverAddr.delegatecall(abi.encodeWithSignature("increment()"));
        emit ReturnedData(success, data);
    }

    // cascades exception - terminates transaction
    function namedCall(address payable _receiverAddr) public pure returns(uint8){
        Receiver receiverSC = Receiver(_receiverAddr);

        // uint256 balance = receiverSC.getBalance();
        // receiverSC.increment();

        uint8 num = receiverSC.exampleOverflow();

        return num;
    }
    
}

contract Receiver {

    uint256 num = 0;

    struct Student {
        uint8 age;
        string name;
    }

    event MoneyReceived(string _function, uint256 _amount);
    event TxContext(uint256 _gasLeft, address _sender, address _origin, address _current);

    fallback() external payable {
        emit MoneyReceived("fallback", msg.value);
    }
    receive()  external payable {
        emit MoneyReceived("receive", msg.value);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function increment() public payable{
        num++;
        emit TxContext(gasleft(), msg.sender, tx.origin, address(this));
    }

    function getNum() public view returns(uint256){
        return num;
    }

    function sum(uint256 _num1, uint256 _num2) public returns(uint256){
        //emit MoneyReceived("sum",msg.value);
        emit TxContext(gasleft(), msg.sender, tx.origin, address(this));
        return _num1+_num2;

        // Student memory student = Student(25,"Alex");
        // student.age = 15;
    }

    function exampleOverflow() public pure returns(uint8){
        uint8 overflowNum = 255;
        return overflowNum++;
    }
}