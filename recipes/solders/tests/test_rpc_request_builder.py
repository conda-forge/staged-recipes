"""These tests are mainly about getting mypy to check stuff, as it doesn't check doc examples."""

from typing import List, Union

from solders.account_decoder import UiAccountEncoding, UiDataSliceConfig
from solders.commitment_config import CommitmentLevel
from solders.hash import Hash
from solders.instruction import AccountMeta, Instruction
from solders.keypair import Keypair
from solders.message import Message
from solders.pubkey import Pubkey
from solders.rpc.config import (
    RpcAccountInfoConfig,
    RpcBlockConfig,
    RpcBlockProductionConfig,
    RpcBlockProductionConfigRange,
    RpcBlockSubscribeConfig,
    RpcBlockSubscribeFilter,
    RpcBlockSubscribeFilterMentions,
    RpcContextConfig,
    RpcEpochConfig,
    RpcGetVoteAccountsConfig,
    RpcLargestAccountsFilter,
    RpcLeaderScheduleConfig,
    RpcProgramAccountsConfig,
    RpcRequestAirdropConfig,
    RpcSendTransactionConfig,
    RpcSignaturesForAddressConfig,
    RpcSignatureStatusConfig,
    RpcSignatureSubscribeConfig,
    RpcSimulateTransactionAccountsConfig,
    RpcSimulateTransactionConfig,
    RpcSupplyConfig,
    RpcTokenAccountsFilterMint,
    RpcTokenAccountsFilterProgramId,
    RpcTransactionConfig,
    RpcTransactionLogsConfig,
    RpcTransactionLogsFilter,
    RpcTransactionLogsFilterMentions,
)
from solders.rpc.filter import Memcmp
from solders.rpc.requests import (
    AccountSubscribe,
    AccountUnsubscribe,
    BlockSubscribe,
    BlockUnsubscribe,
    GetAccountInfo,
    GetBalance,
    GetBlock,
    GetBlockCommitment,
    GetBlockHeight,
    GetBlockProduction,
    GetBlocks,
    GetBlocksWithLimit,
    GetBlockTime,
    GetClusterNodes,
    GetEpochInfo,
    GetEpochSchedule,
    GetFeeForMessage,
    GetFirstAvailableBlock,
    GetGenesisHash,
    GetHealth,
    GetHighestSnapshotSlot,
    GetIdentity,
    GetInflationGovernor,
    GetInflationRate,
    GetInflationReward,
    GetLargestAccounts,
    GetLatestBlockhash,
    GetLeaderSchedule,
    GetMaxRetransmitSlot,
    GetMaxShredInsertSlot,
    GetMinimumBalanceForRentExemption,
    GetMultipleAccounts,
    GetProgramAccounts,
    GetRecentPerformanceSamples,
    GetSignaturesForAddress,
    GetSignatureStatuses,
    GetSlot,
    GetSlotLeader,
    GetSlotLeaders,
    GetStakeActivation,
    GetSupply,
    GetTokenAccountBalance,
    GetTokenAccountsByDelegate,
    GetTokenAccountsByOwner,
    GetTokenLargestAccounts,
    GetTokenSupply,
    GetTransaction,
    GetTransactionCount,
    GetVersion,
    GetVoteAccounts,
    IsBlockhashValid,
    LogsSubscribe,
    LogsUnsubscribe,
    MinimumLedgerSlot,
    ProgramSubscribe,
    ProgramUnsubscribe,
    RequestAirdrop,
    RootSubscribe,
    RootUnsubscribe,
    SendLegacyTransaction,
    SignatureSubscribe,
    SignatureUnsubscribe,
    SimulateLegacyTransaction,
    SlotSubscribe,
    SlotsUpdatesSubscribe,
    SlotsUpdatesUnsubscribe,
    SlotUnsubscribe,
    ValidatorExit,
    VoteSubscribe,
    VoteUnsubscribe,
    batch_from_json,
    batch_to_json,
)
from solders.signature import Signature
from solders.transaction import Transaction
from solders.transaction_status import TransactionDetails, UiTransactionEncoding


