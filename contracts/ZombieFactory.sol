// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;

import './Ownable.sol';
import './SafeMath.sol';

/**
 * @title A contract that manages the creation of Zombies
 * @author Tristán Vaquero (Trigii)
 * @notice This contract allows the users to create new zombies
 * @dev The contract inherits OpenZeppelin's implementation of the Ownable contract
 */
contract ZombieFactory is Ownable {
    // declarations
    using SafeMath for uint256; // for underflow / overflow protection
    using SafeMath32 for uint32; // same library but implemented for uint32
    using SafeMath16 for uint16; // same library but implemented for uint16

    // events
    event NewZombie(uint zombieId, string name, uint dna);

    // variables
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days; // 1 day cooldown for feeding and attacking

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies; // db containing all the existing zombies

    mapping(uint => address) public zombieToOwner; // zombieId => user address
    mapping(address => uint) ownerZombieCount; // user address => zombie count

    /**
     *
     * @param _name name of the zombie
     * @param _dna 16-digit integer that represents the physicall appearance of the zombie
     * @dev function parameters are named with an "_" before the name so we can difference them from global variables. Functions can receive parameters by value or reference:
     * @dev value means that the compiler creates a copy of the variable and passes it to the function so the original variable is not modified.
     * @dev reference means that the compiler passes a reference to the variable, so all the modifications that are done inside the function will affect the original variable.
     * @dev reference variables are: strings, arrays, structs and mappings
     * @dev if we want to pass a reference variable by value, we have to add the "memory" keyword (use "calldata" for external functions).
     */
    function _createZombie(string memory _name, uint _dna) internal {
        uint id = zombies.push(
            Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0) // cooldown = now + 1 day
        ) - 1; // id = array length - 1 (0, 1, 2...)
        zombieToOwner[id] = msg.sender; // zombie belongs to the user who called the function
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1); // increment the zombies owned by the user
        emit NewZombie(id, _name, _dna);
    }

    /**
     *
     * @param _str string used to generate a pseudo-random value using the SHA3 algorythm (keccak256)
     * @notice this function generates a random DNA for the creation of a Zombie.
     */
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str))); // generate a pseudo-random value
        return rand % dnaModulus; // stay only with the 16 characters
    }

    /**
     *
     * @param _name name of the zombie
     * @notice function used by the user to create a new random zombie
     * @dev users can only call this function once
     * @dev the skin of the zombie is based on the input name
     */
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0); // verify that the users call this function once
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
