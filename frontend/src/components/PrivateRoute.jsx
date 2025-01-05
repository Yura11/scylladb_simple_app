import React, { useContext } from 'react';
import { Navigate } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';

const PrivateRoute = ({ element }) => {
  const { user } = useContext(AuthContext); 

  if (!user) {
    return <Navigate to="/login" />;
  }

  return element;
};

export default PrivateRoute;
