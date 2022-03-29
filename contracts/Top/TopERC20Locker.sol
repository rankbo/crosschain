// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8;

import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "../common/ILocker.sol";
import "../common/Event/LockEvent.sol";
import "../common/Event/UnlockEvent.sol";
import "../common/Event/BurnEvent.sol";
import "./prove/ITopProve.sol";
import "./Locker.sol";

contract ERC20Locker is ILocker, Locker, AdminControlled {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Function output from burning fungible token on Near side.
    struct BurnResult {
        uint128 amount;
        address token;
        address recipient;
    }

    // ERC20Locker is linked to the bridge token factory on NEAR side.
    // It also links to the prover that it uses to unlock the tokens.
    constructor(bytes memory _ethMinerContract,
                ITopProve _prover,
                uint64 _minBlockAcceptanceHeight,
                address _admin,
                uint _pausedFlags)
        AdminControlled(_admin, _pausedFlags)
        Locker(_ethMinerContract, _prover, _minBlockAcceptanceHeight)
    {
    }

    function lockToken(address fromToken, uint256 amount, string memory accountId)
        public
        pausable (PAUSED_LOCK)
    {
        require(
            IERC20(ethToken).balanceOf(address(this)).add(amount) <= ((uint256(1) << 128) - 1),
            "Maximum tokens locked exceeded (< 2^128 - 1)");
        require(amount != 0, "amount can not be 0");
        IERC20(ethToken).safeTransferFrom(msg.sender, address(this), amount);
        emit LockEvent.Locked(fromToken, msg.sender, amount, accountId);
    }

    function unlockToken(bytes memory proofData, uint64 proofBlockHeight)
        public
        pausable (PAUSED_UNLOCK)
    {
        BurnEvent.BurnEventData memory status = _parseAndConsumeProof(proofData, proofBlockHeight);
        IERC20(status.token).safeTransfer(result.recipient, result.amount);
        emit UnlockEvent.Unlocked(result.amount, result.recipient);
    }

    // tokenFallback implements the ContractReceiver interface from ERC223-token-standard.
    // This allows to support ERC223 tokens with no extra cost.
    // The function always passes: we don't need to make any decision and the contract always
    // accept token transfers transfer.
    function tokenFallback(address _from, uint _value, bytes memory _data) public pure {}

    function adminTransfer(IERC20 token, address destination, uint256 amount)
        public
        onlyAdmin
    {
        token.safeTransfer(destination, amount);
    }
}
