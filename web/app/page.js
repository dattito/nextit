import Head from "next/head";
import PublicNavbar from "@/components/publicnavabar";
import PublicHomepage from "@/components/public-homepage";

export const dynamic = "force-dynamic";

export default async function Home() {
  return <PublicNavbar />;
}