def test_get_account_info() -> None:
    config = RpcAccountInfoConfig(UiAccountEncoding.Base64)
    req = GetAccountInfo(Pubkey.default(), config)
    as_json = req.to_json()
    assert GetAccountInfo.from_json(as_json) == req


def test_get_balance() -> None:
    config = RpcContextConfig(min_context_slot=1)
    req = GetBalance(Pubkey.default(), config)
    as_json = req.to_json()
    assert GetBalance.from_json(as_json) == req


def test_get_block() -> None:
    config = RpcBlockConfig(
        encoding=UiTransactionEncoding.Base58,
        transaction_details=TransactionDetails.None_,
    )
    req = GetBlock(123, config)
    as_json = req.to_json()
    assert GetBlock.from_json(as_json) == req


def test_get_block_height() -> None:
    config = RpcContextConfig(min_context_slot=123)
    req = GetBlockHeight(config)
    as_json = req.to_json()
    assert GetBlockHeight.from_json(as_json) == req


def test_get_block_production() -> None:
    slot_range = RpcBlockProductionConfigRange(first_slot=10, last_slot=15)
    config = RpcBlockProductionConfig(identity=Pubkey.default(), range=slot_range)
    req = GetBlockProduction(config)
    as_json = req.to_json()
    assert GetBlockProduction.from_json(as_json) == req


def test_get_block_commitment() -> None:
    req = GetBlockCommitment(123)
    as_json = req.to_json()
    assert GetBlockCommitment.from_json(as_json) == req


def test_get_blocks() -> None:
    req = GetBlocks(123, commitment=CommitmentLevel.Processed)
    as_json = req.to_json()
    assert GetBlocks.from_json(as_json) == req
    req2 = GetBlocks(123)
    as_json2 = req2.to_json()
    assert GetBlocks.from_json(as_json2) == req2
    req3 = GetBlocks(123, 124)
    as_json3 = req3.to_json()
    assert GetBlocks.from_json(as_json3) == req3


def test_get_blocks_with_limit() -> None:
    req = GetBlocksWithLimit(123, 5, commitment=CommitmentLevel.Processed)
    as_json = req.to_json()
    assert GetBlocksWithLimit.from_json(as_json) == req


def test_get_block_time() -> None:
    req = GetBlockTime(123)
    as_json = req.to_json()
    assert GetBlockTime.from_json(as_json) == req


def test_get_cluster_nodes() -> None:
    req = GetClusterNodes(123)
    as_json = req.to_json()
    assert GetClusterNodes.from_json(as_json) == req


def test_get_epoch_info() -> None:
    config = RpcContextConfig(commitment=CommitmentLevel.Processed)
    req = GetEpochInfo(config)
    as_json = req.to_json()
    assert GetEpochInfo.from_json(as_json) == req


def test_get_epoch_schedule() -> None:
    req = GetEpochSchedule(123)
    as_json = req.to_json()
    assert GetEpochSchedule.from_json(as_json) == req


def test_get_fee_for_message() -> None:
    req = GetFeeForMessage(Message.default(), commitment=CommitmentLevel.Processed)
    as_json = req.to_json()
    assert GetFeeForMessage.from_json(as_json) == req


def test_get_first_available_block() -> None:
    req = GetFirstAvailableBlock(123)
    as_json = req.to_json()
    assert GetFirstAvailableBlock.from_json(as_json) == req


def test_get_genesis_hash() -> None:
    req = GetGenesisHash(123)
    as_json = req.to_json()
    assert GetGenesisHash.from_json(as_json) == req


def test_get_health() -> None:
    req = GetHealth(123)
    as_json = req.to_json()
    assert GetHealth.from_json(as_json) == req


def test_get_highest_snapshot_slot() -> None:
    req = GetHighestSnapshotSlot(123)
    as_json = req.to_json()
    assert GetHighestSnapshotSlot.from_json(as_json) == req


