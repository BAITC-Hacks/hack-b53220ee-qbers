import { useEffect, useState } from "react";
import { api } from "../lib/api";

export default function WaitlistForm() {
  const [count, setCount] = useState(null);
  const [form, setForm] = useState({ name: "", email: "" });
  const [status, setStatus] = useState({ state: "idle" });

  useEffect(() => {
    api("waitlist/").then((d) => setCount(d.count)).catch(() => {});
  }, []);

  async function submit(e) {
    e.preventDefault();
    setStatus({ state: "sending" });
    try {
      const d = await api("waitlist/", { method: "POST", body: form });
      setCount(d.count);
      setForm({ name: "", email: "" });
      setStatus({ state: "done" });
    } catch (err) {
      const errors = err.data?.errors;
      const message = errors ? Object.values(errors).flat().join(" ") : err.message;
      setStatus({ state: "error", message });
    }
  }

  const update = (key) => (e) => setForm({ ...form, [key]: e.target.value });

  return (
    <section className="card">
      <header className="card-head">
        <i className="fa-solid fa-paper-plane" />
        <div>
          <h3>Django form → Postgres</h3>
          <p>
            <strong className="accent">{count ?? "—"}</strong> people on the waitlist
          </p>
        </div>
      </header>
      <form className="waitlist" onSubmit={submit}>
        <label>
          <i className="fa-solid fa-user-astronaut" />
          <input placeholder="Your name" value={form.name} onChange={update("name")} required />
        </label>
        <label>
          <i className="fa-solid fa-at" />
          <input type="email" placeholder="you@domain.com" value={form.email} onChange={update("email")} required />
        </label>
        <button className="btn" disabled={status.state === "sending"}>
          {status.state === "sending" ? <i className="fa-solid fa-spinner fa-spin" /> : <i className="fa-solid fa-rocket" />}
          Join the launch
        </button>
      </form>
      {status.state === "done" && <p className="card-ok"><i className="fa-solid fa-circle-check" /> Saved to the database.</p>}
      {status.state === "error" && <p className="card-error"><i className="fa-solid fa-triangle-exclamation" /> {status.message}</p>}
    </section>
  );
}
