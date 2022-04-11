// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8;

import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "../common/ILocker.sol";
import "../common/Event/LockEvent2.sol";
import "../common/Event/UnlockEvent.sol";
import "../common/Event/BindAssetEvent.sol";
import "./prove/ITopProve.sol";
import "./Locker2.sol";
import "../common/Borsh.sol";
import "../../lib/lib/EthereumDecoder.sol";
import "./codec/EthProofDecoder.sol";

contract ERC20Locker is ILocker, Locker, AdminControlled {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Borsh for Borsh.Data;
    using EthProofDecoder for Borsh.Data;
    uint64 public selfChainId = 125;

    mapping(address => mapping(uint64 => bytes)) public assetHashMap;

    function bindAssetHash(address fromAssetHash, uint64 toChainId, bytes memory toAssetHash) public onlyAdmin  returns (bool) {
        assetHashMap[fromAssetHash][toChainId] = toAssetHash;
        emit BindAssetEvent.BindAsset(fromAssetHash, toChainId, toAssetHash);
        return true;
    }

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
                uint _pausedFlags) public
        AdminControlled(_admin, _pausedFlags)
        Locker(_ethMinerContract, _prover, _minBlockAcceptanceHeight)
    {
    }

    function lockToken(address fromToken, uint64 toChainId, uint256 amount, string memory accountId)
        public
        pausable (PAUSED_LOCK)
    {
        require(
            IERC20(ethToken).balanceOf(address(this)).add(amount) <= ((uint256(1) << 128) - 1),
            "Maximum tokens locked exceeded (< 2^128 - 1)");
        require(amount != 0, "amount can not be 0");
        bytes memory toAssetHash = assetHashMap[fromAssetHash][toChainId];
        require(toAssetHash.length != 0, "empty illegal toAssetHash");
        require(IERC20(ethToken).safeTransferFrom(msg.sender, address(this), amount), "transfer failed");
        emit LockEvent.Locked(fromToken, address(toAssetHash), toChainId, msg.sender, amount, accountId);
    }

    function unlockToken(bytes memory proofData, uint64 proofBlockHeight)
        public
        pausable (PAUSED_UNLOCK)
    {
        Borsh.Data memory borshData = Borsh.from(proofData);
        EthProofDecoder.Proof memory proof = borshData.decode();
        borshData.done();

        EthereumDecoder.Log memory log = EthereumDecoder.toReceiptLog(proof.logEntryData);
        LockEvent2.LockEvent2 memory lockEvent = LockEvent2.parse(log.data);

        bytes memory toAssetHash = assetHashMap[lockEvent.toToken][toChainId];
        require(toAssetHash.length != 0, "empty illegal toAssetHash");
        require(address(toAssetHash) != lockEvent.fromToken, "");

        _parseAndConsumeProof(proofData, proofBlockHeight);
        require(IERC20(lockEvent.toToken).safeTransfer(result.recipient, result.amount),"transfer failed");
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
