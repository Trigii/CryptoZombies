// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;

import './ZombieHelper.sol';

/**
 * @title A contract that manages zombie attacks
 * @author Tristán Vaquero (Trigii)
 * @notice This contract allows the users to attack other zombies
 */
contract ZombieAttack is ZombieHelper {
    // variables
    uint randNonce = 0; // nonce used for generating random numbers
    uint attackVictoryProbability = 70; // 70% of win rate in attacks

    /**
     *
     * @param _modulus modulus used for generating a random number in a specific range.
     * @dev this function generates a random number using the "keccak256" function.
     * @dev we are not using any oracle like chainlinks, so this random number generation is INSECURE.
     * @notice This function generates an insecure random number and returns the value applying the specified modulus.
     * @return _ returns a random number
     */
    function randMod(uint _modulus) internal returns (uint) {
        randNonce = randNonce.add(1);
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }

    /**
     *
     * @param _zombieId ID of the zombie that is attacking.
     * @param _targetId ID of the target (human | zombie | cryptokitty) that is deffending.
     * @dev the user must be the owner of the zombie to execute this function.
     * @notice This function performs an attack using the _zombieId zombie to the _targetId target.
     */
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        // retrieve the zombies from storage
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        // generate a random number between 0-99
        uint rand = randMod(100);

        // check and update the winner / losser
        if (rand <= attackVictoryProbability) {
            // our zombie wins condition:
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            feedAndMultiply(_zombieId, enemyZombie.dna, 'zombie'); // calls _triggerCooldown so we dont need to call it
        } else {
            // our zombie losses condition
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            _triggerCooldown(myZombie);
        }
    }
}
