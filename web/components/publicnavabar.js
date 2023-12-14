import Image from "next/image";
import LoginButton from "./login-button";

export default function PublicNavbar() {
  return (
    <nav className="navbar bg-body-tertiary">
      <div className="container-fluid">
        <a className="navbar-brand">
          <Image src="/Logo_wide.png" width={100} height={100} alt="Logo" />
        </a>
        <div className="d-flex">
          <LoginButton />
        </div>
      </div>
    </nav>
  );
}
