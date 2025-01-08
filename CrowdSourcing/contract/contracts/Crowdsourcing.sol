// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdsourcingToken is ERC20 {

    /* Structure Design */
    struct Task {
        address poster;
        uint256 EachReward;
        uint256 ReqTimes;
        bool isCompleted;
    }

    event TaskAdded(
        address indexed poster,
        uint256 indexed taskId,
        uint256 rewards,
        uint256 req_times_
    );
    event TaskRemoved(
        address indexed poster,
        uint256 indexed taskId,
        uint256 rewards,
        uint256 req_times_
    );
    event TasksOneTimeCompleted(
        uint256 indexed taskId, 
        address indexed completer
    );
    /* State Variables */ 
    uint256 public nextTaskId = 0;
    mapping(uint256 => mapping (address=> bool)) TaskRecordsList; 
    mapping (uint256 => Task) public TasksList;

    constructor() ERC20("CrowdsourcingToken", "CST"){}

    /**
    Add Tasks/Mission and mint the token to those questions
    */
    function addTasks(
        uint256[] calldata tasksRewards,
        uint256[] calldata reqTimes
    ) external {
        require(
            tasksRewards.length == reqTimes.length,
            "The length of Tasks and Reqired Times don't match!!!"
        );
        require(
            tasksRewards.length > 0,
            "At least have one task and reqired times!!!"
        );

        uint256 totalReward = 0;
        for (uint i = 0; i < tasksRewards.length; i++){
            require(
                tasksRewards[i]> 0,
                "Reward must be positve!!!"
            );
            require(
                reqTimes[i] > 0,
                "Required Submission must be postive!!!"
            );
            totalReward += tasksRewards[i] * reqTimes[i];
            TasksList[nextTaskId] = Task({
                poster: msg.sender,
                EachReward: tasksRewards[i],
                ReqTimes: reqTimes[i],
                isCompleted: false
            });

            emit TaskAdded(msg.sender,nextTaskId,tasksRewards[i],reqTimes[i]
            );
            nextTaskId++;
        }
        _mint(msg.sender, totalReward);
    }

    function redeemReward(
        uint256 taskId
    ) external {
        Task storage cur_task = TasksList[taskId];
        require(
            !cur_task.isCompleted,
            "Current Task has been completed!!!"
        );
        require(
            cur_task.ReqTimes > 0,
            "No submission is required!!!"
        );
        require(
            cur_task.poster != msg.sender,
            "Task Poster and Submitter is the same!!!"
        );
        require(
            !TaskRecordsList[taskId][msg.sender],
            "Reward has been released for the current submitter!!!"
        );

        cur_task.ReqTimes -= 1;
        if (cur_task.ReqTimes == 0){
            cur_task.isCompleted = true;
        }

        _transfer(cur_task.poster, msg.sender, cur_task.EachReward);
        TaskRecordsList[taskId][msg.sender] = true;

        emit TasksOneTimeCompleted(taskId, msg.sender);
    }

    /**
    Get the task details
    */
    function getTask(
        uint256 taskId
    )public view returns (uint256 reward_, address poster_, uint256 reqTimes, bool isCompleted){
        Task storage task = TasksList[taskId];
        return (task.EachReward,
                task.poster,
                task.ReqTimes,
                task.isCompleted);
    }

    /**
    Verify the validity for the recent _x_ submission
    */
    // function ValidityChecker(
    // ) public pure returns (bool){
    //     return true;
    // }

    // /**
    // Froozen the account if it submitted too many trash/invalid submission
    // */
    // function AccountChecker(
    //     address account
    // )public pure returns (bool){
    //     require(account != address(0), "Zero Address was found!!!");
    //     require(PtpRecordsList[]);
    // }

}