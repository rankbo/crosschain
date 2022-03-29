// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.17 <0.9.0;

import "../common/Borsh.sol";
import "./prove/ITopProve.sol";
import "./codec/EthProofDecoder.sol";
import "../../lib/lib/EthereumDecoder.sol";
import "../common/event/BurnEvent.sol";

contract Locker {
    using Borsh for Borsh.Data;
    using EthProofDecoder for Borsh.Data;

    ITopProve public prover;
    bytes public ethMinerContract;

    /// Proofs from blocks that are below the acceptance height will be rejected.
    // If `minBlockAcceptanceHeight` value is zero - proofs from block with any height are accepted.
    uint64 public minBlockAcceptanceHeight;

    // OutcomeReciptId -> Used
    mapping(bytes32 => bool) public usedProofs;

    constructor(bytes memory _ethMinerContract, ITopProve _prover, uint64 _minBlockAcceptanceHeight) {
        require(_nearTokenFactory.length > 0, "Invalid Near Token Factory address");
        require(address(_prover) != address(0), "Invalid Near prover address");

        ethMinerContract = _ethMinerContract;
        prover = _prover;
        minBlockAcceptanceHeight = _minBlockAcceptanceHeight;
    }

    /// Parses the provided proof and consumes it if it's not already used.
    /// The consumed event cannot be reused for future calls.
    function _parseAndConsumeProof(bytes memory proofData, uint64 proofBlockHeight)
        internal
        returns (BurnEvent.BurnEventData memory result)
    {
        require(prover.verify(proofData), "Proof should be valid");

        Borsh.Data memory borshData = Borsh.from(proofData);
        EthProofDecoder.Proof memory proof = borshData.decode();
        borshData.done();

        EthereumDecoder.TransactionReceiptTrie memory reciptData = EthereumDecoder.toReceipt(proof.reciptData);
        //bytes32 receiptId = keccak256();
        bytes32 proofIndex = keccak256(reciptData.proof);
        require(!usedProofs[proofIndex], "The burn event proof cannot be reused");
        usedProofs[proofIndex] = true;

        address contractAddress = reciptData.logs[proof.logIndex].contractAddress;

        require(
            keccak256(contractAddress) == keccak256(ethMinerContract),
            "Can only unlock tokens from the linked proof producer on Top blockchain");
        result = BurnEvent.parse(reciptData.logs[proof.logIndex].data);
    }
}
