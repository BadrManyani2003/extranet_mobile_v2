const nodemailer = require("nodemailer");

async function main() {
  let transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: "badrmeneyani87@gmail.com",
      pass: "qyizfrdfbklzmmki",
    },
  });

  try {
    let info = await transporter.sendMail({
      from: '"MyASK" <badrmeneyani87@gmail.com>',
      to: "badrmeneyani87@gmail.com", // send to yourself
      subject: "Test SMTP from Node.js",
      text: "Hello, this is a test email.",
    });

    console.log("Message sent: %s", info.messageId);
  } catch (error) {
    console.error("Error sending email:", error);
  }
}

main();
