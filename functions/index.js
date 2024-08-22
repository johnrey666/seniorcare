const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

// Configure the email transport using Nodemailer and Gmail with App Passwords
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'johnreydado3@gmail.com',  // Replace with your Gmail address
    pass: 'asnz gxdm zayp auwx',     // Replace with your generated App Password
  },
});

exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const mailOptions = {
    from: 'johnreydado3@gmail.com',
    to: data.email,
    subject: 'Your Verification Code',
    text: `Your verification code is ${data.code}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});
