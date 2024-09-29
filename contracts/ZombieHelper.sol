pragma solidity >=0.5.0 <0.6.0;

import './ZombieFeeding.sol';

/**
 * @title A contract that manages extra functionalities for the Zombies
 * @author Tristán Vaquero (Trigii)
 * @notice This contract allows the users to level up their Zombies, change the name and DNA of their Zombies, or retrieve a list of their Zombies
 * @dev This contract allows the owner to withdraw the funds of the contract
 */
contract ZombieHelper is ZombieFeeding {
    // variables
    uint levelUpFee = 0.001 ether;

    // check if a zombie has more level than the specified
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /**
     *
     * @param _zombieId ID of the zombie we want to change the name
     * @param _newName new name of the zombie
     * @dev requires the zombie to have at least level 2
     * @dev requires the user to be the owner of the zombie
     * @notice This function changes the name of the zombie.
     */
    function changeName(
        uint _zombieId,
        string calldata _newName
    ) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    /**
     *
     * @param _zombieId ID of the zombie we want to change the DNA
     * @param _newDna new DNA of the zombie
     * @dev requires the zombie to have at least level 20
     * @dev requires the user to be the owner of the zombie
     * @notice This function changes the DNA of the zombie.
     */
    function changeDna(
        uint _zombieId,
        uint _newDna
    ) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    /**
     *
     * @param _owner address of the user we want to retrieve all his zombies
     * @dev this function creates a memory array to store all the zombies owned by the _owner to save gas
     * @dev we could create a storage mapping between addresses and an array of zombies, but this is very expensive since we have to add extra store operations
     * @dev it is also very expensive if we want to transfer a zombie from one account to another one because we would have to:
     * @dev 1. Push the zombie to the new owner's ownerToZombies array,
     * @dev 2. Remove the zombie from the old owner's ownerToZombies array,
     * @dev 3. Shift every zombie in the older owner's array up one place to fill the hole (or reorder the array to fill the hole with the last zombie),
     * @dev 4. Reduce the array length by 1.
     */
    function getZombiesByOwner(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]); // resulting memory array containing all the zombies owned by the _owner (memory arrays must have a fixed length)

        uint counter = 0; // variable to keep track of the current position in the result array

        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i; // save the zombieId
                counter++;
            }
        }

        return result;
    }

    /**
     *
     * @param _zombieId ID of the zombie the user wants to level up
     * @dev the user requires to send levelUpFee ETH to level up the zombie with ID = _zombieId
     * @notice This function levels up a zombie from the user
     */
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    /**
     * @notice This function withdraws all the money from the contract to the owner of it
     * @dev this function can only be called by the owner of the contract
     */
    function withdraw() external onlyOwner {
        address payable _owner = address(uint160(owner())); // get the address of the owner of the contract
        _owner.transfer(address(this).balance); // transfer the balance of the contract
    }

    /**
     *
     * @param _fee new fee for leveling up the zombies
     * @dev this function can only be called by the owner of the contract
     * @notice This function sets the level up fee. This is usefull to have a dynamic fee in case the price of the ETH bumps or dumps
     */
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }
}
