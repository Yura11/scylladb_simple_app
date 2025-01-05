import React from "react";
import styles from "../styles/button.module.css";

const Button = ({ text, onClick, type = "button", disabled = false }) => {
  return (
    <button type={type} onClick={onClick} disabled={disabled} className={styles.button}>
      {text}
    </button>
  );
};

export default Button;
