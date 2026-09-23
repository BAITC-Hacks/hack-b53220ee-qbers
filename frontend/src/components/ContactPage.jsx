import { useRef, useState } from "react";
import damirPhoto from "../assets/team/damir1.jpg";
import damirSecondPhoto from "../assets/team/damir2.jpg";
import sabyrzhanPhoto from "../assets/team/sabyrzhan.jpg";
import sabyrzhanSecondPhoto from "../assets/team/sabyrzhan2.jpg";
import anselPhoto from "../assets/team/ansel1.jpg";
import anselSecondPhoto from "../assets/team/ansel2.jpg";
import groupPhoto from "../assets/team/group_photo.jpg";
import "./ContactPage.css";

const MEMBERS = [
  { id: "damir", photo: damirPhoto, secondPhoto: damirSecondPhoto, email: "isakovdamirforwca@gmail.com", telegram: "dgsq1" },
  { id: "sabyrzhan", photo: sabyrzhanPhoto, secondPhoto: sabyrzhanSecondPhoto, email: "kanatov.s.07@mail.ru", telegram: "Xd3Ys" },
  { id: "ansel", photo: anselPhoto, secondPhoto: anselSecondPhoto, email: "ansel@ns.com", telegram: "BrackiumEmendo" },
];

function ContactIcon({ type, ...props }) {
  const paths = {
    arrow: <path d="M4 12h16m-6-6 6 6-6 6" />,
    mail: <><rect x="3" y="5" width="18" height="14" rx="3" /><path d="m4 7 8 6 8-6" /></>,
    pin: <><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z" /><circle cx="12" cy="10" r="2.5" /></>,
    telegram: <><path d="m21 3-4 18-6-6-4 3 1-7L21 3 3 9l5 2" /><path d="m8 11 9-5-6 9" /></>,
  };
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true" {...props}>{paths[type]}</svg>;
}

function EmailContact({ member, person, copy }) {
  const [copyStatus, setCopyStatus] = useState("");
  const addressInput = useRef(null);
  const recipient = encodeURIComponent(member.email);

  async function copyAddress() {
    try {
      if (!navigator.clipboard?.writeText) throw new Error("Clipboard unavailable");
      await navigator.clipboard.writeText(member.email);
      setCopyStatus("Email address copied.");
    } catch {
      addressInput.current?.focus();
      addressInput.current?.select();
      setCopyStatus("Select and copy the email address above.");
    }
  }

  return (
    <details className="contact-email-picker" onToggle={() => setCopyStatus("")}>
      <summary className="contact-email" aria-label={`${copy.email}: ${person.name}, ${member.email}`}>
        <ContactIcon type="mail" />
        <span><span className="contact-link-label">{copy.email}</span><span className="contact-address">{member.email}</span></span>
        <ContactIcon type="arrow" />
      </summary>
      <div className="contact-email-options" role="group" aria-label={`Email options for ${person.name}`}>
        <p>Choose your email service. The recipient is already filled in.</p>
        <a href={`https://mail.google.com/mail/?view=cm&fs=1&to=${recipient}`} target="_blank" rel="noopener noreferrer">
          Gmail <span>New tab <ContactIcon type="arrow" /></span>
        </a>
        <a href={`https://outlook.live.com/mail/0/deeplink/compose?to=${recipient}`} target="_blank" rel="noopener noreferrer">
          Outlook <span>New tab <ContactIcon type="arrow" /></span>
        </a>
        <a href={`mailto:${member.email}`}>Default email app <ContactIcon type="mail" /></a>
        <label htmlFor={`email-address-${member.id}`}>Email address</label>
        <div className="contact-copy-row">
          <input id={`email-address-${member.id}`} ref={addressInput} type="text" value={member.email} readOnly autoComplete="off" spellCheck={false} />
          <button type="button" onClick={copyAddress} aria-label={`Copy email address for ${person.name}`}>Copy</button>
        </div>
        <p className="contact-copy-status" role="status">{copyStatus}</p>
      </div>
    </details>
  );
}

function MemberCard({ member, copy }) {
  const person = copy.members[member.id];
  return (
    <article className={`contact-member contact-member--${member.id}`} aria-labelledby={`member-${member.id}`}>
      <div className="contact-portraits">
        <div className="contact-portrait">
          <img src={member.photo} alt={`${copy.portrait} ${person.name}`} width="160" height="160" loading="lazy" />
        </div>
        {member.secondPhoto && (
          <div className="contact-portrait contact-portrait--second">
            <img src={member.secondPhoto} alt={`${copy.secondPortrait} ${person.name}`} width="96" height="96" loading="lazy" />
          </div>
        )}
      </div>
      <p className="contact-role">{person.role}</p>
      <h3 id={`member-${member.id}`}>{person.name}</h3>
      <p className="contact-location"><ContactIcon type="pin" />{person.location}</p>
      <div className="contact-bio">{person.bio.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}</div>
      <ul className="contact-tags" aria-label={person.role}>
        {person.tags.map((tag) => <li key={tag}>{tag}</li>)}
      </ul>
      <div className="contact-links">
        <EmailContact member={member} person={person} copy={copy} />
        <a className="contact-telegram" href={`https://t.me/${member.telegram}`} target="_blank" rel="noopener noreferrer" aria-label={`${copy.telegram}: ${person.name}, @${member.telegram}`}>
          <ContactIcon type="telegram" /><span>{copy.telegram}</span><span className="contact-handle">@{member.telegram}</span>
        </a>
      </div>
    </article>
  );
}

export default function ContactPage({ copy }) {
  return (
    <main className="contact-page" lang="en">
      <section className="contact-hero" aria-labelledby="contact-heading">
        <div className="contact-hero-copy">
          <p className="contact-eyebrow"><span className="contact-dot" />{copy.eyebrow}</p>
          <h1 id="contact-heading">{copy.heading}</h1>
          <p className="contact-intro">{copy.intro}</p>
          <button className="contact-primary" type="button" onClick={() => {
            document.getElementById("contact-team").focus({ preventScroll: true });
            document.getElementById("contact-team").scrollIntoView({ block: "start" });
          }}>{copy.meet}<ContactIcon type="arrow" /></button>
          <p className="contact-hero-location"><ContactIcon type="pin" />{copy.location}</p>
        </div>
        <figure className="contact-team-photo">
          <img src={groupPhoto} alt={copy.photoAlt} width="1920" height="2560" fetchPriority="high" />
          <figcaption><strong>{copy.photoCaption}</strong><span>{copy.photoNames}</span></figcaption>
        </figure>
      </section>

      <section id="contact-team" className="contact-team" aria-labelledby="contact-team-heading" tabIndex={-1}>
        <div className="contact-section-heading">
          <div><p className="contact-eyebrow">{copy.teamEyebrow}</p><h2 id="contact-team-heading">{copy.teamHeading}</h2></div>
          <p>{copy.teamIntro}</p>
        </div>
        <div className="contact-member-grid">
          {MEMBERS.map((member) => <MemberCard key={member.id} member={member} copy={copy} />)}
        </div>
      </section>

      <aside className="contact-note">
        <div className="contact-note-icon"><ContactIcon type="mail" /></div>
        <div><h2>{copy.noteHeading}</h2><p>{copy.note}</p></div>
        <a href="#/" className="contact-back">{copy.back}<ContactIcon type="arrow" /></a>
      </aside>
    </main>
  );
}
