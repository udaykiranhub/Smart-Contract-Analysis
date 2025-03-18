
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AgriSupplyChain {

uint public productId=0;//inital value for products
    // Product Details
    struct Product {
        uint id;
        string[] names;
        address currentOwner;
     address[] owners;
        string image;
        State state; 
    uint[] period; // Time taken at each stage (in hours)
        uint[] pricesFixed;
    string[] location; 
        uint[] expenditure;
        string[] transportStage;//
    }

mapping(uint=>Product)public Products;//storing the all products in a mapping with theri id

//Product details in Retialer stage

struct RetailerStage{
    uint id;
    uint sales;
    uint stockReceived;
    uint price;
    uint percent;
    string location;

}

//mapping
mapping(uint=>RetailerStage)public RetialDetails;
//customer Review for the Product

struct Review{
    uint id;
    uint8 quality;
    uint8 rating;
    string description;
    string priceReview;

}
mapping (uint=>Review)public ProductReview;
// Possible states of a product in the supply chain                                
enum State { Harvest,  InProduction, Retailer,Customer }

//Events Tracking for Products

event ProductCreated(uint pid,address powner,string pname);//creation time
event TransferOwner(address oldOwner,address newOwner,State state);//Owner ship transfering

event ProductUpdation(address powner,string pname,uint pprice,string plocation);//updation

function CreateProduct(
    string memory _name,
   string memory _image,
      uint _period,

    uint _price,
    string memory _location,
    uint _expenditure,
    string memory _transportStage

) public   {
    productId++;
    Products[productId].id=productId;
     Products[productId].names.push(_name);
     Products[productId].image = _image;
     Products[productId].state = State.Harvest;
     Products[productId].currentOwner=msg.sender;
    Products[productId].owners.push(msg.sender);
    Products[productId].period.push(_period);
     Products[productId].pricesFixed.push(_price);
    Products[productId].location.push(_location);
    Products[productId].expenditure.push(_expenditure);
    Products[productId].transportStage.push(_transportStage);

    emit ProductCreated(productId, msg.sender,_name);

}

modifier IsOwner(uint _id){
   
    require(msg.sender==Products[_id].currentOwner,"Not the Product Owner");
    _;
}

//Transfer Product OwnerShip in supply Chain
function TransferOwnerShip(uint _id,address _newOwner)public IsOwner(_id){
    require(msg.sender!=_newOwner,"This is the current Owner");
    if(Products[_id].state==State.Retailer){
        return ;
    }
    if(Products[_id].state==State.Harvest){
        Products[_id].state=State.InProduction;
    }
    else{
        Products[_id].state=State.Retailer;
    }
    //   if(Products[_id].state==State.Retailer){
    //     return ;
    // }
    Products[_id].currentOwner=_newOwner;
    Products[_id].owners.push(_newOwner);
emit TransferOwner(msg.sender,_newOwner, Products[_id].state);

}

//function to update product details in t next level supply chain 


function UpdateChain(
uint _id ,
string memory _name,
uint _period,
uint _pricesFixed,
string memory _location,
uint _expenditure,
string memory _transportStage)public IsOwner(_id){

//this function is available for stages InProduction
require(Products[_id].state==State.InProduction,"This stage no update permission!");
Products[_id].names.push(_name);
 Products[_id].period.push(_period);
Products[_id].pricesFixed.push(_pricesFixed);
Products[_id].location.push(_location);
Products[_id].expenditure.push(_expenditure);
emit ProductUpdation(msg.sender, _name, _pricesFixed, _location);
               
}


//Enter Product details by Retailer

function RetialerDetails(uint _id,uint _sales,
uint _stockReceived,uint _price,uint _percent,string memory _location) public IsOwner(_id) {
     
    require(Products[_id].state==State.Retailer,"Not in Retailer state");

  RetialDetails[_id]=RetailerStage(Products[_id].id,_sales,_stockReceived,_price,_percent,_location);
  Products[_id].state=State.Customer;

}


//Customer Review for the product

function CustomerReview(uint _id,uint8 _quality,
uint8 _rating,string memory _description,
string memory _priceReview)public {
require(_rating<=5,"Rating is must less than 5!");

require(_quality<=100,"quality less than 100");

require(Products[_id].state==State.Customer,"Not Customer Stage");

 ProductReview[_id]=Review(_id,_quality,_rating,_description,_priceReview);


}


//Stage of a Product 
function ProductStage(uint _id)public view returns (State){
    return Products[_id].state;
}
//getting product

function getProduct(uint _id)public view returns(Product memory){
    return Products[_id];

}


}
