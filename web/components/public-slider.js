import Image from "next/image";

export default function PublicSlider() {
  return (
    <div id="carouselExample" className="carousel slide" data-bs-ride="carousel">
      <div className="carousel-inner" style={{height : '300px'}}>
        <div className="carousel-item active">
          <Image src="/slider1.jpg" width={1200} height={800} layout="responsive" />
        </div>
        <div className="carousel-item">
          <Image src="/slider2.jpg" width={1200} height={800} layout="responsive" />
        </div>
        <div className="carousel-item">
          <Image src="/slider3.jpg" width={1200} height={800} layout="responsive" />
        </div>
      </div>
      <button className="carousel-control-prev" type="button" data-bs-target="#carouselExample" data-bs-slide="prev">
        <span className="carousel-control-prev-icon" aria-hidden="true"></span>
        <span className="visually-hidden">Previous</span>
      </button>
      <button className="carousel-control-next" type="button" data-bs-target="#carouselExample" data-bs-slide="next">
        <span className="carousel-control-next-icon" aria-hidden="true"></span>
        <span className="visually-hidden">Next</span>
      </button>
    </div>
  );
}
