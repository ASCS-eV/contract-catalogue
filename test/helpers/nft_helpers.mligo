[@public] #import "../../lib/fa2/nft/nft.impl.mligo" "FA2_NFT"

let get_initial_storage () =
  let () = Test.Next.State.reset 8n ([
    1000000tez;
    1000000tez;
    1000000tez;
    1000000tez;
    1000000tez;
    1000000tez;
    1000000tez;
    1000000tez;
  ] : tez list) in

  let baker = Test.Next.Account.address 7n in
  let () = Test.Next.State.set_baker baker in

  let owner1 = Test.Next.Account.address 0n in
  let owner2 = Test.Next.Account.address 1n in
  let owner3 = Test.Next.Account.address 2n in
  let owner4 = Test.Next.Account.address 6n in

  let owners = [owner1; owner2; owner3; owner4] in

  let op1 = Test.Next.Account.address 3n in
  let op2 = Test.Next.Account.address 4n in
  let op3 = Test.Next.Account.address 5n in

  let ops = [op1; op2; op3] in

    let ledger = Big_map.literal ([
    (1n, owner1);
    (2n, owner2);
    (3n, owner3);
    (4n, owner4);
    (5n, owner4);
  ])
  in

  let operators  = Big_map.literal ([
    ((owner1, op1), Set.literal [1n]);
    ((owner2, op1), Set.literal [2n]);
    ((owner3, op1), Set.literal [3n]);
    ((op1   , op3), Set.literal [1n]);
    ((owner4, op1), Set.literal [4n; 5n]);
  ])
  in

  let token_metadata = (Big_map.literal [
    (1n, ({token_id=1n;token_info=(Map.empty : (string, bytes) map);} : FA2_NFT.TZIP12.tokenMetadataData));
    (2n, ({token_id=2n;token_info=(Map.empty : (string, bytes) map);} : FA2_NFT.TZIP12.tokenMetadataData));
    (3n, ({token_id=3n;token_info=(Map.empty : (string, bytes) map);} : FA2_NFT.TZIP12.tokenMetadataData));
    (4n, ({token_id=3n;token_info=(Map.empty : (string, bytes) map);} : FA2_NFT.TZIP12.tokenMetadataData));
    (5n, ({token_id=3n;token_info=(Map.empty : (string, bytes) map);} : FA2_NFT.TZIP12.tokenMetadataData));
  ] : FA2_NFT.TZIP12.tokenMetadata) in

  let metadata =Big_map.literal [
	("", [%bytes {|tezos-storage:data|}]);
	("data", [%bytes
{|{
	"name":"FA2",
	"description":"Example FA2 implementation",
	"version":"0.1.0",
	"license":{"name":"MIT"},
	"authors":["Benjamin Fuentes<benjamin.fuentes@marigold.dev>"],
	"homepage":"",
	"source":{"tools":["Ligo"], "location":"https://github.com/ligolang/contract-catalogue/tree/main/lib/fa2"},
	"interfaces":["TZIP-012"],
	"errors":[],
	"views":[]

}|}]);
] in


  let initial_storage : FA2_NFT.storage = {
    ledger         = ledger;
    token_metadata = token_metadata;
    operators      = operators;
    metadata       = metadata;
  } in

  initial_storage, owners, ops


let assert_balances
  (contract_address : (FA2_NFT parameter_of, FA2_NFT.storage) typed_address )
  (a, b, c : (address * nat) * (address * nat) * (address * nat)) =
  let (owner1, token_id_1) = a in
  let (owner2, token_id_2) = b in
  let (owner3, token_id_3) = c in
  let storage = Test.Next.Typed_address.get_storage contract_address in
  let ledger = storage.ledger in
  let () = match (Big_map.find_opt token_id_1 ledger) with
    Some amt -> Assert.assert (amt = owner1)
  | None -> Test.Next.Assert.failwith "incorrect address"
  in
  let () = match (Big_map.find_opt token_id_2 ledger) with
    Some amt ->  Assert.assert (amt = owner2)
  | None -> Test.Next.Assert.failwith "incorrect address"
  in
  let () = match (Big_map.find_opt token_id_3 ledger) with
    Some amt -> Assert.assert (amt = owner3)
  | None -> Test.Next.Assert.failwith "incorrect address"
  in
  ()

let assert_error (result : test_exec_result) (error : FA2_NFT.Errors.t) =
  match result with
    Success _ -> Test.Next.Assert.failwith "This test should fail"
  | Fail (Rejected (err, _))  -> Assert.assert (Test.Next.Compare.eq err (Test.Next.Michelson.eval error))
  | Fail _ -> Test.Next.Assert.failwith "invalid test failure"
