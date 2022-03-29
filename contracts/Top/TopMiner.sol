pragma solidity >=0.4.17 <0.9.0;

import "../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "../common/IMiner.sol";
import "./prove/ITopProve.sol";
import "../common/event/LockEvent.sol";
import "../common/Borsh.sol";
import "./codec/EthProofDecoder.sol";
import "../../lib/lib/EthereumDecoder.sol";

contract TopMiner is IMiner, AdminControlled {
    using Borsh for Borsh.data;
    using EthProofDecoder for Borsh.Data;
    //using SafeERC20 for IERC20;
    struct Account {
        uint256 amount;
        mapping(address => uint256) grantAmount;
    }

    mapping(bytes32=>bool) public usedProofs;
    mapping(address=>Account) public accounts;
    address public peerLockContract;
    ITopProve public prover;

    constructor (address _peerLockContract, ITopProve _prover) Ownable(msg.sender) {
        peerLockContract = _peerLockContract;
        prover = _prover;
    }

    function mine(bytes memory proofData, uint64 proofBlockHeight) external payable pausable (PAUSED_LOCK) returns (bool) {

        require(prover.verify(proofData), "Proof should be valid");

        Borsh.Data memory borshData = Borsh.from(proofData);
        EthProofDecoder.Proof memory proof = borshData.decode();
        borshData.done();

        EthereumDecoder.TransactionReceiptTrie memory reciptData = EthereumDecoder.toReceipt(proof.reciptData);
        address contractAddress = reciptData.logs[proof.logIndex].contractAddress;
        require(
            keccak256(peerLockContract) == keccak256(contractAddress),
            "Can only unlock tokens from the linked proof producer on Top blockchain");

        bytes32 proofIndex = keccak256(reciptData.proof);
        require(!usedProofs[proofIndex], "The lock event proof cannot be reused");
        usedProofs[proofIndex] = true;

        LockEvent.LockEventData memory eventData;
        eventData = LockEvent.parse(reciptData.logs[proof.logIndex].data);
        require(eventData.amount != 0, "amount can not be 0");
        accounts[eventData.receipient] += eventData.amount;
        return true;
    }

    function burn(uint256 amount) external payable pausable (PAUSED_UNLOCK) returns (bool) {
        require(amount != 0, "amount can not be 0");
        require(msg.value != 0, "gas can not be zero");

        if (0 == accounts[msg.sender].amount) {
            return false;
        }
        Account storage account = accounts[msg.sender];
        require(account.amount >= amount, "not enough balance");
        account.amount -= amount;
        return true;
    }

    function incAllowance(address newOwner, uint256 amount) public payable returns (bool) {
        require(amount != 0, "amount can not be 0");
        require(msg.value != 0, "gas can not be 0");

        require(msg.sender != newOwner, "Can not equal");

        if (0 == accounts[msg.sender].amount) {
            return false;
        }
        Account storage account = accounts[msg.sender];
        account.grantAccount[newOwner] += amount;

        return true;
    }

    function decAllowance(address newOwner,uint256 amount) public payable returns (bool) {
        require(amount != 0, "amount can not be 0");
        require(msg.value != 0, "gas can not be zero");

        require(msg.sender != newOwner, "Can not equal");

        if (0 == accounts[msg.sender].amount) {
            return false;
        }
        Account storage account = accounts[msg.sender];
        if (0 == account.grantAmount[newOwner]) {
            return false;
        }

        if (account.grantAccount[newOwner] > amount) {
            account.grantAccount[newOwner] -= amount;
        } else {
            delete account.grantAccount[newOwner];
        }
        return true;
    }

    function transfer_from(address owner, address newOwner,uint256 amount) public payable returns (bool) {
        require(amount != 0, "amount can not be 0");
        require(msg.value != 0, "gas can not be zero");
        require(owner != newOwner, "gas can not be zero");

        // Retrieving the account from the state.
        if (0 == accounts[owner].amount) {
            return false;
        }

        Account storage account = accounts[owner];
        require(account.amount >= amount, "not enough");
        account.amount -= amount;
        if (msg.sender != owner) {
            if (0 == account.grantAmount[msg.sender]) {
                delete account.grantAccount[msg.sender];
            }
            require(account.grantAmount[msg.sender] >= amount, "not enough");

            if (account.grantAccount[msg.sender] > amount) {
                account.grantAccount[msg.sender] -= amount;
            } else {
                delete account.grantAccount[msg.sender];
            }
        }

        accounts[newOwner].amount += amount;
        return true;
    }

    function transfer(address newOwner,uint256 amount) public payable returns (bool) {
        require(amount != 0, "amount can not be 0");
        require(msg.value != 0, "gas can not be zero");
        return transfer_from(msg.sender, newOwner, amount);
    }
}