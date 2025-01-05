import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; 
import InputField from "../components/InputField";
import Button from "../components/Button";
import ErrorMessage from "../components/ErrorMessage";
import { registerUser } from "../services/authService";
import styles from '../styles/register.module.css'; 

const Register = () => {
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    confirmPassword: "",
  });

  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const { username, password, confirmPassword } = formData;

    if (password !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    try {
      await registerUser({ username, password });
      navigate("/login");
    } catch (err) {
      setError(err.message || "Registration failed");
    }
  };

  return (
    <div className={styles.registerPage}> 
      <h2 className={styles.heading}>Register</h2>
      <ErrorMessage message={error} />
      <form onSubmit={handleSubmit} className={styles.form}>
        <InputField
          label="Username"
          type="text"
          name="username"
          value={formData.username}
          onChange={handleChange}
        />
        <InputField
          label="Password"
          type="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
        />
        <InputField
          label="Confirm Password"
          type="password"
          name="confirmPassword"
          value={formData.confirmPassword}
          onChange={handleChange}
        />
        <Button text="Register" type="submit" className={styles.button} />
      </form>
    </div>
  );
};

export default Register;
