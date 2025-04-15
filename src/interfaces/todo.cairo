#[derive(Drop, Clone, Serde, PartialEq, starknet::Store)]
pub struct Task {
    pub title: ByteArray,
    pub description: ByteArray,
    pub completed: bool,
}

#[starknet::interface]
pub trait ITodo<TContractState> {
    fn add_task(ref self:TContractState, title: ByteArray, desc: ByteArray) -> u256;
    fn complete_task(ref self: TContractState, id: u256, complete: bool, desc: Option<ByteArray>);
    fn delete_task(ref self: TContractState, id: u256);
    fn get_all_tasks(self: @TContractState, id: u256) -> Task;
}