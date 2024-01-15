import PublicContent from "./public-content";
import PublicSlider from "./public-slider";
import PublicNavbar from "./publicnavabar";

export default function PublicHomepage() {
  return (
    <div>
      <PublicNavbar />
      <PublicSlider />
      <PublicContent />
    </div>
  );
}
