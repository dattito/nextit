import PublicNavbar from "@/components/publicnavabar";

export const dynamic = "force-dynamic";

export default async function Home() {
  // const r = new AddItemRequest();
  // r.setName("Test!");
  // itemService.addItem(r, (e, res) => {
  //   console.log("Add:", res);
  // });

  return <PublicNavbar />;
}
