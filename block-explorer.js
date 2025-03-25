

import React, { useState } from 'react';
import axios from 'axios';
import "./App.css";

const API_KEY = 'xxx'; //  API Key

function App() {
  const [blockNumber, setBlockNumber] = useState('');
  const [blockData, setBlockData] = useState(null);
  const [error, setError] = useState(null);
const [color,setColor]=useState(null)
  const fetchBlockData = async () => {
    setError(null);
    setBlockData(null);

    try {
  const response = await axios.get(
     `https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=${parseInt(blockNumber, 10).toString(16)}&boolean=true&apikey=${API_KEY}`
  );

      if (response.data.result) {
        setBlockData(response.data.result);
      } else {
        setError('Block not found or invalid block number');
      }
    } catch (err) {
      setError('Failed to fetch block data');
    }
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    fetchBlockData();
  };
function coloring(){
if(color==="black"){
  setColor("blue")

}
else{
  setColor("white")
}
}
  return (
    <div className="App" style={{ fontFamily: 'Arial' }}>
<div className='form'>
<h1 style={{color:"white"}} > 🔒 Ethereum Block Explorer</h1>

<form onSubmit={handleSubmit} >
  <div className="form-group mr-2">
    <input
      type="text"
     style={{padding:"10px",borderRadius:"30px"}}
      value={blockNumber}
      onChange={(e) => setBlockNumber(e.target.value)}
      placeholder="Enter block number"
    />
  </div>
  <button type="submit" className="btn btn-dark" 
  




  style={{marginTop:"30px",marginBottom:"30px"}} >🧩Fetch Block</button>
</form>
</div>

      {error && <p className="text-danger text-center">{error}</p>}

      {blockData && (

       <div className='box' >
       
    <h3 style={{textAlign:"center"}}><span style={{color:"black"}}>🔗</span>Block Information </h3>

           <ul className="list-group list-group-flush">
              <li className="list-group-item"><strong>Block Number:</strong> {parseInt(blockData.number, 16)}</li>
            <li className="list-group-item"><strong>Timestamp:</strong> {new Date(parseInt(blockData.timestamp, 16) * 1000).toLocaleString()}</li>
              <li className="list-group-item"><strong>Hash:</strong> {blockData.hash}</li>
            <li className="list-group-item"><strong>Parent Hash:</strong> {blockData.parentHash}</li>
              <li className="list-group-item"><strong>Miner:</strong> {blockData.miner}</li>
              <li className="list-group-item"><strong>Transaction Count:</strong> {blockData.transactions.length}</li>
            </ul>
          </div>

      )}
    </div>
  );
}

export default App;
