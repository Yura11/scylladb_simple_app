import React from "react";
import styles from "../styles/inputField.module.css"; 

const InputField = ({ label, type, name, value, onChange }) => {
  return (
    <div className={styles["input-group"]}>
      <input
        id={name}
        type={type}
        name={name}
        value={value}
        onChange={onChange}
        placeholder={label}
        required
      />
    </div>
  );
};

export default InputField;
