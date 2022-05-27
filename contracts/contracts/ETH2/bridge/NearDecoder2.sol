// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../../../lib/external_lib/RLPEncode.sol";
import "../../../lib/external_lib/RLPDecode.sol";

library NearDecoder2 {
    using RLPDecode for RLPDecode.RLPItem;
    using RLPDecode for RLPDecode.Iterator;

    struct BlockProducer {
        bytes32 publicKey;
        uint128 stake;
    }

    struct OptionalBlockProducers {
       bool some;
        BlockProducer[] blockProducers;
        bytes32 bp_hash; // Additional computable element
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct OptionalSignature {
        Signature signature;
    }

    struct BlockHeaderInnerLite {
        uint64 version; //version of block header
        uint64 height; // Height of this block since the genesis block (height 0).
        bytes32 epoch_id; // Epoch start hash of this block's epoch. Used for retrieving validator information
        uint64 timestamp; // Timestamp at which the block was built.
        bytes32 elections_hash; // Hash of the next epoch block producers set
        bytes32 txs_root_hash; // Hash of the next epoch block producers set
        bytes32 receipts_root_root; // Root of the outcomes of transactions and receipts.
        bytes32 prev_state_root; // Root hash of the state at the previous block.
        bytes32 block_merkle_root; //all block merkle root hash
        bytes32 innder_hash; // Additional computable element
    }

    struct LightClientBlock {
        BlockHeaderInnerLite inner_lite;
        bytes32 prev_block_hash;
        uint256 chain_bits;
        uint64 table_height;
        OptionalBlockProducers next_bps;
        OptionalSignature[] approvals_after_next;
        bytes32 block_hash; // Additional computable element
    }

    
    function decodeOptionalSignature(RLPDecode.RLPItem memory itemBytes)
        internal
        pure
        returns (OptionalSignature memory res)
    {
        RLPDecode.Iterator memory it = itemBytes.toRlpItem().iterator();
        uint256 idx;
        while (it.hasNext()) {
            if (idx == 0) res.Signature.r = bytes32(it.next().toUint());
            else if (idx == 1) res.Signature.v = bytes32(it.next().toUint());
            else if (idx == 2) res.Signature.s = it.next().toUint();
            else it.next();

            idx++;
        }
    }

    function decodeOptionalBlockProducers(RLPDecode.RLPItem memory itemBytes)
        internal
        view
        returns (OptionalBlockProducers memory res)
    {
        if (itemBytes.isList()) {
            RLPDecode.RLPItem[] memory ls = itemBytes.toRlpItem().toList();
            if (ls.length > 0) {
                bytes memory hash_raw = itemBytes.toBytes();
                res.bp_hash = sha256(abi.encodePacked(hash_raw));
                console.log("OptionalBlockProducers bp_hash ");
                console.logBytes32(res.bp_hash);
                res.some = true;
                res.blockProducers = new BlockProducer[](ls.length);
                for (uint256 i = 0; i < ls.length; i++) {
                    RLPDecode.RLPItem[] memory items = ls[i].toList();
                    res.blockProducers[i].publicKey = bytes32(
                        items[0].toUint()
                    );
                    res.blockProducers[i].stake = items[1].toUint();
                }
            }
        }
    }

    function decodeBlockHeaderInnerLite(RLPDecode.RLPItem memory itemBytes)
        internal
        view
        returns (BlockHeaderInnerLite memory res)
    {
        //cacl innter hash
        bytes memory hash_raw = itemBytes.toBytes();
        res.innder_hash = sha256(abi.encodePacked(hash_raw));
        console.log("res.innder_hash ");
        console.logBytes32(res.innder_hash);

        RLPDecode.Iterator memory it = itemBytes.toRlpItem().iterator();
        uint256 idx;
        while (it.hasNext()) {
            if (idx == 0)      res.version = it.next().toUint();
            else if (idx == 1) res.height = it.next().toUint();
            else if (idx == 2) res.epoch_id = bytes32(it.next().toUint());
            else if (idx == 3) res.timestamp = it.next().toUint();
            else if (idx == 4) res.elections_hash = bytes32(it.next().toUint());
            else if (idx == 5) res.txs_root_hash = bytes32(it.next().toUint());
            else if (idx == 6)
                res.receipts_root_root = bytes32(it.next().toUint());
            else if (idx == 7)
                res.prev_state_root = bytes32(it.next().toUint());
            else if (idx == 8)
                res.block_merkle_root = bytes32(it.next().toUint());
            else it.next();

            idx++;
        }
        console.log("version %s ", res.version);
    }

    function decodeLightClientBlock(bytes memory rlpBytes)
        internal
        view
        returns (LightClientBlock memory res)
    {
        RLPDecode.Iterator memory it = rlpBytes.toRlpItem().iterator();
        uint256 idx;
        while (it.hasNext()) {
            if (idx == 0) {
                res.inner_lite = it.next().decodeBlockHeaderInnerLite();
            } else if (idx == 1) {
                res.prev_block_hash = bytes32(it.next().toUint());
            } else if (idx == 2) {
                res.chain_bits = it.next().toUnit();
            } else if (idx == 3) {
                res.table_height = it.next().toUnit();
            } else if (idx == 4) {
                res.next_bps = it.next().decodeOptionalBlockProducers();
            } else if (idx == 6) {
                RLPDecode.RLPItem memory sig_item = it.next();
                if (sig_item.numItems() > 0) {
                    RLPDecode.RLPItem[] memory sig_ls = sig_item.toList();
                    res.approvals_after_next = new OptionalSignature[](sig_ls.length);
                    for (uint256 i = 0; i < sig_ls.length; i++) {
                        res.approvals_after_next[i] = decodeOptionalSignature(sig_ls[i]);
                    }
                }
            }
        }

        bytes[] memory raw_list = new bytes[](4);
        raw_list[0] = RLPEncode.encodeBytes(res.inner_lite.iner_hash);
        raw_list[1] = RLPEncode.encodeBytes(res.prev_block_hash);
        raw_list[2] = RLPEncode.encodeUint(res.chain_bits);
        raw_list[3] = RLPEncode.encodeUint(res.table_height);
        bytes memory  hash_raw   = RLPEncode.encodeList(raw_list);

        res.block_hash = sha256( abi.encodePacked(hash_raw));
    }

    /* struct PublicKey {
        bytes32 k;
    }*/

 /*   function decodePublicKey(Borsh.Data memory data)
        internal
        pure
        returns (PublicKey memory res)
    {
        require(data.decodeU8() == 0, "Parse error: invalid key type");
        res.k = data.decodeBytes32();
    }

    function decodeSignature(Borsh.Data memory data)
        internal
        pure
        returns (Signature memory res)
    {
        require(data.decodeU8() == 0, "Parse error: invalid signature type");
        res.r = data.decodeBytes32();
        res.s = data.decodeBytes32();
    }

    function decodeBlockProducer(Borsh.Data memory data)
        internal
        pure
        returns (BlockProducer memory res)
    {
        uint8 validator_version = data.decodeU8();
        data.skipBytes();
        res.publicKey = data.decodePublicKey();
        res.stake = data.decodeU128();
        if (validator_version == VALIDATOR_V2) {
            res.isChunkOnly = data.decodeU8() != 0;
        } else {
            res.isChunkOnly = false;
        }
    }

    function decodeBlockProducers(Borsh.Data memory data)
        internal
        pure
        returns (BlockProducer[] memory res)
    {
        uint256 length = data.decodeU32();
        res = new BlockProducer[](length);
        for (uint256 i = 0; i < length; i++) {
            res[i] = data.decodeBlockProducer();
        }
    }
*/
}
