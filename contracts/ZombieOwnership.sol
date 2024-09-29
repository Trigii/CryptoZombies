// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;

import './ZombieAttack.sol';
import './ERC721.sol';

/**
 * @title A contract that manages transferring zombie ownership
 * @author Tristán Vaquero (Trigii)
 * @notice This contract allows the users to trade the Zombies they own.
 * @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft
 */
contract ZombieOwnership is ZombieAttack, ERC721 {
    // variables
    mapping(uint => address) zombieApprovals;

    /**
     *
     * @param _owner address of the owner that we want to retrieve the balance from
     * @notice This function retrieves the number of zombies (balance) the _owner has.
     */
    function balanceOf(address _owner) external view returns (uint256) {
        // 1. Return the number of zombies `_owner` has here
        return ownerZombieCount[_owner];
    }

    /**
     *
     * @param _tokenId the ID of the token that we want to retrieve the owner from
     * @notice This function retrieves the owner of the zombie
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        // 2. Return the owner of `_tokenId` here
        return zombieToOwner[_tokenId];
    }

    /**
     *
     * @param _from the address of the user who sends the token
     * @param _to the address of the user who receives the token
     * @param _tokenId the token that is being transfered
     * @notice This function contains all the logic of transfering a Zombie from one user to another
     */
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1); // the receiver will have 1 more zombie
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1); // the sender will have 1 less zombie
        zombieToOwner[_tokenId] = _to; // change the owner of the zombie
        emit Transfer(_from, _to, _tokenId); // emit an event
    }

    /**
     *
     * @param _from the address of the user who sends the token
     * @param _to the address of the user who receives the token
     * @param _tokenId the token that is being transfered
     * @dev this function can only be called if the msg.sender is the owner of the Zombie or the msg.sender has been approved.
     * @notice This function transfers the Zombie from one user to another.
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId); // transfer the zombie
    }

    /**
     *
     * @param _approved the address of the user who is being approved
     * @param _tokenId the zombie that is being approved to the _approved
     * @dev this function can only be called if the owner of the zombie is the msg.sender
     * @notice This function aproves the user _approved to use the zombie _tokenId
     */
    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}
