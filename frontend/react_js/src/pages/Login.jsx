import React, { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser } from "../services/authService";
import { AuthContext } from "../context/AuthContext";
import InputField from "../components/InputField";
import Button from "../components/Button";
import styles from '../styles/login.module.css'; 
import loginImage from "../assets/login.webp";

const Login = () => {
  const [credentials, setCredentials] = useState({ email: "", password: "" });
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const { setUser } = useContext(AuthContext); 

  const handleChange = (e) => {
    const { name, value } = e.target;
    setCredentials({ ...credentials, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const data = await loginUser(credentials);
      setUser(data.user); 
      navigate("/dashboard"); 
    } catch (err) {
      setError(err.response?.data?.message || "Login failed. Please try again.");
    }
  };

  return (
    <div className={styles.loginPage}>
      <div className={styles.imageContainer}>
        <img src={loginImage} alt="Login Illustration" className={styles.image} />
      </div>
      <div className={styles.formContainer}>
        <h2 className={styles.heading}>Login</h2>
        {error && <p className={styles.error}>{error}</p>}
        <form onSubmit={handleSubmit} className={styles.form}>
          <InputField
            label="Username"
            type="text"
            name="email"
            value={credentials.email}
            onChange={handleChange}
          />
          <InputField
            label="Password"
            type="password"
            name="password"
            value={credentials.password}
            onChange={handleChange}
          />
          <Button type="submit" text="Login" className={styles.button} />
        </form>
        <p className={styles.redirectText}>
          Don't have an account?{" "}
          <a href="/register" className={styles.redirectLink}>
            Register here
          </a>
        </p>
      </div>
    </div>
  );
};

export default Login;

