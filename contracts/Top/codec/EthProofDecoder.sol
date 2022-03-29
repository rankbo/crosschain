// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8;

import "../../common/Borsh.sol";

library EthProofDecoder {
    using Borsh for Borsh.Data;
    using EthProofDecoder for Borsh.Data;

    struct Proof {
        uint64 logIndex;
        bytes logEntryData;
        uint64 reciptIndex;
        bytes reciptData;
        bytes headerData;
        bytes proof;
    }

    function decode(Borsh.Data memory data) internal pure returns (Proof memory proof) {
        proof.logIndex = data.decodeU64();
        proof.logEntryData = data.decodeBytes();
        proof.reciptIndex = data.decodeU64();
        proof.reciptData = data.decodeBytes();
        proof.headerData = data.decodeBytes();
        proof.proof = data.decodeBytes();
    }
}
