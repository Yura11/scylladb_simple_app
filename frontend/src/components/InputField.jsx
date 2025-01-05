import React from "react";
import styles from "../styles/inputField.module.css"; // Import CSS module

const InputField = ({ label, type, name, value, onChange }) => {
  return (
    <div className={styles["input-group"]}>
      <label htmlFor={name}>{label}</label>
      <input
        id={name}
        type={type}
        name={name}
        value={value}
        onChange={onChange}
        required
      />
    </div>
  );
};

export default InputField;
