// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;



contract X{

function sendETH(address receiver)external payable  {

require(msg.value>0,"amount must >0");
(bool sent,)=receiver.call{value:msg.value}("");
require(sent,"Transaction Failed@@");

}  
}


contract Y{
uint public  balance;

receive() external payable { 

     balance+=msg.value;

//1.****************Scenerio  One********************

revert(" ");

//2.********************Scenerio Two ****************
uint i=0;
while(i<10000000){//Infinite loop
i+=1;

}
   

}

}
 
 //###################################

######### Vulnerabilities ###########

 1.revert()=> Attacker uses the revert statement in the  receive() always Revert the transaction make 
 that transaction useless .Funds locked in the Contract only.

 2.Loop()=> Attacker can bound or unbounded loop in the receive()  it will  delayand Fail the transaction 
 afters some time due to increase of the Block Gas limit .


 ### Prevention Technique #####
1.Check the user before making an external call
 2.use gas limit for external calls   => receiver.call{value:x,gas:limit}(" ");