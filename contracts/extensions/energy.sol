// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Energy represents the sub-token in VeChainThor which conforms VIP180(ERC20) standard.
/// The name of token is "VeThor" and 1 THOR equals to 1e18 wei. The main function of VeThor is to pay for the transaction fee.
/// VeThor is generated from VET, so the initial supply of VeThor is zero in the genesis block.
/// The growth rate of VeThor is 5000000000 wei per token(VET) per second, that is to say 1 VET will produce about 0.000432 THOR per day.
/// The miner will charge 30 percent of transation fee and 70 percent will be burned. So the total supply of VeThor is dynamic.

interface Energy {
    ///
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice transfer '_amount' of VeThor from msg sender to account '_to'
    function transfer(address _to, uint256 _amount)
        external
        returns (bool success);
}