def test_get_identity() -> None:
    req = GetIdentity(123)
    as_json = req.to_json()
    assert GetIdentity.from_json(as_json) == req


def test_validator_exit() -> None:
    req = ValidatorExit(123)
    as_json = req.to_json()
    assert ValidatorExit.from_json(as_json) == req


def test_get_inflation_governor() -> None:
    req = GetInflationGovernor(CommitmentLevel.Finalized)
    as_json = req.to_json()
    assert GetInflationGovernor.from_json(as_json) == req


def test_get_inflation_rate() -> None:
    req = GetInflationRate(123)
    as_json = req.to_json()
    assert GetInflationRate.from_json(as_json) == req


def test_get_inflation_reward() -> None:
    config = RpcEpochConfig(epoch=1234)
    addresses = [Pubkey.default(), Pubkey.default()]
    req = GetInflationReward(addresses, config)
    as_json = req.to_json()
    assert GetInflationReward.from_json(as_json) == req


def test_get_largest_accounts() -> None:
    commitment = CommitmentLevel.Processed
    filter_ = RpcLargestAccountsFilter.Circulating
    req = GetLargestAccounts(commitment=commitment, filter_=filter_)
    as_json = req.to_json()
    assert GetLargestAccounts.from_json(as_json) == req
    req2 = GetLargestAccounts()
    as_json2 = req2.to_json()
    assert GetLargestAccounts.from_json(as_json2) == req2
    req3 = GetLargestAccounts(commitment=commitment)
    as_json3 = req3.to_json()
    assert GetLargestAccounts.from_json(as_json3) == req3
    req4 = GetLargestAccounts(filter_=filter_)
    as_json4 = req4.to_json()
    assert GetLargestAccounts.from_json(as_json4) == req4


def test_get_latest_blockhash() -> None:
    config = RpcContextConfig(commitment=CommitmentLevel.Processed)
    req = GetLatestBlockhash(config)
    as_json = req.to_json()
    assert GetLatestBlockhash.from_json(as_json) == req


def test_get_leader_schedule() -> None:
    config = RpcLeaderScheduleConfig(identity=Pubkey.default())
    req = GetLeaderSchedule(123, config)
    as_json = req.to_json()
    assert GetLeaderSchedule.from_json(as_json) == req
    req2 = GetLeaderSchedule()
    as_json2 = req2.to_json()
    assert GetLeaderSchedule.from_json(as_json2) == req2
    req3 = GetLeaderSchedule(config=config)
    as_json3 = req3.to_json()
    assert GetLeaderSchedule.from_json(as_json3) == req3
    req4 = GetLeaderSchedule(123)
    as_json4 = req4.to_json()
    assert GetLeaderSchedule.from_json(as_json4) == req4


def test_get_max_retransmit_slot() -> None:
    req = GetMaxRetransmitSlot(123)
    as_json = req.to_json()
    assert GetMaxRetransmitSlot.from_json(as_json) == req


def test_get_max_shred_insert_slot() -> None:
    req = GetMaxShredInsertSlot(123)
    as_json = req.to_json()
    assert GetMaxShredInsertSlot.from_json(as_json) == req


def test_get_minimum_balance_for_rent_exemption() -> None:
    req = GetMinimumBalanceForRentExemption(50)
    as_json = req.to_json()
    assert GetMinimumBalanceForRentExemption.from_json(as_json) == req


def test_get_multiple_accounts() -> None:
    encoding = UiAccountEncoding.Base64Zstd
    data_slice = UiDataSliceConfig(10, 8)
    config = RpcAccountInfoConfig(encoding=encoding, data_slice=data_slice)
    accounts = [Pubkey.default(), Pubkey.default()]
    req = GetMultipleAccounts(accounts, config)
    as_json = req.to_json()
    assert GetMultipleAccounts.from_json(as_json) == req


