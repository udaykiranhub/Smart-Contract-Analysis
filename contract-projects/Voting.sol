// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting{

//..........for voters.........

//total votes in the Election
uint public TotalVotes=0;

//counting votes one by one for ending the Elections, we have to set vote limit for accuracy
uint public currentVotes=0;


//check voting completed or not
bool public Polling=true;

//check Registration is completed or not
bool public Registration=true;
//check Nomination is completed or not
bool public Nomination=true;

//Admin for Elections
address public  Admin;
//Storing a Voter information
struct Voter{
    string name;
    string addr;
    bool Registered;
    bool voted;
   
}


//storing all voter details in a struct Array
Voter[] public VoterList;

//Getting voter details by their wallet address
mapping(address=>Voter)public VoterDetails;



//..........For Participant ..............

// Dynamically storing a Participant in Elections

//creating a struct for storing the participant in Elections
 struct Participant{
    string name;
    string symbol;
    uint votes;
    uint index;

 }
 uint public ParticipantIndex=0;//It is index for updating participant vote count in the array
 
//storing in an Array for accessing all participants once
Participant[] public ParticipantList;

//accessing a participant votes instantly
mapping(string=>Participant)public ParticipantDetails;

//setting Admin 
constructor(){
Admin=msg.sender;
}


modifier OnlyAdmin(){
    require(msg.sender==Admin,"Not the Admin!");
    _;
}


//Events for monitoring
event NominationEvent(string pname,string psymbol);
event RegisterEvent(address vwallet,string vname,string vaddress );
event VotedEvent(address sender,string symbol);
//Add Participant to the Elections
function NominationForParticipant(string memory _name,string memory _symbol)public  OnlyAdmin returns(bool){
    require(Nomination==true,"Nomination completed!");

require(keccak256(abi.encodePacked(ParticipantDetails[_symbol].name)) != keccak256(abi.encodePacked(_name)),"Participant name already exists!");
require(keccak256(abi.encodePacked(ParticipantDetails[_symbol].symbol)) != keccak256(abi.encodePacked(_symbol)),"Symbol already exists");

ParticipantDetails[_symbol]=Participant(_name,_symbol,0,ParticipantIndex);
ParticipantList.push(Participant(_name,_symbol,0,ParticipantIndex));
ParticipantIndex++;
emit NominationEvent(_name, _symbol);

return true;

}


//Register a Voter

function RegisterVoter(string memory _name,string memory _addr)public returns(bool){
    require(Registration==true,"Registration is completed");
    require(!VoterDetails[msg.sender].Registered, "Voter is already registered!");
    VoterList.push(Voter(_name,_addr,true ,false));
    VoterDetails[msg.sender]=Voter(_name,_addr,true,false);
    TotalVotes++;
    emit RegisterEvent(msg.sender, _name, _addr);
    return true;
}


//Vote to participant

function VoteToParticipant(string  memory _symbol)public   returns (bool){
   require(Polling==true,"Polling stopped!");
    require(!VoterDetails[msg.sender].voted,"Already Voted");
    require(currentVotes<TotalVotes,"Voting Completed!"); // Changed <= to < for accuracy

 VoterDetails[msg.sender].voted=true;
ParticipantDetails[_symbol].votes+=1;//incrementing the participant vote count
uint i=ParticipantDetails[_symbol].index;

ParticipantList[i].votes+=1;

 currentVotes+=1;
 emit VotedEvent(msg.sender, _symbol);

return true;


}

//stop the election polling
function StopPolling()public  OnlyAdmin {
    Polling=false;


}
//stop the nomination process
function StopNomination()public OnlyAdmin {
    Nomination=false;

}
//stop the voter Registration
function StopRegistration()public OnlyAdmin {
    Registration=false;
    
}


//To know the Voter details
function getMyDetails()public view returns (Voter memory){
    return VoterDetails[msg.sender];
}
//to know the participant details
function getParticipant(string memory _symbol)public view returns (Participant memory){
    return ParticipantDetails[_symbol];
}


}
