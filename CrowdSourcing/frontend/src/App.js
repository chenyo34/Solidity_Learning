import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import { getProvider, getContract } from "./services/contract";

function App() {
  const [account, setAccount] = useState(null);
  const [userBalance, setUserBalance] = useState("0");
  const [taskIdToQuery, setTaskIdToQuery] = useState("");
  const [taskInfo, setTaskInfo] = useState(null);

  // 新建任务所需字段
  // 假设一次添加多个任务。为了简单，这里演示添加“单个任务”，如果要多个可扩展成 array。
  const [eachReward, setEachReward] = useState("");
  const [reqTimes, setReqTimes] = useState("");

  // 任务提交 / 兑换奖励
  const [redeemTaskId, setRedeemTaskId] = useState("");

  // 连接钱包
  const connectWallet = async () => {
    try {
      const provider = getProvider();
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const address = await signer.getAddress();
      setAccount(address);

      // 获取用户余额
      const contract = getContract(signer);
      const balance = await contract.balanceOf(address);
      // CrowdsourcingToken 继承了 ERC20，所以可以直接调用 balanceOf
      setUserBalance(ethers.utils.formatUnits(balance, 18));
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  // 刷新/获取当前账户 Token 余额
  const fetchBalance = async () => {
    if (!account) return;
    try {
      const provider = getProvider();
      const signer = provider.getSigner();
      const contract = getContract(signer);
      const balance = await contract.balanceOf(account);
      setUserBalance(ethers.utils.formatUnits(balance, 18));
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  // 添加任务
  const addTask = async () => {
    if (!eachReward || !reqTimes) return;
    try {
      const provider = getProvider();
      const signer = provider.getSigner();
      const contract = getContract(signer);

      // 合约的 addTasks 接收数组参数
      const tasksRewards = [ethers.utils.parseUnits(eachReward, 18)];
      const reqTimesArray = [reqTimes];

      const tx = await contract.addTasks(tasksRewards, reqTimesArray);
      await tx.wait();

      alert("任务创建成功");
      setEachReward("");
      setReqTimes("");
      // 更新余额
      fetchBalance();
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  // 查询任务信息
  const getTaskInfo = async () => {
    if (!taskIdToQuery) return;
    try {
      const provider = getProvider();
      const contract = getContract(provider);
      const [reward, poster, reqTimesRemaining, isCompleted] = await contract.getTask(taskIdToQuery);

      const formattedReward = ethers.utils.formatUnits(reward, 18);
      setTaskInfo({
        reward: formattedReward,
        poster,
        reqTimesRemaining: reqTimesRemaining.toString(),
        isCompleted
      });
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  // 兑换奖励
  const redeem = async () => {
    if (!redeemTaskId) return;
    try {
      const provider = getProvider();
      const signer = provider.getSigner();
      const contract = getContract(signer);

      const tx = await contract.redeemReward(redeemTaskId);
      await tx.wait();

      alert(`兑换任务 ${redeemTaskId} 成功！`);
      // 更新余额
      fetchBalance();
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  // 当账号变化时，自动刷新余额
  useEffect(() => {
    if (account) fetchBalance();
    // eslint-disable-next-line
  }, [account]);

  return (
    <div style={{ margin: "20px" }}>
      <h1>CrowdsourcingToken DApp</h1>
      {!account ? (
        <button onClick={connectWallet}>连接钱包</button>
      ) : (
        <div>
          <p>当前账户: {account}</p>
          <p>账户余额: {userBalance} CST</p>
        </div>
      )}

      <hr />

      <h2>发布新任务</h2>
      <p>EachReward（单位 CST）</p>
      <input
        type="number"
        value={eachReward}
        onChange={(e) => setEachReward(e.target.value)}
      />
      <p>ReqTimes（需要多少次提交才完成）</p>
      <input
        type="number"
        value={reqTimes}
        onChange={(e) => setReqTimes(e.target.value)}
      />
      <br />
      <button onClick={addTask}>发布任务</button>

      <hr />

      <h2>查询任务信息</h2>
      <p>请输入 Task ID</p>
      <input
        type="number"
        value={taskIdToQuery}
        onChange={(e) => setTaskIdToQuery(e.target.value)}
      />
      <button onClick={getTaskInfo}>查询</button>

      {taskInfo && (
        <div style={{ marginTop: "20px" }}>
          <p>Reward: {taskInfo.reward} CST</p>
          <p>Poster: {taskInfo.poster}</p>
          <p>ReqTimes 剩余: {taskInfo.reqTimesRemaining}</p>
          <p>是否完成: {taskInfo.isCompleted ? "是" : "否"}</p>
        </div>
      )}

      <hr />

      <h2>兑换奖励</h2>
      <p>请输入 Task ID</p>
      <input
        type="number"
        value={redeemTaskId}
        onChange={(e) => setRedeemTaskId(e.target.value)}
      />
      <button onClick={redeem}>兑换</button>
    </div>
  );
}

export default App;
