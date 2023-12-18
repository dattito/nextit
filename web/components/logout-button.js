"use client";

import { signOut } from "next-auth/react";

export default function LogoutButton() {
  return (
    <button
      className="btn btn-secondary"
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
