pragma solidity >=0.4.17 <0.9.0;
pragma experimental ABIEncoderV2;

import "../../lib/lib/MPT.sol";
import "./AdminControlled.sol";

interface ILocker {
    uint constant UNPAUSED_ALL = 0;
    uint constant PAUSED_LOCK = 1 << 0;
    uint constant PAUSED_UNLOCK = 1 << 1;

    function burn(address tokenContract, uint256 amount, string memory userAccount)
        external
        payable
        pausable (PAUSED_LOCK);

    function mine(bytes memory proofData, uint64 proofBlockHeight)
        external
        payable
        pausable (PAUSED_UNLOCK);
}