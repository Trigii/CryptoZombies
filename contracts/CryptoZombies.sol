pragma solidity >=0.5.0 <0.6.0;

import "./ZombieOwnership.sol";

contract CryptoZombies is ZombieOwnership {
    /*function kill() public onlyOwner {
        selfdestruct(owner()); // remove code from the blockchain at a certain address
    }*/
}
