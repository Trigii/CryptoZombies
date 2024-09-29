// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;

import './ZombieFactory.sol';

// CryptoKitties interface to be able to use the getKitty function (favorite food from the zombiess)
/**
 * @title A contract that manages the interaction with the CryptoKitty contract
 * @author Tristán Vaquero (Trigii)
 * @dev This contract is an interface for the CryptoKitty contract to be able to use the getKitty function and retrieve the DNA
 */
contract KittyInterface {
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

/**
 * @title A contract that manages the feeding of Zombies
 * @author Tristán Vaquero (Trigii)
 * @notice This contract allows the users to feed their Zombies with CryptoKitties
 */
contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;

    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]); // check if the user is the owner of the zombie
        _;
    }

    /**
     *
     * @param _zombieId zombie ID of the user
     * @param _targetDna DNA of the target the zombie is eating (zombie, human or CryptoKitty)
     * @param _species species of the _targetDna (human | zombie | kitty)
     * @dev requires the user to be the owner of the zombie
     * @notice This function feeds the zombie identified by _zombieId with the zombie / human / CryptoKitty identified by _targetDna
     *
     */
    function feedAndMultiply(
        uint _zombieId,
        uint _targetDna,
        string memory _species
    ) internal onlyOwnerOf(_zombieId) {
        // get the Zombie
        Zombie storage myZombie = zombies[_zombieId]; // get the zombie

        // check if the cooldown time has passed and we can feed
        require(_isReady(myZombie));

        // calculate the new zombie DNA
        _targetDna = _targetDna % dnaModulus; // make sure targetDna is no longer than 16 digits
        uint newDna = (myZombie.dna + _targetDna) / 2; // formula to calculate the new dna (average)

        // if we are feeding the zombie with a CryptoKitty:
        // DNA will end in 99
        // special characteristic of the cat-zombies
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked('kitty'))) {
            newDna = newDna - (newDna % 100) + 99; // dna = dna end in 99
        }

        // create the new zombie
        _createZombie('NoName', newDna);

        // give the zombie a cooldown for feeding / attacking
        _triggerCooldown(myZombie);
    }

    /**
     *
     * @param _zombieId zombie ID of the user
     * @param _kittyId ID of the CryptoKitty the zombie is eating
     * @dev uses the interface of the CryptoKitty contract to extract the genes (dna) of the Kitty
     * @notice This function feeds a specific zombie with a CryptoKitty
     */
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;

        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId); // extract the kitty genes (kitty dna)
        feedAndMultiply(_zombieId, kittyDna, 'kitty'); // feed the zombie
    }

    /**
     *
     * @param _address CryptoKitty contract address
     * @dev this function can only be executed by the owner of the contract
     * @notice this function sets the CryptoKitty contract address in case it changed
     */
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /**
     *
     * @param _zombie zombie that we want to give a cooldown on
     * @notice This function sets the cooldown of the zombie for attacking or feeding
     * @dev cooldown = current time + 1 day (in seconds)
     */
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    /**
     *
     * @param _zombie zombie that we want to check the cooldown on
     * @return bool returns true if the zombie cooldown has passed and therefore it can attack/feed and false in any other case
     * @notice This function checks if the zombie cooldown has passed or not
     */
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }
}
