import React, { useEffect, useState } from "react";
import axios from "axios";

const Dashboard = () => {
  const [responseData, setResponseData] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const token = localStorage.getItem("jwt_token");

    if (token) {
      axios
        .get("http://localhost:10000/protected", {
          headers: {
            Authorization: `Bearer ${token}`, 
          },
        })
        .then((response) => {
          setResponseData(response.data); 
        })
        .catch((err) => {
          setError(err.response?.data?.message || "Error fetching data.");
        });
    } else {
      setError("No JWT token found. Please login again.");
    }
  }, []);

  return (
    <div className="dashboard">
      <h2>Dashboard</h2>
      {error && <p className="error">{error}</p>}
      {responseData && (
        <div>
          <h3>Protected Data:</h3>
          <pre>{JSON.stringify(responseData, null, 2)}</pre>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
