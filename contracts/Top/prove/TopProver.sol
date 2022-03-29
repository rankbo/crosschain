pragma solidity >=0.4.17 <0.9.0;

import "./ITopProve.sol";
import "../codec/EthProofDecoder.sol";
import "../../../lib/lib/EthereumDecoder.sol";
import "../../../lib/lib/MPT.sol";
import "../../common/Borsh.sol";

contract TopProve is ITopProve{
    using Borsh for Borsh.Data;
    using EthProofDecoder for Borsh.Data;
    using MPT for MPT.MerkleProof;
    address public bridgeLight;

    constructor(address bridgeClient) {
        bridgeLight = bridgeClient;
    }

    function verify(bytes memory proofData) external view returns (bool valid, string memory reason) {
        Borsh.Data memory borshData = Borsh.from(proofData);
        EthProofDecoder.Proof memory proof = borshData.decode();
        borshData.done();

        EthereumDecoder.TransactionReceiptTrie memory receiptData = EthereumDecoder.toReceiptLog(proof.reciptData);
        if (keccak256(logEntryData) != keccak256(EthereumDecoder.getLog(receiptData.logs[logIndex]))) {
            return (false, "Log not found");
        }

        EthereumDecoder.BlockHeader header = EthereumDecoder.toBlockHeader(proof.headerData);
        MPT.MerkleProof memory merkleProof;
        merkleProof.expectedRoot = header.receiptsRoot;
        merkleProof.proof = proof.proof;
        merkleProof.expectedValue = proof.reciptData;
        merkleProof.key = RLPEncode.encodeUint(proof.reciptIndex);
        valid = merkleProof.verifyTrieProof();
        if (!valid) {
            return (false, "Fail to verify");
        }

        // 调用系统合约验证块头
        (success, returnData) = bridgeLight.Call(
            abi.encodePacked(bytes4(keccak256(abi.encodePacked("getHeaderIfHeightConifrmed", "(bytes, uint64)"))),
            abi.encode(proof.headerData, 125)));
        if (!success) {
            return (false, "Height is not confirmed");
        }

        return (true, "");
    }
}