import Image from "next/image";
import LogoutButton from "./logout-button";

export default function InternNavbar() {
  return (
    <nav className="navbar bg-body-tertiary">
      <div className="container-fluid">
        <a className="navbar-brand">
          <Image src="/Logo_wide.png" width={100} height={0} />
        </a>
        <div className="d-flex">
          <LogoutButton />
        </div>
      </div>
    </nav>
  );
}
