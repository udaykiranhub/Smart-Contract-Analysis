// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract coffeeShop {

uint public limit;
address public owner;

//Token creation 
IERC20 public CFT;
constructor(uint _limit,address _cft){
    CFT=IERC20(_cft);
    limit=_limit;
    owner=msg.sender;
}



//customer
struct customer{
    string name;
    uint tokens;
    uint coffee;
    bool exist;
    
}
//storing customers
mapping(address=>customer)public customers;

event addEvent(string name,uint time);

function AddCustomer(string memory _name)public {
    require(!customers[msg.sender].exist,"Already customer exists");
    customers[msg.sender]=customer(_name,0,0,true);
    emit addEvent(_name,block.timestamp);
}

event buyEvent(address addr,string name,uint amount,uint coffee);
function BuyCoffee()public payable {
    require(msg.value>=0.01 ether,"Price too low!");
    uint bought=msg.value/0.01 ether;
    customers[msg.sender].coffee=bought;
emit buyEvent(msg.sender,customers[msg.sender].name, msg.value, bought);

}


//token limit
modifier OnlyOwner(){
    require(msg.sender==owner,"Not the Owner");
    _;
}

function changeLimit(uint _limit)public OnlyOwner{
limit=_limit;

}


//claim tokn
event claimEvent(address addr,uint tokens);
function claimToken()public {
    require(customers[msg.sender].exist,"Customer does not exist!");
    require(customers[msg.sender].coffee>=limit,"You have to buy some coffees!");
       
uint value=customers[msg.sender].coffee;
uint tokens=value/limit;

// Check if the contract has enough tokens

require(CFT.balanceOf(address(this)) >= tokens, "Not enough tokens in contract!");

// Transfer tokens from the contract to the customer
CFT.transfer(msg.sender, tokens);
customers[msg.sender].coffee=0;//updating the coffe value
emit claimEvent(msg.sender, tokens);



}



  
}
