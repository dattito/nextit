"use client";

import { signOut } from "next-auth/react";

export default function LogoutButton() {
  return (
    <button
      className="btn btn-sm btn-outline-primary"
      onClick={() =>
        signOut({
          callbackUrl: "/",
        })
      }
    >
      Log Out
    </button>
  );
}
