pragma solidity >=0.4.17 <0.9.0;

interface ITopProve {
    function verify(bytes calldata proofData) external view returns(bool valid, string memory reason);
}