// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PayPool is Ownable {
    // Contracts that are participating in the referral campaign.
    address[] public memberContracts;
    address public tokenAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    uint256 public referrerBips = 5000;
    uint256 public refereeBips = 3000;
    uint256 public serviceBips = 2000;
    uint256 constant BIP = 10_000;

    // Balance the participating member has left to spend.
    mapping(address memberContractAddress => uint256 share) public memberBalance;

    mapping(address referrer => uint256 id) public referrerIds;
    mapping(address referee => uint256 id) public refereeIds;
    // Referrer and referee shares.
    mapping(address referrer => uint256 share) public referrerShares;
    mapping(address referee => uint256 share) public refereeShares;
    mapping(address service => uint256 share) public serviceShare;

    uint256 public number;

    constructor() Ownable(msg.sender) {}

    // Sign up a new member
    function startAMembership(address memberContractAddress, uint256 contribution) public {
        AddToMemberBalance(memberContractAddress, contribution);
        memberContracts.push(memberContractAddress);
    }

    // Manage member balance
    function AddToMemberBalance(address memberContractAddress, uint256 share) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), share);
        memberBalance[memberContractAddress] += share;
    }

    function ReduceMemberBalance(address memberContractAddress, uint256 share) public {
        memberBalance[memberContractAddress] -= share;
    }

    // TODO: Need to restrict this to accounts with permissions
    function updateReferrerId(address referrer, uint256 id) public {
        referrerIds[referrer] = id;
    }

    // TODO: Need to restrict this to accounts with permissions
    function updateRefereeId(address referee, uint256 id) public {
        refereeIds[referee] = id;
    }

    function successfulReferral(address memberContractAddress, address referrer, address referee, uint256 share)
        public
    {
        updateReferrerShare(memberContractAddress, referrer, (share * referrerBips) / BIP);
        updateRefereeShare(memberContractAddress, referee, (share * refereeBips) / BIP);
        updateServiceShare(memberContractAddress, address(this), (share * serviceBips) / BIP);
    }

    // Update Shares
    function updateReferrerShare(address memberContractAddress, address referrer, uint256 share) public {
        ReduceMemberBalance(memberContractAddress, share);
        referrerShares[referrer] += share;
    }

    function updateRefereeShare(address memberContractAddress, address referee, uint256 share) public {
        ReduceMemberBalance(memberContractAddress, share);
        refereeShares[referee] += share;
    }

    function updateServiceShare(address memberContractAddress, address service, uint256 share) public {
        ReduceMemberBalance(memberContractAddress, share);
        serviceShare[service] += share;
    }

    // Pull Shares
    function pullReferrerShare() public {
        IERC20(tokenAddress).transfer(msg.sender, referrerShares[msg.sender]);
        referrerShares[msg.sender] = 0;
    }

    function pullRefereeShare() public {
        IERC20(tokenAddress).transfer(msg.sender, referrerShares[msg.sender]);
        referrerShares[msg.sender] = 0;
    }

    function pullServiceShare() public onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, serviceShare[msg.sender]);
        serviceShare[msg.sender] = 0;
    }
}
