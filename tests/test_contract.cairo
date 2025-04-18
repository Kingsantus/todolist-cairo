use starknet::ContractAddress;

use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait, declare, spy_events,
    start_cheat_caller_address, stop_cheat_caller_address,
};

use task::interfaces::todo::{ITodoDispatcher, ITodoDispatcherTrait, ITodoSafeDispatcher};
use task::contracts::todo::Todo;

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

fn SANTUS() -> ContractAddress {
    'SANTUS'.try_into().unwrap()
}

#[derive(Drop, Clone, Serde, PartialEq, starknet::Store)]
pub struct Task {
    pub title: ByteArray,
    pub description: ByteArray,
    pub completed: bool,
}


fn deploy_contract(owner: ContractAddress) -> ContractAddress {
    let contract = declare("Task").unwrap().contract_class();
    let mut constructor_args = array![];
    // Serialize the owner address
    SANTUS().serialize(ref constructor_args);
    let (contract_address, _) = contract.deploy(@constructor_args).unwrap();
    contract_address
}


#[test]
fn test_add_task() {
    let contract_address = deploy_contract(SANTUS());
    let mut spy = spy_events();
    let caller: ContractAddress = SANTUS();
    let task = ITodoDispatcher { contract_address };
    let title = "test title".into();
    let desc = "test description".into();
    let id = task.add_task(title, desc);
    let task = task.get_all_tasks(id);
    assert(task.title == "test title".into(), 'incorrect title');
    assert(task.description == "test description".into(), 'incorrect description');
    assert(task.completed == bool::False, 'incorrect completed');
    spy
    .assert_emitted(
        @array![
        (
                contract_address,
                Todo::Event::TaskCreated(Todo::Taskcreated { id: 1 }),
            ),
        ],
    );
}
    
#[test]
fn test_complete_task() {
    let contract_address = deploy_contract(SANTUS());
    let mut spy = spy_events();
    let caller: ContractAddress = SANTUS();
    let task = ITodoDispatcher { contract_address };
    let title = "test title".into();
    let desc = "test description".into();
    let id = task.add_task(title, desc);

    task.complete_task(id, bool::True, Option::None(()));
    let task = task.get_all_tasks(id);
    assert(task.completed == bool::True, 'incorrect completed');
    spy
    .assert_emitted(
        @array![
        (
                contract_address,
                Todo::Event::TaskUpdated(Todo::TaskUpdated { id: 1 }),
            ),
        ],
    );
}

#[test]
fn test_delete_task() {
    let contract_address = deploy_contract(SANTUS());
    let mut spy = spy_events();
    let caller: ContractAddress = SANTUS();
    let task = ITodoDispatcher { contract_address };
    start_cheat_caller_address(contract_address, caller);

    let title = "test title".into();
    let desc = "test description".into();
    let id = task.add_task(title, desc);

    task.delete_task(id);
    let task = task.get_all_tasks(id);
    assert(task.title == "".into(), 'incorrect title');
    assert(task.description == "".into(), 'incorrect description');
    assert(task.completed == bool::False, 'incorrect completed');
    spy
    .assert_emitted(
        @array![
        (
                contract_address,
                Todo::Event::TaskDeleted(Todo::TaskDeleted { id: 1 }),
            ),
        ],
    );

    stop_cheat_caller_address(contract_address);
}
