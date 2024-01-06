import Image from "next/image";

export default function PublicContent() {
  return (
    <>
  {/* Header */}
  <header className="text-center mt-5 mb-3">
    <h1>Ihre IT-Experten für erfolgreiche Vernetzung und Design</h1>
    <p>Willkommen bei unserem IT-Dienstleistungsunternehmen. Wir bieten umfassende Lösungen für erfolgreiche Vernetzung und modernes Design.</p>
  </header>

  {/* Hauptinhalt */}
  <div className="container mt-5 mb-3">
    {/* Bild mit Text auf der linken Seite */}
    <div className="row mt-4">
      <div className="col-md-6">
        <Image src="/slider2.jpg" height={500} width={500} alt="Erfolgreich Vernetzen" fluid />
      </div>
      <div className="col-md-6">
        <h4>Erfolgreich Vernetzen</h4>
        <p>Unsere Experten sorgen für eine nahtlose Vernetzung Ihrer IT-Systeme. Wir entwickeln individuelle Lösungen, die perfekt auf Ihre Anforderungen zugeschnitten sind. Von der Netzwerkarchitektur bis zur Implementierung stehen wir Ihnen zur Seite, um sicherzustellen, dass Ihre Systeme reibungslos zusammenarbeiten.</p>
      </div>
    </div>

    {/* Bild mit Text auf der rechten Seite */}
    <div className="row mt-5">
      <div className="col-md-6">
        <h4>Erfolgreich Designen</h4>
        <p>Ein ansprechendes Design ist entscheidend für den Erfolg Ihrer digitalen Präsenz. Unsere erfahrenen Designer arbeiten eng mit Ihnen zusammen, um ein modernes und benutzerfreundliches Design zu schaffen. Von der Konzeptentwicklung bis zur Umsetzung setzen wir Ihre Vision in visuell ansprechende Designs um.</p>
      </div>
      <div className="col-md-6">
        <Image src="/slider3.jpg" height={500} width={500} alt="Erfolgreich Designen" fluid />
      </div>
    </div>

  </div>

  <div className="container mt-5">
    <div className="text-center mt-3"><h4>Unsere Lösungen</h4></div>

    {/* Boxen mit weiterführenden Infos */}
    <div className="row">
      <div className="col-md-4 mt-md-0 mt-3">
        <div className="card">
          <div className="card-body">
            <h5 className="card-title">Vernetzungs-Services</h5>
            <p className="card-text">Unsere umfassenden Vernetzungs-Services optimieren Ihre IT-Infrastruktur und steigern die Effizienz Ihrer Arbeitsabläufe. Wir bieten Lösungen für die Netzwerkplanung, Sicherheit und Skalierbarkeit.</p>
            <a href="#" className="btn btn-primary">Mehr erfahren</a>
          </div>
        </div>
      </div>

      <div className="col-md-4 mt-md-0 mt-3">
        <div className="card">
          <div className="card-body">
            <h5 className="card-title">Design-Services</h5>
            <p className="card-text">Unsere Design-Experten kreieren ansprechende und benutzerfreundliche Designs, die Ihre Marke optimal präsentieren. Wir bieten Dienstleistungen von der Logo-Gestaltung bis zum Webdesign, um sicherzustellen, dass Ihr Unternehmen visuell beeindruckt.</p>
            <a href="#" className="btn btn-primary">Mehr erfahren</a>
          </div>
        </div>
      </div>

      <div className="col-md-4 mt-md-0 mt-3">
        <div className="card">
          <div className="card-body">
            <h5 className="card-title">Support & Wartung</h5>
            <p className="card-text">Unser engagiertes Support-Team steht Ihnen jederzeit zur Verfügung, um sicherzustellen, dass Ihre Systeme reibungslos funktionieren. Wir bieten auch Wartungsdienste, um Probleme frühzeitig zu erkennen und zu beheben.</p>
            <a href="#" className="btn btn-primary">Mehr erfahren</a>
          </div>
        </div>
      </div>
    </div>

  </div>

  {/* Impressum */}
  <footer className="mt-5 pt-4 bg-light text-center" style={{ height: '100px' }}>
    <p>Impressum | Kontakt | Datenschutz</p>
  </footer>
</>
  );
}
