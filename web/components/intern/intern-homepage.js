import { getItemsProto } from "@/lib/items/actions-proto";
import InternContent from "./intern-content";
import InternNavbar from "./intern-navbar";
import { getServerSession } from "next-auth";
import { authOptions } from "@/app/api/auth/[...nextauth]/route";

export default async function InternHomepage() {
  return (
    <>
      <InternNavbar />
      <InternContent
        defaultItems={await getItemsProto()}
        username={(await getServerSession(authOptions))?.user?.name ?? "User"}
      />
    </>
  );
}
