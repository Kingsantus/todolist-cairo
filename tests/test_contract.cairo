// Write a simple TODO list contract, that provides functions for add_task, complete_task, delete_task, get_all_tasks. Also, write integration test for the function using Cheatcodes and SafeDispatcher.
// Submit a link to the public repo containing the code here. Goodluck.

use starknet::ContractAddress;

use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait, declare, spy_events,
    start_cheat_caller_address, stop_cheat_caller_address,
};

use task::interfaces::todo::*;
use task::contracts::todo::*;

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

fn SANTUS() -> ContractAddress {
    'SANTUS'.try_into().unwrap()
}


fn deploy_contract(name: ByteArray, owner: ContractAddress) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let mut constructor_args = array![];
    // Serialize the owner address
    SANTUS().serialize(ref constructor_args);
    let (contract_address, _) = contract.deploy(@constructor_args).unwrap();
    contract_address
}


// #[test]
// fn test_increase_balance() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let dispatcher = IHelloStarknetDispatcher { contract_address };

//     let balance_before = dispatcher.get_balance();
//     assert(balance_before == 0, 'Invalid balance');

//     dispatcher.increase_balance(42);

//     let balance_after = dispatcher.get_balance();
//     assert(balance_after == 42, 'Invalid balance');
// }

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
