import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL ;
console.log("API_URL:", API_URL);

// Register user
export const registerUser = async (userData) => {
  const response = await axios.post(`${API_URL}/register`, userData);
  return response.data;
};

// Login user
export const loginUser = async (credentials) => {
  const response = await axios.post(`${API_URL}/login`, credentials);
  localStorage.setItem("jwt_token", response.data.token); 
  return response.data;
};
