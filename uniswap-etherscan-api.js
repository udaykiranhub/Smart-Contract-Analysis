import React, { useState, useEffect } from "react";
import { Table, Form, InputGroup, Button, Pagination, Modal, Row, Col } from "react-bootstrap";
import './uniswap.css'; // Add any additional custom styles

const UniswapTransactions = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(5);
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [showModal, setShowModal] = useState(false);

  const ETHERSCAN_API_KEY = "xxx";
  const UNISWAP_ADDRESS = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"; // Uniswap V2 Router

  const fetchTransactions = async () => {
    setLoading(true);
    setError("");
    try {
      const url = `https://api.etherscan.io/api?module=account&action=txlist&address=${UNISWAP_ADDRESS}&startblock=0&endblock=99999999&sort=desc&apikey=${ETHERSCAN_API_KEY}`;

      const response = await fetch(url);
      const data = await response.json();

      if (data.status === "1") {
        setTransactions(data.result);
      } else {
        setError("Error fetching transactions.");
      }
    } catch (err) {
      setError("Failed to fetch transactions. Please try again.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, []);

  // Filter transactions based on search term
  const filteredTransactions = transactions.filter(tx =>
    tx.from.toLowerCase().includes(searchTerm.toLowerCase()) ||
    tx.to.toLowerCase().includes(searchTerm.toLowerCase()) ||
    tx.hash.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Pagination logic
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentTransactions = filteredTransactions.slice(indexOfFirstItem, indexOfLastItem);

  const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage);

  // Open modal for detailed transaction
  const handleShowModal = (transaction) => {
    setSelectedTransaction(transaction);
    setShowModal(true);
  };

  const handleCloseModal = () => setShowModal(false);

  // Handle pagination
  const nextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };

  const previousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };

  return (
    <div className="container mt-5">
      <h2 className="text-center mb-4">Uniswap V2 Transactions</h2>

      {/* Search Bar */}
      <Row className="mb-3">
        <Col md={8}>
          <InputGroup>
            <Form.Control
              type="text"
              placeholder="Search by Hash, From, To..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </InputGroup>
        </Col>
        <Col md={4}>
          <Button variant="primary" className="w-100">Search</Button>
        </Col>
      </Row>

      {loading ? (
        <p className="text-center">Loading transactions...</p>
      ) : error ? (
        <p className="text-center text-danger">{error}</p>
      ) : (
        <>
          {/* Transactions Table */}
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Hash</th>
                <th>From</th>
                <th>To</th>
                <th>Value (ETH)</th>
                <th>Block Number</th>
                <th>Details</th>
              </tr>
            </thead>
            <tbody>
              {currentTransactions.length === 0 ? (
                <tr>
                  <td colSpan="6" className="text-center">No transactions found.</td>
                </tr>
              ) : (
                currentTransactions.map((tx) => (
                  <tr key={tx.hash}>
                    <td>{tx.hash.substring(0, 10)}...</td>
                    <td>{tx.from}</td>
                    <td>{tx.to}</td>
                    <td>{(tx.value / Math.pow(10, 18)).toFixed(4)} ETH</td>
                    <td>{tx.blockNumber}</td>
                    <td>
                      <Button variant="info" onClick={() => handleShowModal(tx)}>
                        View Details
                      </Button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </Table>

          {/* Pagination */}
          <div className="d-flex justify-content-between mb-4">
            <Button 
              variant="secondary" 
              onClick={previousPage} 
              disabled={currentPage === 1}
            >
              Previous
            </Button>
            <Button 
              variant="secondary" 
              onClick={nextPage} 
              disabled={currentPage === totalPages}
            >
              Next
            </Button>
          </div>

          {/* Transaction Details Modal */}
          {selectedTransaction && (
            <Modal show={showModal} onHide={handleCloseModal}>
              <Modal.Header closeButton>
                <Modal.Title>Transaction Details</Modal.Title>
              </Modal.Header>
              <Modal.Body>
                <p><strong>Hash:</strong> {selectedTransaction.hash}</p>
                <p><strong>From:</strong> {selectedTransaction.from}</p>
                <p><strong>To:</strong> {selectedTransaction.to}</p>
                <p><strong>Value:</strong> {(selectedTransaction.value / Math.pow(10, 18)).toFixed(4)} ETH</p>
                <p><strong>Block Number:</strong> {selectedTransaction.blockNumber}</p>
                <p><strong>Timestamp:</strong> {new Date(selectedTransaction.timeStamp * 1000).toLocaleString()}</p>
              </Modal.Body>
              <Modal.Footer>
                <Button variant="secondary" onClick={handleCloseModal}>Close</Button>
              </Modal.Footer>
            </Modal>
          )}
        </>
      )}
    </div>
  );
};

export default UniswapTransactions;
