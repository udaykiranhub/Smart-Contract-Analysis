// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract X{
    uint[] public  arr;
    function set(uint n)public {
        for(uint i=0;i<n;i++){
            arr.push(i);
        }
    }

    function get()public view returns(uint[] memory){
        return arr;
    }
}

/* *****************************************  */

Note: Usage of  Dynamic or unlimited interation may cause failure of a transaction .
This will cause transaction will alwasy fails.

n==100

decoded output	{
"0": "uint256[]: 0,1,2,3,4,5,6,7,8,9,10,...................80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99
}


n==1000;
	{
	"0": "uint256[]: 0,1,2,3,4,5,6,7,8..................1000
    }

n==10000; //Failure Case

VM Exception : transact to X.set errored: Error occurred: out of gas.

out of gas

The transaction ran out of gas. Please increase the Gas Limit.

If the transaction failed for not having enough gas, try increasing the gas limit gently.