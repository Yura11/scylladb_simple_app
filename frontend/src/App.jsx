import { Routes, Route } from "react-router-dom";
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Register from './pages/Register';
import { AuthProvider } from "./context/AuthContext";
import PrivateRoute from './components/PrivateRoute';
import './styles/global.css';


export default function App() {
  return (
    <AuthProvider>  
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
      </Routes>
    </AuthProvider>  
  );
}
