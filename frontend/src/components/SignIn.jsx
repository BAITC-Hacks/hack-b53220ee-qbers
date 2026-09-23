import { useEffect, useRef, useState } from "react";
import { api } from "../lib/api";
import { env } from "../lib/env";
import { loadScript } from "../lib/loadScript";

export default function SignIn() {
  const button = useRef(null);
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    api("auth/me/").then((d) => setUser(d.user)).catch(() => {});
  }, []);

  useEffect(() => {
    if (user || !env.googleClientId) return;
    loadScript("https://accounts.google.com/gsi/client")
      .then(() => {
        google.accounts.id.initialize({
          client_id: env.googleClientId,
          callback: async ({ credential }) => {
            try {
              const d = await api("auth/google/", { method: "POST", body: { credential } });
              setUser({ ...d.user, picture: d.picture });
              setError(null);
            } catch (e) {
              setError(e.message);
            }
          },
        });
        google.accounts.id.renderButton(button.current, { theme: "filled_black", shape: "pill", size: "medium", locale: "en" });
      })
      .catch((e) => setError(e.message));
  }, [user]);

  async function signOut() {
    await api("auth/logout/", { method: "POST", body: {} });
    google.accounts?.id.disableAutoSelect();
    setUser(null);
  }

  if (user) {
    return (
      <div className="signin">
        {user.picture ? <img src={user.picture} alt="" /> : <i className="fa-solid fa-circle-user" />}
        <span>{user.name}</span>
        <button className="btn ghost small" onClick={signOut}>
          <i className="fa-solid fa-arrow-right-from-bracket" /> Sign out
        </button>
      </div>
    );
  }
  return (
    <div className="signin" title={error || ""}>
      <div ref={button} />
      {error && <i className="fa-solid fa-triangle-exclamation warn" />}
    </div>
  );
}
