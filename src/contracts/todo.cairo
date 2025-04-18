#[starknet::contract]
pub mod Todo {
    use starknet::event::EventEmitter;
    use openzeppelin::access::ownable::OwnableComponent;
    use core::starknet::ContractAddress;
    use core::starknet::get_caller_address;
    use core::starknet::storage::{
        Map,
        StoragePathEntry,
        StoragePointerReadAccess,
        StoragePointerWriteAccess
    };
    use crate::interfaces::todo::*;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        tasks: Map<(u256, ContractAddress), Task>,
        nounce: u256,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        TaskCreated: TaskCreated,
        TaskUpdated: TaskUpdated,
        TaskDeleted: TaskDeleted,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    pub struct TaskCreated {
        id: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TaskUpdated {
       id: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TaskDeleted {
       id: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // Set the initial owner of the contract
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl TodoImpl of ITodo<ContractState> {
        fn add_task(ref self:ContractState, title: ByteArray, desc: ByteArray) -> u256 {
            let id = self.nounce.read() + 1;
            assert!(title != "" && desc != "", "TITLE OR DESC IS EMPTY");
            let caller = get_caller_address();
            let task = Task {
                title: title,
                description: desc,
                completed: bool::False
            };
            self.tasks.entry((id, caller)).write(task);
            self.nounce.write(id);
            self.emit(Event::TaskCreated(TaskCreated {
                id: id
            }));
            id
        }

        fn complete_task(
            ref self: ContractState, id: u256, complete: bool, desc: Option<ByteArray>
        ) {
            let caller = get_caller_address();
            let mut task = self.tasks.entry((id, caller)).read();
            assert(task.completed != bool::False, 'TASK IS ALREADY COMPLETED');
            match desc {
                Option::Some(new_desc) => {
                    task.description = new_desc;
                },
                Option::None(_) => {},
            }
            task.completed = complete;
            self.emit(Event::TaskUpdated(TaskUpdated {
                id: id
            }));
            self.tasks.entry((id, caller)).write(task);
        }

        fn delete_task(ref self: ContractState, id: u256) {
            let caller = get_caller_address();
            // Set the task to its default value to effectively "delete" it
            self.tasks.entry((id, caller)).write(
                Task { title: "", description: "", completed: bool::False }
            );
            self.ownable.assert_only_owner();
            self.emit(Event::TaskDeleted(TaskDeleted {
                id: id
            }));
        }

        fn get_all_tasks(self: @ContractState, id: u256) -> Task {
            let caller = get_caller_address();
            self.tasks.entry((id, caller)).read()
        }
    }
}