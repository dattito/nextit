"use client";

import { signOut } from "next-auth/react";
import { useRouter } from "next/navigation";

export default function LogoutButton() {
  const router = useRouter();

  return (
    <button
      className="btn btn-sm btn-outline-primary"
      onClick={async () => {
        await signOut({
          redirect: false,
        });
        router.replace("https://google.com");
      }}
    >
      Log Out
    </button>
  );
}
