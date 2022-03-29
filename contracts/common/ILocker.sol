pragma solidity >=0.4.17 <0.9.0;

import "../../lib/lib/MPT.sol";
import "./AdminControlled.sol";

interface ILocker {
    uint constant UNPAUSED_ALL = 0;
    uint constant PAUSED_LOCK = 1 << 0;
    uint constant PAUSED_UNLOCK = 1 << 1;

    function lockToken(address fromToken, uint64 toChainId, uint256 amount, string memory userAccount)
        public
        pausable (PAUSED_LOCK);

    function unlockToken(bytes memory proofData, uint64 proofBlockHeight)
        public
        pausable (PAUSED_UNLOCK);
}