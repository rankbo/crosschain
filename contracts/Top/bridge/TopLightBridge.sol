pragma solidity >=0.4.17 <0.9.0;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";


contract TopLightBridge is Pausable {
    function init_genesis_block() onlyOwner external returns (bool) {
        return true;
    }

    function sync_block() external returns (bool) {
        return true;
    }

    function get_block() public view returns (bool) {
        return true;
    }
}