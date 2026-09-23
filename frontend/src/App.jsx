import ChartCard from "./components/ChartCard";
import MapCard from "./components/MapCard";
import SignIn from "./components/SignIn";
import StatusGrid from "./components/StatusGrid";
import WaitlistForm from "./components/WaitlistForm";

const STACK = [
  { icon: "fa-brands fa-python", name: "Django", note: "Forms, auth & site actions" },
  { icon: "fa-solid fa-database", name: "PostgreSQL", note: "Primary data store" },
  { icon: "fa-brands fa-react", name: "React", note: "Interactive UI via Vite" },
  { icon: "fa-brands fa-google", name: "Google Cloud", note: "Maps, Charts, Sign-In" },
  { icon: "fa-brands fa-aws", name: "AWS", note: "Ready for deployment" },
];

export default function App() {
  return (
    <>
      <div className="bg-grid" aria-hidden />
      <div className="bg-glow" aria-hidden />

      <nav className="nav">
        <a className="brand" href="/">
          <i className="fa-solid fa-atom" />
          <span>QBERS</span>
        </a>
        <div className="nav-links">
          <a href="#live"><i className="fa-solid fa-signal" /> Live</a>
          <a href="#stack"><i className="fa-solid fa-layer-group" /> Stack</a>
          <a href="/admin/" target="_blank" rel="noreferrer"><i className="fa-solid fa-shield-halved" /> Admin</a>
        </div>
        <SignIn />
      </nav>

      <main>
        <section className="hero">
          <p className="eyebrow"><i className="fa-solid fa-bolt" /> HackAlem · local build online</p>
          <h1>
            The future is <em>running</em> on localhost.
          </h1>
          <p className="lede">
            A demo landing page that proves every layer of our stack is wired together: React talking to Django,
            Django talking to Postgres, and Google APIs rendering live.
          </p>
          <StatusGrid />
        </section>

        <section id="live" className="grid">
          <MapCard />
          <ChartCard />
          <WaitlistForm />
        </section>

        <section id="stack" className="stack">
          <h2>Built on</h2>
          <div className="stack-row">
            {STACK.map((s) => (
              <div key={s.name} className="stack-item">
                <i className={s.icon} />
                <strong>{s.name}</strong>
                <span>{s.note}</span>
              </div>
            ))}
          </div>
        </section>
      </main>

      <footer className="footer">
        <i className="fa-solid fa-code" /> Team QBERS · {new Date().getFullYear()}
      </footer>
    </>
  );
}
