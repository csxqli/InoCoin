pragma solidity ^0.4.11;
contract InoCoin {
    struct Device {
        int balance;
        uint pricePerSecond;
        uint startTime;
    }
    
    address public rentalCompany;
    mapping (address => Device) public Devices;
    
    function InoCoin() {
        rentalCompany = msg.sender;
    }
    
    function queryDevice(address DeviceAddress) constant returns (int, uint, uint) {
        return (Devices[DeviceAddress].balance, Devices[DeviceAddress].pricePerSecond, Devices[DeviceAddress].startTime);
    }
    
    function register(address DeviceAddress, int _Balance, uint _pricePerSecond) {
        require (Devices[DeviceAddress].pricePerSecond == 0);
        Devices[DeviceAddress] = Device(_Balance, _pricePerSecond, 0);
    }
    
    function chargeOrRefundByCompany(address DeviceAddress, int amount) {
        require (msg.sender == rentalCompany);
        require (amount > 0 || Devices[DeviceAddress].balance + amount >= 0);
        Devices[DeviceAddress].balance += amount;
    }
    
    function chargeWithEther() payable {
        require (Devices[msg.sender].pricePerSecond != 0);
        Devices[msg.sender].balance += int(msg.value);
    }
    
    function refundWithEther() {
        int balance = Devices[msg.sender].balance;
        require (balance > 0);
        Devices[msg.sender].balance = 0;
        msg.sender.transfer(uint(balance));
    }
    
    function sendEther(address receiver, uint amount) {
        require (msg.sender == rentalCompany);
        receiver.transfer(amount);
    }
    
    function unregister() {
        require (Devices[msg.sender].pricePerSecond != 0);
        require (Devices[msg.sender].balance == 0);
        delete Devices[msg.sender];
    }
    
    function start() {
        require (Devices[msg.sender].startTime == 0);
        Devices[msg.sender].startTime = now;
    }
    
    function stop() returns (uint price, int balance) {
        require (Devices[msg.sender].startTime != 0);
        price = (now - Devices[msg.sender].startTime) * Devices[msg.sender].pricePerSecond;
        Devices[msg.sender].startTime = 0;
        Devices[msg.sender].balance -= int(price);
        balance = Devices[msg.sender].balance;
    }
    
}