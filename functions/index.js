const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();

const SMTP_HOST = defineSecret("SMTP_HOST");
const SMTP_PORT = defineSecret("SMTP_PORT");
const SMTP_USER = defineSecret("SMTP_USER");
const SMTP_PASS = defineSecret("SMTP_PASS");
const SMTP_FROM = defineSecret("SMTP_FROM");

function buildTransporter({ host, port, user, pass }) {
  return nodemailer.createTransport({
    host,
    port,
    secure: String(port) === "465",
    auth: { user, pass },
  });
}

exports.sendOtpEmail = onDocumentCreated(
  {
    document: "otp_emails/{docId}",
    region: "europe-west1",
    secrets: [SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM],
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data() || {};
    const to = data.to;
    const subject = data.subject || "Verification Code";
    const html = data.html || "";

    // Prevent re-sending if the doc was already processed.
    if (data.sentAt || data.status === "sent") return;

    if (!to || typeof to !== "string") {
      await snap.ref.update({
        status: "error",
        error: "Missing or invalid `to` field",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const host = SMTP_HOST.value();
    const port = SMTP_PORT.value();
    const user = SMTP_USER.value();
    const pass = SMTP_PASS.value();
    const from = SMTP_FROM.value();

    const transporter = buildTransporter({ host, port, user, pass });

    try {
      await transporter.sendMail({
        from,
        to,
        subject,
        html,
      });

      await snap.ref.update({
        status: "sent",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      await snap.ref.update({
        status: "error",
        error: String(err),
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  },
);