def test_get_program_accounts() -> None:
    acc_info_config = RpcAccountInfoConfig.default()
    filters: List[Union[int, Memcmp]] = [10, Memcmp(offset=10, bytes_=b"123")]
    config = RpcProgramAccountsConfig(acc_info_config, filters)
    req = GetProgramAccounts(Pubkey.default(), config)
    as_json = req.to_json()
    assert GetProgramAccounts.from_json(as_json) == req


def test_get_recent_performance_samples() -> None:
    req = GetRecentPerformanceSamples(5)
    as_json = req.to_json()
    assert GetRecentPerformanceSamples.from_json(as_json) == req


def test_get_signatures_for_address() -> None:
    config = RpcSignaturesForAddressConfig(limit=10)
    req = GetSignaturesForAddress(Pubkey.default(), config)
    as_json = req.to_json()
    assert GetSignaturesForAddress.from_json(as_json) == req


def test_get_signature_statuses() -> None:
    req = GetSignatureStatuses([Signature.default()], RpcSignatureStatusConfig(True))
    as_json = req.to_json()
    assert GetSignatureStatuses.from_json(as_json) == req


def test_get_slot() -> None:
    config = RpcContextConfig(min_context_slot=123)
    req = GetSlot(config)
    as_json = req.to_json()
    assert GetSlot.from_json(as_json) == req


def test_get_slot_leader() -> None:
    config = RpcContextConfig(min_context_slot=123)
    req = GetSlotLeader(config)
    as_json = req.to_json()
    assert GetSlotLeader.from_json(as_json) == req


def test_get_slot_leaders() -> None:
    req = GetSlotLeaders(100, 10)
    as_json = req.to_json()
    assert GetSlotLeaders.from_json(as_json) == req


def test_get_stake_activation() -> None:
    config = RpcEpochConfig(epoch=1234)
    req = GetStakeActivation(Pubkey.default(), config)
    as_json = req.to_json()
    assert GetStakeActivation.from_json(as_json) == req


def test_get_supply() -> None:
    config = RpcSupplyConfig(exclude_non_circulating_accounts_list=True)
    req = GetSupply(config)
    as_json = req.to_json()
    assert GetSupply.from_json(as_json) == req


def test_get_token_account_balance() -> None:
    req = GetTokenAccountBalance(Pubkey.default(), CommitmentLevel.Processed)
    as_json = req.to_json()
    assert GetTokenAccountBalance.from_json(as_json) == req


