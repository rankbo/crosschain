// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

library BindAssetEvent {
    event BindAsset(
        address fromAssetHash,
        uint64 toChainId,
        bytes toAssetHash
    );
}