pragma solidity >=0.4.17 <0.9.0;

library BindAssetEvent {
    event BindAsset(
        address fromAssetHash,
        uint64 toChainId,
        bytes toAssetHash
    );
}