def test_get_token_accounts_by_delegate() -> None:
    program_filter = RpcTokenAccountsFilterProgramId(
        Pubkey.from_string("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
    )
    config = RpcAccountInfoConfig(min_context_slot=1234)
    req = GetTokenAccountsByDelegate(Pubkey.default(), program_filter, config)
    assert req.filter_ == program_filter
    as_json = req.to_json()
    assert GetTokenAccountsByDelegate.from_json(as_json) == req


def test_get_token_accounts_by_owner() -> None:
    mint_filter = RpcTokenAccountsFilterMint(Pubkey.default())
    config = RpcAccountInfoConfig(min_context_slot=1234)
    req = GetTokenAccountsByOwner(Pubkey.default(), mint_filter, config)
    assert req.filter_ == mint_filter
    as_json = req.to_json()
    assert GetTokenAccountsByOwner.from_json(as_json) == req


def test_get_token_largest_accounts() -> None:
    req = GetTokenLargestAccounts(Pubkey.default())
    as_json = req.to_json()
    assert GetTokenLargestAccounts.from_json(as_json) == req


def test_get_token_supply() -> None:
    req = GetTokenSupply(Pubkey.default())
    as_json = req.to_json()
    assert GetTokenSupply.from_json(as_json) == req


def test_get_transaction() -> None:
    config = RpcTransactionConfig(max_supported_transaction_version=1)
    req = GetTransaction(Signature.default(), config)
    as_json = req.to_json()
    assert GetTransaction.from_json(as_json) == req


def test_get_transaction_count() -> None:
    config = RpcContextConfig(min_context_slot=1234)
    req = GetTransactionCount(config)
    as_json = req.to_json()
    assert GetTransactionCount.from_json(as_json) == req


def test_get_version() -> None:
    req = GetVersion(123)
    as_json = req.to_json()
    assert GetVersion.from_json(as_json) == req


def test_get_vote_accounts() -> None:
    config = RpcGetVoteAccountsConfig(keep_unstaked_delinquents=False)
    req = GetVoteAccounts(config)
    as_json = req.to_json()
    assert GetVoteAccounts.from_json(as_json) == req


def test_is_blockhash_valid() -> None:
    req = IsBlockhashValid(Hash.default())
    as_json = req.to_json()
    assert IsBlockhashValid.from_json(as_json) == req


def test_minimum_ledger_slot() -> None:
    req = MinimumLedgerSlot(123)
    as_json = req.to_json()
    assert MinimumLedgerSlot.from_json(as_json) == req


def test_request_airdrop() -> None:
    config = RpcRequestAirdropConfig(commitment=CommitmentLevel.Confirmed)
    req = RequestAirdrop(Pubkey.default(), 1000, config)
    as_json = req.to_json()
    assert RequestAirdrop.from_json(as_json) == req


def test_send_transaction() -> None:
    program_id = Pubkey.default()
    arbitrary_instruction_data = b"abc"
    accounts: List[AccountMeta] = []
    instruction = Instruction(program_id, arbitrary_instruction_data, accounts)
    seed = bytes([1] * 32)
    payer = Keypair.from_seed(seed)
    message = Message([instruction], payer.pubkey())
    blockhash = Hash.default()  # replace with a real blockhash
    tx = Transaction([payer], message, blockhash)
    commitment = CommitmentLevel.Confirmed
    config = RpcSendTransactionConfig(preflight_commitment=commitment)
    req = SendLegacyTransaction(tx, config)
    as_json = req.to_json()
    assert SendLegacyTransaction.from_json(as_json) == req


def test_simulate_transaction() -> None:
    program_id = Pubkey.default()
    arbitrary_instruction_data = b"abc"
    accounts: List[AccountMeta] = []
    instruction = Instruction(program_id, arbitrary_instruction_data, accounts)
    seed = bytes([1] * 32)
    payer = Keypair.from_seed(seed)
    message = Message([instruction], payer.pubkey())
    blockhash = Hash.default()  # replace with a real blockhash
    tx = Transaction([payer], message, blockhash)
    account_encoding = UiAccountEncoding.Base64Zstd
    accounts_config = RpcSimulateTransactionAccountsConfig(
        [Pubkey.default()], account_encoding
    )
    commitment = CommitmentLevel.Confirmed
    config = RpcSimulateTransactionConfig(
        commitment=commitment, accounts=accounts_config
    )
    req = SimulateLegacyTransaction(tx, config)
    as_json = req.to_json()
    assert SimulateLegacyTransaction.from_json(as_json) == req


def test_account_subscribe() -> None:
    config = RpcAccountInfoConfig(UiAccountEncoding.Base64)
    req = AccountSubscribe(Pubkey.default(), config)
    as_json = req.to_json()
    assert AccountSubscribe.from_json(as_json) == req


def test_block_subscribe() -> None:
    config = RpcBlockSubscribeConfig(transaction_details=TransactionDetails.Signatures)
    req = BlockSubscribe(RpcBlockSubscribeFilter.All, config)
    as_json = req.to_json()
    assert BlockSubscribe.from_json(as_json) == req
    req2 = BlockSubscribe(RpcBlockSubscribeFilterMentions(Pubkey.default()), config)
    as_json2 = req2.to_json()
    assert BlockSubscribe.from_json(as_json2) == req2


def test_logs_subscribe() -> None:
    config = RpcTransactionLogsConfig(commitment=CommitmentLevel.Confirmed)
    req = LogsSubscribe(RpcTransactionLogsFilter.All, config)
    as_json = req.to_json()
    assert LogsSubscribe.from_json(as_json) == req
    req2 = LogsSubscribe(RpcTransactionLogsFilterMentions(Pubkey.default()), config)
    as_json2 = req2.to_json()
    assert LogsSubscribe.from_json(as_json2) == req2


def test_program_subscribe() -> None:
    acc_info_config = RpcAccountInfoConfig.default()
    filters: List[Union[int, Memcmp]] = [10, Memcmp(offset=10, bytes_=b"123")]
    config = RpcProgramAccountsConfig(acc_info_config, filters)
    req = ProgramSubscribe(Pubkey.default(), config)
    as_json = req.to_json()
    assert ProgramSubscribe.from_json(as_json) == req


def test_signature_subscribe() -> None:
    config = RpcSignatureSubscribeConfig(enable_received_notification=False)
    req = SignatureSubscribe(Signature.default(), config)
    as_json = req.to_json()
    assert SignatureSubscribe.from_json(as_json) == req


def test_slot_subscribe() -> None:
    req = SlotSubscribe(123)
    as_json = req.to_json()
    assert SlotSubscribe.from_json(as_json) == req


def test_slots_updates_subscribe() -> None:
    req = SlotsUpdatesSubscribe(123)
    as_json = req.to_json()
    assert SlotsUpdatesSubscribe.from_json(as_json) == req


def test_root_subscribe() -> None:
    req = RootSubscribe(123)
    as_json = req.to_json()
    assert RootSubscribe.from_json(as_json) == req


def test_vote_subscribe() -> None:
    req = VoteSubscribe(123)
    as_json = req.to_json()
    assert VoteSubscribe.from_json(as_json) == req


def test_account_unsubscribe() -> None:
    req = AccountUnsubscribe(1, 2)
    as_json = req.to_json()
    assert AccountUnsubscribe.from_json(as_json) == req


def test_block_unsubscribe() -> None:
    req = BlockUnsubscribe(1, 2)
    as_json = req.to_json()
    assert BlockUnsubscribe.from_json(as_json) == req


def test_logs_unsubscribe() -> None:
    req = LogsUnsubscribe(1, 2)
    as_json = req.to_json()
    assert LogsUnsubscribe.from_json(as_json) == req


def test_program_unsubscribe() -> None:
    req = ProgramUnsubscribe(1, 2)
    as_json = req.to_json()
    assert ProgramUnsubscribe.from_json(as_json) == req


def test_signature_unsubscribe() -> None:
    req = SignatureUnsubscribe(1, 2)
    as_json = req.to_json()
    assert SignatureUnsubscribe.from_json(as_json) == req


def test_slot_unsubscribe() -> None:
    req = SlotUnsubscribe(1, 2)
    as_json = req.to_json()
    assert SlotUnsubscribe.from_json(as_json) == req


def test_slots_updates_unsubscribe() -> None:
    req = SlotsUpdatesUnsubscribe(1, 2)
    as_json = req.to_json()
    assert SlotsUpdatesUnsubscribe.from_json(as_json) == req


def test_root_unsubscribe() -> None:
    req = RootUnsubscribe(1, 2)
    as_json = req.to_json()
    assert RootUnsubscribe.from_json(as_json) == req


def test_vote_unsubscribe() -> None:
    req = VoteUnsubscribe(1, 2)
    as_json = req.to_json()
    assert VoteUnsubscribe.from_json(as_json) == req


def test_batch() -> None:
    reqs: List[Union[GetSignatureStatuses, RequestAirdrop]] = [
        GetSignatureStatuses([Signature.default()], RpcSignatureStatusConfig(True)),
        RequestAirdrop(Pubkey.default(), 1000),
    ]
    as_json = batch_to_json(reqs)
    assert as_json == (
        '[{"method":"getSignatureStatuses","jsonrpc":"2.0","id":0,"params"'
        ':[["1111111111111111111111111111111111111111111111111111111111111111"],'
        '{"searchTransactionHistory":true}]},{"method":"requestAirdrop","jsonrpc":"2.0","id":0,'
        '"params":["11111111111111111111111111111111",1000]}]'
    )
    assert batch_from_json(as_json) == reqs
