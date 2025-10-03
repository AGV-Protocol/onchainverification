// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IAGVOracle
 * @notice Defines the external interface for the on-chain oracle and settlement contract.
 * @dev Mapped directly from the Oracle & Contract section of the On-Chain Oracle Implementation Plan.
 */
interface IAGVOracle {
    // ===== Daily snapshot (evidence only; not mint-determining) =====
    // Event emitted when a daily snapshot is stored on-chain.
    event DailySnapshotStored(
        bytes32 indexed snapshotHash,   // keccak256(JSON; sorted keys; integerized; scaled decimals) [cite: 65]
        string  date,                   // "YYYY-MM-DD" (UTC) [cite: 66]
        string  stationId,              // [cite: 67]
        uint256 solarKWhSum_x10,        // kWh*10 [cite: 68]
        uint256 selfConsumedKWh_x10,    // kWh*10 [cite: 69]
        uint256 computeHoursSum_x10,    // h*10 [cite: 70]
        uint16  records,                // expected 96 [cite: 71]
        bytes32 sheetSha256,            // daily CSV SHA-256 [cite: 72]
        address signer                  // optional: EIP-712 signer [cite: 73]
    );

    // ===== Monthly settlement (sole minting anchor) =====
    // Event emitted when a monthly settlement (or a new revision) is stored.
    event MonthlySettlementStored(
        string  period,                 // "YYYY-MM" [cite: 77]
        string  stationId,              // [cite: 78]
        uint256 gridDeliveredKWh_x10,   // kWh*10 [cite: 79]
        uint256 selfConsumedKWh_x10,    // kWh*10 [cite: 80]
        uint256 tariff_bp,              // tariff * 10000 [cite: 81]
        bytes32 monthFilesAggSha256,    // aggregated hash [cite: 82]
        bytes32 settlementPdfSha256,    // State Grid bill PDF hash [cite: 83]
        bytes32 bankSlipSha256,         // bank receipt hash (optional) [cite: 84]
        uint8   revision,               // starts from 1 [cite: 85]
        address reconciler              // multisig/role [cite: 86]
    );

    // Event emitted when a previously stored monthly settlement is amended.
    event MonthlySettlementAmended(
        string  period,                 // [cite: 89]
        string  stationId,              // [cite: 90]
        uint8   oldRevision,            // [cite: 91]
        uint8   newRevision,            // [cite: 92]
        string  reason                  // red invoice / supplement / cross-period correction / other [cite: 93]
    );

    // Note: Since the contract uses structs for data input, 
    // we use a simplified function signature in the interface definition. 
    // The implementation (AGVOracle.sol) handles the actual parameters.

    // Function signatures
    function storeDailySnapshot(bytes memory data, bytes memory signature) external;
    function storeMonthlySettlement(bytes memory data) external;
    function amendMonthlySettlement(bytes memory data) external;

    // View: return the "current effective revision" for given period+station
    function getEffectiveMonthlySettlement(string calldata period, string calldata stationId)
    external view
    returns (bytes memory /* fields including revision */);
}