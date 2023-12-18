import Image from "next/image";
import LogoutButton from "./logout-button";

export default function InternNavbar() {
  return (
    <nav class="navbar bg-body-tertiary">
      <div class="container-fluid">
        <a class="navbar-brand">
          <Image src="/Logo_wide.png" width={100} height={0} />
        </a>
        <div class="d-flex">
          <LogoutButton />
        </div>
      </div>
    </nav>
  );
}
